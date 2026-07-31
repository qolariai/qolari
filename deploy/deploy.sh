#!/usr/bin/env bash
# ============================================================================
# QOLARI — Deploy com releases datadas + symlink (rollback instantaneo)
# Alvo: /var/www/qolari (servidor Hetzner, Ubuntu 24.04)
#
# USO:
#   deploy.sh              — deploy normal (git pull + composer + migrate)
#   deploy.sh rollback     — volta para a release anterior
#
# ESTRUTURA:
#   /var/www/qolari/
#   ├── releases/
#   │   ├── 20260730-143000/
#   │   ├── 20260731-090000/
#   │   └── ...
#   ├── shared/
#   │   ├── .env
#   │   └── storage/
#   └── current -> releases/20260731-090000
# ============================================================================
set -euo pipefail

APP_DIR="/var/www/qolari"
RELEASES_DIR="$APP_DIR/releases"
SHARED_DIR="$APP_DIR/shared"
CURRENT_LINK="$APP_DIR/current"
KEEP_RELEASES=5
PHP_VERSION="8.3"
REPO_URL="git@github.com:qolariai/qolari.git"

log()  { echo -e "\033[1;34m[deploy]\033[0m $*"; }
die()  { echo -e "\033[1;31m[erro]\033[0m $*" >&2; exit 1; }

# ----------------------------------------------------------------------------
# ROLLBACK
# ----------------------------------------------------------------------------
if [[ "${1:-}" == "rollback" ]]; then
    log "Rollback para a release anterior..."
    CURRENT=$(readlink -f "$CURRENT_LINK")
    PREV=$(ls -1d "$RELEASES_DIR"/*/ | grep -v "$(basename "$CURRENT")" | sort -r | head -1)
    [[ -n "$PREV" ]] || die "Nao ha release anterior para rollback."
    ln -sfn "${PREV%/}" "$CURRENT_LINK"
    sudo systemctl reload php${PHP_VERSION}-fpm
    log "Rollback concluido: $(basename "$PREV")"
    exit 0
fi

# ----------------------------------------------------------------------------
# DEPLOY NORMAL
# ----------------------------------------------------------------------------
STAMP=$(date +%Y%m%d-%H%M%S)
RELEASE_DIR="$RELEASES_DIR/$STAMP"

log "Nova release: $STAMP"

# 1) Clonar/pull para a nova release
if [[ -d "$RELEASES_DIR" && "$(ls -A "$RELEASES_DIR" 2>/dev/null)" ]]; then
    # Copia da release anterior + git pull (mais rapido que clone)
    CURRENT=$(readlink -f "$CURRENT_LINK" 2>/dev/null || echo "")
    if [[ -n "$CURRENT" && -d "$CURRENT" ]]; then
        cp -a "$CURRENT" "$RELEASE_DIR"
        cd "$RELEASE_DIR"
        git fetch origin
        git reset --hard origin/main
    else
        git clone --depth 1 "$REPO_URL" "$RELEASE_DIR"
        cd "$RELEASE_DIR"
    fi
else
    mkdir -p "$RELEASES_DIR"
    git clone --depth 1 "$REPO_URL" "$RELEASE_DIR"
    cd "$RELEASE_DIR"
fi

log "Codigo atualizado."

# 2) Composer install (producao)
composer install --no-dev --optimize-autoloader --no-interaction --quiet
log "Dependencias instaladas."

# 3) Shared: .env + storage (symlinks)
mkdir -p "$SHARED_DIR/storage/logs" "$SHARED_DIR/storage/app" "$SHARED_DIR/storage/framework"
if [[ ! -f "$SHARED_DIR/.env" ]]; then
    cp .env.example "$SHARED_DIR/.env"
    log "AVISO: $SHARED_DIR/.env criado a partir do example. Editar manualmente!"
fi
ln -sfn "$SHARED_DIR/.env" "$RELEASE_DIR/.env"
rm -rf "$RELEASE_DIR/storage"
ln -sfn "$SHARED_DIR/storage" "$RELEASE_DIR/storage"

# 4) Migrations
php artisan migrate --force --no-interaction
log "Migrations aplicadas."

# 5) Cache de config/routes/views
php artisan config:cache --quiet
php artisan route:cache --quiet
php artisan view:cache --quiet
log "Caches gerados."

# 6) Ativar symlink (atomico)
ln -sfn "$RELEASE_DIR" "$CURRENT_LINK"
log "Symlink atualizado: current -> $STAMP"

# 7) Restart servicos
sudo systemctl reload php${PHP_VERSION}-fpm
if command -v supervisorctl >/dev/null 2>&1; then
    sudo supervisorctl restart qolari-horizon 2>/dev/null || true
fi
log "Servicos reiniciados."

# 8) Limpeza: manter so as ultimas N releases
cd "$RELEASES_DIR"
ls -1d */ | sort -r | tail -n +$((KEEP_RELEASES + 1)) | while read -r old; do
    rm -rf "$old"
    log "Removida release antiga: $old"
done

log "Deploy concluido com sucesso. Release: $STAMP"
