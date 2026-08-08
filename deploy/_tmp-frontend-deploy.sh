#!/usr/bin/env bash
# Deploy frontend: sync do repo fresco -> /var/www/qolari/frontend + build + restart
set -euo pipefail
cd /var/www/qolari/api

echo "=== 1) git update (api clone serve de fonte) ==="
git fetch --depth 1 origin master -q
git reset --hard origin/master -q
git log -1 --oneline

echo ""
echo "=== 2) sync frontend (preserva node_modules, .next, .env.local) ==="
rsync -a --delete \
  --exclude node_modules --exclude .next --exclude .env.local \
  /var/www/qolari/api/frontend/ /var/www/qolari/frontend/
echo "synced"

echo ""
echo "=== 3) build Next.js ==="
cd /var/www/qolari/frontend
npm run build 2>&1 | tail -6
cp -r .next/static .next/standalone/.next/static
cp -r public .next/standalone/public

echo ""
echo "=== 4) restart ==="
chown -R www-data:www-data /var/www/qolari/frontend/.next
supervisorctl restart qolari-nextjs
sleep 3
supervisorctl status qolari-nextjs

echo ""
echo "=== 5) verificacao ==="
echo "landing /pt: $(curl -s -o /dev/null -w '%{http_code}' https://qolari.com/pt)"
echo "download win: $(curl -s -o /dev/null -w '%{http_code} %{size_download}B' -r 0-0 https://qolari.com/downloads/qolari-ide-win-x64.exe)"
curl -s https://qolari.com/pt | grep -o 'Descarregar o Qolari IDE\|/downloads/qolari-ide-win-x64.exe' | sort -u
date -u
