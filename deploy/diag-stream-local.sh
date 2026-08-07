#!/usr/bin/env bash
# Isolar o problema de streaming: artisan serve (sem nginx/FPM) vs producao
cd /var/www/qolari/api

pkill -f 'artisan serve' 2>/dev/null
nohup php artisan serve --host=127.0.0.1 --port=8010 > /tmp/qolari-serve.log 2>&1 &
sleep 3

TOKEN=$(curl -s -X POST http://127.0.0.1:8010/api/v1/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"deco@qolari.com","password":"Qolari2026Teste"}' \
  | php -r '$d=json_decode(stream_get_contents(STDIN),true); echo $d["token"]??"";')
echo "token: ${TOKEN:0:8}..."

echo "=== streaming via artisan serve (8010) ==="
curl -s --max-time 60 -o /tmp/stream-local.txt \
  -w 'http=%{http_code} bytes=%{size_download} tempo=%{time_total}s\n' \
  -X POST http://127.0.0.1:8010/api/v1/chat/completions \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"model":"nexus-low","stream":true,"messages":[{"role":"user","content":"Diz ola"}],"max_tokens":30}'
head -c 200 /tmp/stream-local.txt; echo

echo "=== output_buffering do FPM ==="
php -r 'echo "cli output_buffering: ".ini_get("output_buffering").PHP_EOL;'
php-fpm8.3 -i 2>/dev/null | grep -m2 'output_buffering' || true

pkill -f 'artisan serve' 2>/dev/null
echo FIM
