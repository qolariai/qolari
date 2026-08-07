#!/usr/bin/env bash
# Diagnostico: NVIDIA streaming com/sem stream_options.include_usage
KEY=$(grep '^NVIDIA_API_KEY=' /var/www/qolari/api/.env | cut -d= -f2)

echo "=== COM stream_options ==="
curl -s --max-time 45 -o /tmp/nv1.txt -w 'http=%{http_code} bytes=%{size_download}\n' \
  https://integrate.api.nvidia.com/v1/chat/completions \
  -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  -d '{"model":"meta/llama-3.1-8b-instruct","stream":true,"stream_options":{"include_usage":true},"messages":[{"role":"user","content":"Diz ola"}],"max_tokens":30}'
head -c 300 /tmp/nv1.txt; echo

echo "=== SEM stream_options ==="
curl -s --max-time 45 -o /tmp/nv2.txt -w 'http=%{http_code} bytes=%{size_download}\n' \
  https://integrate.api.nvidia.com/v1/chat/completions \
  -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  -d '{"model":"meta/llama-3.1-8b-instruct","stream":true,"messages":[{"role":"user","content":"Diz ola"}],"max_tokens":30}'
head -c 300 /tmp/nv2.txt; echo

echo "=== cauda (fim do stream SEM stream_options) ==="
tail -c 300 /tmp/nv2.txt
