#!/usr/bin/env bash
# ============================================================================
# QOLARI — Provisionamento do servidor (Fase 1)
# Marca: Qolari (qolari.com) — antes "Nexus AI" (rebrand a 28-07-2026)
# Alvo: Ubuntu 24.04 LTS, Hetzner CPX31 EXISTENTE (partilhado com outros projetos)
#
# GARANTIAS DESTE SCRIPT:
#   * NÃO cria servidores novos (corre dentro do servidor, via SSH)
#   * NÃO toca em projetos existentes: instala só o que falta, cria apenas
#     recursos isolados com o nome "qolari" (pool PHP-FPM, BD, user MySQL,
#     server blocks Nginx, pastas /var/www/qolari e /opt/qolari)
#   * FASE 0 corre SEMPRE primeiro: auditoria completa → /root/qolari-audit.txt
#     e o script PARA. Só continua com CONFIRM=yes na segunda execução.
#   * Idempotente: pode correr várias vezes sem estragar nada.
#
# USO:
#   1ª vez (auditoria):     sudo bash provision.sh
#   Rever /root/qolari-audit.txt. Se estiver tudo OK:
#   2ª vez (instalação):    sudo CONFIRM=yes \
#                              QOLARI_DB_PASSWORD='...' \
#                              QOLARI_S3_KEY='...' QOLARI_S3_SECRET='...' \
#                              QOLARI_S3_BUCKET='...' \
#                              bash provision.sh
#
# NENHUM segredo fica gravado neste ficheiro. Os valores passados por
# ambiente são escritos apenas em /opt/qolari/backup.env (chmod 600).
# ============================================================================
set -euo pipefail

APP_USER="qolari"
APP_DIR="/var/www/qolari"
OPT_DIR="/opt/qolari"
PHP_VERSION="8.3"
DB_NAME="qolari"
DB_USER="qolari"
DOMAIN="qolari.com"
API_DOMAIN="api.qolari.com"
AUDIT_FILE="/root/qolari-audit.txt"

log()  { echo -e "\033[1;34m[qolari]\033[0m $*"; }
warn() { echo -e "\033[1;33m[aviso]\033[0m $*"; }
die()  { echo -e "\033[1;31m[erro]\033[0m $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Corre como root: sudo bash provision.sh"

# ============================================================================
# FASE 0 — AUDITORIA (sempre corre; na 1ª vez o script para aqui)
# ============================================================================
log "FASE 0 — Auditoria ao servidor (nada é alterado)"
{
    echo "=== QOLARI AUDIT — $(date -Is) ==="
    echo; echo "--- Sistema ---"
    lsb_release -d 2>/dev/null; uname -m
    echo; echo "--- RAM e swap ---"
    free -h
    echo; echo "--- Disco ---"
    df -h / /var 2>/dev/null || df -h /
    echo; echo "--- Portas em escuta ---"
    ss -tlnp | awk 'NR==1 || /LISTEN/'
    echo; echo "--- Serviços ativos (top 40 por memória) ---"
    ps aux --sort=-%mem | head -41
    echo; echo "--- Versões instaladas (se existirem) ---"
    for cmd in php mysql nginx redis-server node npm supervisorctl s3cmd composer; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "$cmd: $($cmd --version 2>&1 | head -1)"
        else
            echo "$cmd: NÃO INSTALADO"
        fi
    done
    echo; echo "--- Bases de dados MySQL existentes (NÃO tocar) ---"
    mysql -Nse 'SHOW DATABASES;' 2>/dev/null || echo "(MySQL inacessível ou não instalado)"
    echo; echo "--- Sites Nginx existentes (NÃO tocar) ---"
    ls -1 /etc/nginx/sites-enabled/ 2>/dev/null || echo "(Nginx não instalado)"
    echo; echo "--- Pools PHP-FPM existentes (NÃO tocar) ---"
    ls -1 /etc/php/*/fpm/pool.d/*.conf 2>/dev/null || echo "(PHP-FPM não instalado)"
    echo; echo "--- Crontabs existentes ---"
    crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' || echo "(vazia)"
} | tee "$AUDIT_FILE"

RAM_LIVRE_MB=$(free -m | awk '/^Mem:/ {print $7}')
echo
if [[ "$RAM_LIVRE_MB" -lt 5120 ]]; then
    warn "RAM disponível: ${RAM_LIVRE_MB}MB (< 5GB). O servidor está carregado."
    warn "A Qolari corre na mesma, mas considera migrar para um CPX31 dedicado mais tarde."
fi

if [[ "${CONFIRM:-no}" != "yes" ]]; then
    echo
    log "Auditoria gravada em $AUDIT_FILE"
    log "Reve o relatório. Para prosseguir com a instalação, corre:"
    echo "  sudo CONFIRM=yes QOLARI_DB_PASSWORD='...' QOLARI_S3_KEY='...' \\"
    echo "       QOLARI_S3_SECRET='...' QOLARI_S3_BUCKET='...' bash provision.sh"
    exit 0
fi

# ============================================================================
# Pré-requisitos da fase de instalação
# ============================================================================
: "${QOLARI_DB_PASSWORD:?Define QOLARI_DB_PASSWORD (password da BD qolari)}"
: "${QOLARI_S3_KEY:?Define QOLARI_S3_KEY (Hetzner Object Storage)}"
: "${QOLARI_S3_SECRET:?Define QOLARI_S3_SECRET}"
: "${QOLARI_S3_BUCKET:?Define QOLARI_S3_BUCKET (bucket de backups)}"

log "FASE 1 — Instalação (isolada, tudo com o nome qolari)"

# ----------------------------------------------------------------------------
# 1) Pacotes base
# ----------------------------------------------------------------------------
log "1/9 — Pacotes base"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq software-properties-common curl git unzip ufw \
    logrotate cron ca-certificates gnupg s3cmd >/dev/null

# ----------------------------------------------------------------------------
# 2) PHP 8.3 + extensões (coexiste com PHPs antigos de outros projetos)
# ----------------------------------------------------------------------------
log "2/9 — PHP ${PHP_VERSION}-FPM"
if ! command -v php${PHP_VERSION} >/dev/null 2>&1 && ! php -v 2>/dev/null | grep -q "^PHP ${PHP_VERSION}"; then
    add-apt-repository -y ppa:ondrej/php >/dev/null
    apt-get update -qq
fi
apt-get install -y -qq \
    php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-redis php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml \
    php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-zip \
    php${PHP_VERSION}-bcmath php${PHP_VERSION}-intl php${PHP_VERSION}-opcache >/dev/null

if ! command -v composer >/dev/null 2>&1; then
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --quiet
fi

# ----------------------------------------------------------------------------
# 3) MySQL 8, Redis, Nginx, Node 22, Supervisor — SÓ se não existirem
# ----------------------------------------------------------------------------
log "3/9 — Serviços (instala só o que falta)"
command -v mysql >/dev/null 2>&1 || { apt-get install -y -qq mysql-server >/dev/null; }
command -v redis-server >/dev/null 2>&1 || { apt-get install -y -qq redis-server >/dev/null; }
command -v nginx >/dev/null 2>&1 || { apt-get install -y -qq nginx >/dev/null; }
command -v supervisord >/dev/null 2>&1 || command -v supervisorctl >/dev/null 2>&1 || { apt-get install -y -qq supervisor >/dev/null; }
if ! command -v node >/dev/null 2>&1 || [[ "$(node -v 2>/dev/null | cut -d. -f1 | tr -d v)" -lt 20 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >/dev/null
    apt-get install -y -qq nodejs >/dev/null
fi

# ----------------------------------------------------------------------------
# 4) Swap 4GB (só se não existir nenhum)
# ----------------------------------------------------------------------------
log "4/9 — Swap"
if [[ "$(swapon --show | wc -l)" -eq 0 ]]; then
    fallocate -l 4G /swapfile && chmod 600 /swapfile
    mkswap /swapfile >/dev/null && swapon /swapfile
    grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    log "Swap de 4GB criado."
else
    log "Swap já existe — nada a fazer."
fi

# ----------------------------------------------------------------------------
# 5) Utilizador da app + estrutura de releases (deploy com rollback)
# ----------------------------------------------------------------------------
log "5/9 — Utilizador ${APP_USER} e ${APP_DIR}"
id -u "$APP_USER" >/dev/null 2>&1 || useradd -r -m -d "$APP_DIR" -s /bin/bash "$APP_USER"
mkdir -p "$APP_DIR"/{releases,shared/storage,shared/.env.d} "$OPT_DIR"
chown -R "$APP_USER":"$APP_USER" "$APP_DIR"

# ----------------------------------------------------------------------------
# 6) Base de dados e utilizador MySQL próprios (só a BD "qolari")
# ----------------------------------------------------------------------------
log "6/9 — MySQL: BD ${DB_NAME} + user ${DB_USER}"
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${QOLARI_DB_PASSWORD}';"
mysql -e "ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${QOLARI_DB_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"

# Tuning CONSERVADOR (servidor partilhado). Se a auditoria mostrar RAM de
# sobra (>6GB livres) e os outros projetos o permitirem, subir o buffer pool.
cat > /etc/mysql/conf.d/90-qolari.cnf <<'EOF'
[mysqld]
innodb_buffer_pool_size = 1G        # subir para 2G se houver RAM livre
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
performance_schema = OFF
max_connections = 60
slow_query_log = 1
long_query_time = 1
EOF
systemctl restart mysql

# ----------------------------------------------------------------------------
# 7) PHP-FPM: pool dedicada "qolari" (socket próprio, user qolari) + OPcache
# ----------------------------------------------------------------------------
log "7/9 — Pool PHP-FPM qolari"
cat > /etc/php/${PHP_VERSION}/fpm/pool.d/qolari.conf <<EOF
[qolari]
user = ${APP_USER}
group = ${APP_USER}
listen = /run/php/php${PHP_VERSION}-fpm-qolari.sock
listen.owner = www-data
pm = dynamic
pm.max_children = 12
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 5
pm.max_requests = 500
php_admin_value[memory_limit] = 256M
EOF

cat > /etc/php/${PHP_VERSION}/fpm/conf.d/90-qolari-opcache.ini <<'EOF'
opcache.enable=1
opcache.memory_consumption=192
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000
opcache.validate_timestamps=0
EOF
systemctl reload php${PHP_VERSION}-fpm

# ----------------------------------------------------------------------------
# 8) Nginx: server blocks da Qolari (INATIVOS até o DNS estar apontado)
#    api.qolari.com  → Laravel (API + proxy de IA)
#    qolari.com      → Next.js (site + dashboard), standalone na porta 3000
# ----------------------------------------------------------------------------
log "8/9 — Nginx server blocks (templates inativos)"
cat > /etc/nginx/sites-available/qolari.conf.disabled <<EOF
# ATIVAR QUANDO O DNS DE ${DOMAIN} E ${API_DOMAIN} APONTAR A ESTE SERVIDOR:
#   1) mv qolari.conf.disabled qolari.conf
#   2) ln -s /etc/nginx/sites-available/qolari.conf /etc/nginx/sites-enabled/
#   3) nginx -t && systemctl reload nginx
#   4) certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} -d ${API_DOMAIN}

# --- API Laravel ---
server {
    listen 80;
    server_name ${API_DOMAIN};
    root ${APP_DIR}/current/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm-qolari.sock;
    }
    # Streaming SSE do proxy de IA: sem buffering SÓ nesta rota
    location /api/v1/chat {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm-qolari.sock;
        fastcgi_buffering off;
        fastcgi_read_timeout 300s;
        proxy_buffering off;
    }
    location ~ /\.(?!well-known).* { deny all; }
}

# --- Site + Dashboard Next.js (standalone, porta 3000, gerido pelo Supervisor) ---
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
warn "Nginx: template criado em sites-available/qolari.conf.disabled — INATIVO."
warn "Ativar quando o DNS de ${DOMAIN} e ${API_DOMAIN} apontar ao servidor."

# ----------------------------------------------------------------------------
# 9) Backups diários (SÓ a BD qolari) → Hetzner Object Storage
# ----------------------------------------------------------------------------
log "9/9 — Backups"
cat > "$OPT_DIR/backup.env" <<EOF
S3_KEY=${QOLARI_S3_KEY}
S3_SECRET=${QOLARI_S3_SECRET}
S3_BUCKET=${QOLARI_S3_BUCKET}
DB_PASSWORD=${QOLARI_DB_PASSWORD}
EOF
chmod 600 "$OPT_DIR/backup.env"

cat > "$OPT_DIR/backup.sh" <<'EOF'
#!/usr/bin/env bash
# Backup diário da BD qolari → Hetzner Object Storage. Retenção local: 7 dias.
set -euo pipefail
source /opt/qolari/backup.env
STAMP=$(date +%Y%m%d-%H%M%S)
FILE="/opt/qolari/backups/qolari-${STAMP}.sql.gz"
mkdir -p /opt/qolari/backups
MYSQL_PWD="$DB_PASSWORD" mysqldump --single-transaction --quick qolari | gzip > "$FILE"
s3cmd --access_key="$S3_KEY" --secret_key="$S3_SECRET" \
      --host=fsn1.your-objectstorage.com --host-bucket='%(bucket)s.fsn1.your-objectstorage.com' \
      put "$FILE" "s3://${S3_BUCKET}/mysql/"
find /opt/qolari/backups -name 'qolari-*.sql.gz' -mtime +7 -delete
# Retenção remota (30 dias): configurar lifecycle no bucket OU apagar aqui via s3cmd ls/del.
EOF
chmod 700 "$OPT_DIR/backup.sh"

# Cron diário às 03h17 (minuto fora da hora certa de propósito)
( crontab -l 2>/dev/null | grep -v 'qolari/backup.sh' ; echo "17 3 * * * $OPT_DIR/backup.sh >> /var/log/qolari-backup.log 2>&1" ) | crontab -

# Logrotate para logs da app
cat > /etc/logrotate.d/qolari <<EOF
${APP_DIR}/shared/storage/logs/*.log /var/log/qolari-*.log {
    daily
    rotate 14
    compress
    missingok
    notifempty
    copytruncate
}
EOF

echo
log "✔ Provisionamento concluído."
echo "  Próximos passos manuais:"
echo "   1) Guardar /opt/qolari/backup.env em local seguro (está chmod 600)"
echo "   2) Testar um backup:  sudo $OPT_DIR/backup.sh  (e confirmar no bucket)"
echo "   3) Testar um RESTORE de teste (backup que não restaura não é backup)"
echo "   4) Confirmar DNS de ${DOMAIN} e ${API_DOMAIN} → ativar server blocks → certbot"
echo "   5) Firewall (ufw): NÃO foi tocada (servidor partilhado). Rever à mão."
echo "  Seguinte: deploy do Laravel em ${APP_DIR}/releases (script deploy.sh — Fase 1)"
