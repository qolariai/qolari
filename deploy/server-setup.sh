#!/usr/bin/env bash
# ============================================================================
# QOLARI — Setup completo no servidor Hetzner
# Domínio principal: qolari.com (SSL já activo via Certbot)
#
# Arquitectura:
#   qolari.com/*        → Next.js standalone (porta 3000)
#   qolari.com/api/*    → Laravel (PHP-FPM)
#   qolari.com/admin/*  → Laravel Filament (PHP-FPM)
#   qolari.com/storage/* → Laravel ficheiros públicos
# ============================================================================
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

APP_DIR="/var/www/qolari"
API_DIR="$APP_DIR/api"
FRONTEND_DIR="$APP_DIR/frontend"
PHP_VERSION="8.3"
DB_NAME="qolari"
DB_USER="qolari"
DB_PASS="Qolari2026Hetzner"
DOMAIN="qolari.com"
REPO="https://github.com/qolariai/qolari.git"

log() { echo -e "\033[1;34m[qolari]\033[0m $*"; }

# ----------------------------------------------------------------------------
# 1) Instalar o que falta
# ----------------------------------------------------------------------------
log "1/7 — Pacotes em falta"

# Redis
if ! command -v redis-server >/dev/null 2>&1; then
    apt-get install -y -qq redis-server >/dev/null
    systemctl enable redis-server
    systemctl start redis-server
    log "Redis instalado."
fi

# Node.js 22
if ! command -v node >/dev/null 2>&1; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >/dev/null 2>&1
    apt-get install -y -qq nodejs >/dev/null
    log "Node.js $(node -v) instalado."
fi

# Composer
if ! command -v composer >/dev/null 2>&1; then
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --quiet
    log "Composer instalado."
fi

# PHP extensions (garantir que estão todas)
apt-get install -y -qq \
    php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-redis php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml \
    php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-zip \
    php${PHP_VERSION}-bcmath php${PHP_VERSION}-intl php${PHP_VERSION}-opcache >/dev/null

# Supervisor
if ! command -v supervisord >/dev/null 2>&1; then
    apt-get install -y -qq supervisor >/dev/null
fi

# Git (garantir)
command -v git >/dev/null 2>&1 || apt-get install -y -qq git >/dev/null

log "Pacotes OK."

# ----------------------------------------------------------------------------
# 2) MySQL: base de dados + utilizador
# ----------------------------------------------------------------------------
log "2/7 — MySQL"
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"
log "BD '${DB_NAME}' pronta."

# ----------------------------------------------------------------------------
# 3) Clonar/pull o código do GitHub
# ----------------------------------------------------------------------------
log "3/7 — Código fonte"
mkdir -p "$APP_DIR"

# Usar token via env para clone privado (passar: GITHUB_TOKEN=xxx bash server-setup.sh)
CLONE_URL="$REPO"
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    CLONE_URL="https://${GITHUB_TOKEN}@github.com/qolariai/qolari.git"
fi

if [[ -d "$API_DIR/.git" ]]; then
    cd "$API_DIR"
    git fetch origin
    git reset --hard origin/master
    log "Código actualizado (pull)."
else
    # Primeira vez: clonar para tmp e mover
    rm -rf /tmp/qolari-clone
    git clone --depth 1 "$CLONE_URL" /tmp/qolari-clone
    # O Laravel fica na raiz do repo
    rm -rf "$API_DIR"
    mv /tmp/qolari-clone "$API_DIR"
    # A pasta frontend/ dentro do repo é o Next.js
    mv "$API_DIR/frontend" "$FRONTEND_DIR"
    rm -rf /tmp/qolari-clone
    log "Código clonado."
fi

# Garantir que frontend está separado
if [[ -d "$API_DIR/frontend" && ! -d "$FRONTEND_DIR" ]]; then
    mv "$API_DIR/frontend" "$FRONTEND_DIR"
fi

chown -R www-data:www-data "$APP_DIR"

# ----------------------------------------------------------------------------
# 4) Laravel: composer + .env + migrate + cache
# ----------------------------------------------------------------------------
log "4/7 — Laravel setup"
cd "$API_DIR"

composer install --no-dev --optimize-autoloader --no-interaction --quiet 2>/dev/null || \
    composer install --no-dev --optimize-autoloader --no-interaction

# .env de produção
APP_KEY=$(php artisan key:generate --show 2>/dev/null || openssl rand -base64 32)
cat > "$API_DIR/.env" <<EOF
APP_NAME=Qolari
APP_ENV=production
APP_KEY=base64:${APP_KEY}
APP_DEBUG=false
APP_URL=https://${DOMAIN}

APP_LOCALE=pt
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=pt_PT

LOG_CHANNEL=stack
LOG_STACK=single
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASS}

SESSION_DRIVER=redis
SESSION_LIFETIME=120
SESSION_DOMAIN=.${DOMAIN}

CACHE_STORE=redis
QUEUE_CONNECTION=redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

FILESYSTEM_DISK=local
MAIL_MAILER=log

SANCTUM_STATEFUL_DOMAINS=
EOF

# Permissões storage
mkdir -p "$API_DIR/storage/logs" "$API_DIR/storage/app" "$API_DIR/storage/framework/cache" "$API_DIR/storage/framework/sessions" "$API_DIR/storage/framework/views"
chown -R www-data:www-data "$API_DIR/storage" "$API_DIR/bootstrap/cache"
chmod -R 775 "$API_DIR/storage" "$API_DIR/bootstrap/cache"

# Migrations + seed
php artisan migrate --force --no-interaction
php artisan db:seed --force --no-interaction 2>/dev/null || true

# Caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

log "Laravel pronto."

# ----------------------------------------------------------------------------
# 5) Next.js: build standalone
# ----------------------------------------------------------------------------
log "5/7 — Next.js build"
cd "$FRONTEND_DIR"

# .env.local para o build
cat > "$FRONTEND_DIR/.env.local" <<EOF
NEXT_PUBLIC_API_URL=https://${DOMAIN}/api/v1
NEXT_PUBLIC_APP_URL=https://${DOMAIN}
EOF

npm install --legacy-peer-deps 2>/dev/null || npm install
npm run build

# Standalone: copiar static e public para o output standalone
cp -r "$FRONTEND_DIR/.next/static" "$FRONTEND_DIR/.next/standalone/.next/static" 2>/dev/null || true
cp -r "$FRONTEND_DIR/public" "$FRONTEND_DIR/.next/standalone/public" 2>/dev/null || true

log "Next.js build concluído."

# ----------------------------------------------------------------------------
# 6) PHP-FPM pool + Nginx
# ----------------------------------------------------------------------------
log "6/7 — Nginx + PHP-FPM"

# Pool PHP-FPM dedicada
cat > /etc/php/${PHP_VERSION}/fpm/pool.d/qolari.conf <<EOF
[qolari]
user = www-data
group = www-data
listen = /run/php/php${PHP_VERSION}-fpm-qolari.sock
listen.owner = www-data
pm = dynamic
pm.max_children = 10
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 5
pm.max_requests = 500
php_admin_value[memory_limit] = 256M
EOF

systemctl reload php${PHP_VERSION}-fpm

# Nginx: qolari.com com Laravel API + Next.js
cat > /etc/nginx/sites-available/qolari <<'NGINX'
server {
    listen 80;
    listen [::]:80;
    server_name qolari.com www.qolari.com;
    return 301 https://qolari.com$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name qolari.com www.qolari.com;

    ssl_certificate /etc/letsencrypt/live/qolari.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/qolari.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /var/www/qolari/api/public;
    index index.php;

    client_max_body_size 50M;

    # --- Laravel: ficheiros estáticos do public/ ---
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt { access_log off; log_not_found off; }

    # --- Laravel API (rotas /api/v1/*) ---
    location /api {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # --- Laravel Filament Admin (/admin) ---
    location /admin {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # --- Laravel Storage (ficheiros públicos) ---
    location /storage {
        try_files $uri $uri/ =404;
    }

    # --- Laravel assets (css/js/fonts do Filament) ---
    location ~* ^/(css|js|fonts)/ {
        try_files $uri =404;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # --- PHP-FPM (front controller Laravel) ---
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.3-fpm-qolari.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 300;
        fastcgi_buffering off;
    }

    # --- Negar acesso a ficheiros ocultos ---
    location ~ /\.(?!well-known).* {
        deny all;
    }

    # --- Next.js (tudo o resto → porta 3000) ---
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
NGINX

# Activar site
ln -sf /etc/nginx/sites-available/qolari /etc/nginx/sites-enabled/qolari
nginx -t && systemctl reload nginx
log "Nginx configurado."

# ----------------------------------------------------------------------------
# 7) Supervisor: Next.js + Horizon (queue)
# ----------------------------------------------------------------------------
log "7/7 — Supervisor"

cat > /etc/supervisor/conf.d/qolari-nextjs.conf <<EOF
[program:qolari-nextjs]
command=node ${FRONTEND_DIR}/.next/standalone/server.js
directory=${FRONTEND_DIR}/.next/standalone
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
environment=NODE_ENV=production,PORT=3000,HOSTNAME=127.0.0.1
stdout_logfile=/var/log/qolari-nextjs.log
stderr_logfile=/var/log/qolari-nextjs-error.log
EOF

cat > /etc/supervisor/conf.d/qolari-horizon.conf <<EOF
[program:qolari-horizon]
command=php ${API_DIR}/artisan horizon
directory=${API_DIR}
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
stdout_logfile=/var/log/qolari-horizon.log
stderr_logfile=/var/log/qolari-horizon-error.log
EOF

# Fallback: se Horizon não estiver instalado, usar queue:work
if ! php "$API_DIR/artisan" horizon:status >/dev/null 2>&1; then
    cat > /etc/supervisor/conf.d/qolari-horizon.conf <<EOF
[program:qolari-queue]
command=php ${API_DIR}/artisan queue:work redis --sleep=3 --tries=3
directory=${API_DIR}
autostart=true
autorestart=true
user=www-data
stdout_logfile=/var/log/qolari-queue.log
stderr_logfile=/var/log/qolari-queue-error.log
EOF
fi

supervisorctl reread
supervisorctl update
supervisorctl restart all 2>/dev/null || true

log "Supervisor configurado."

echo
log "✔ SETUP COMPLETO!"
echo "  qolari.com       → Next.js (frontend)"
echo "  qolari.com/api/* → Laravel (API REST)"
echo "  qolari.com/admin → Filament (painel admin)"
echo
echo "  Verificar: curl -I https://qolari.com"
echo "  Logs: tail -f /var/log/qolari-*.log"
