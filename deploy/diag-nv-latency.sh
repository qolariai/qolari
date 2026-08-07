#!/usr/bin/env bash
# Mede tempo ate 1º chunk (TTFB) e total por modelo NVIDIA, prompt curto.
KEY=$(grep '^NVIDIA_API_KEY=' /var/www/qolari/api/.env | cut -d= -f2)

medir() {
  local modelo=$1
  local inicio=$(date +%s.%N)
  local primeiro=""
  local total_bytes=0
  while IFS= read -r linha; do
    total_bytes=$((total_bytes + ${#linha}))
    if [ -z "$primeiro" ] && [[ "$linha" == data:* ]]; then
      primeiro=$(echo "scale=2; ($(date +%s.%N) - $inicio) / 1" | bc)
    fi
  done < <(curl -s --max-time 40 https://integrate.api.nvidia.com/v1/chat/completions \
    -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
    -d "{\"model\":\"$modelo\",\"stream\":true,\"messages\":[{\"role\":\"user\",\"content\":\"Diz apenas: ola\"}],\"max_tokens\":20}")
  local total=$(echo "scale=2; ($(date +%s.%N) - $inicio) / 1" | bc)
  echo "$modelo | 1ºchunk=${primeiro:-ERR} total=${total} bytes=${total_bytes}"
}

medir "meta/llama-3.1-8b-instruct"
medir "nvidia/llama-3.1-nemotron-nano-8b-v1"
medir "mistralai/mistral-7b-instruct-v0.3"
medir "nvidia/llama-3.3-nemotron-super-49b-v1.5"
medir "meta/llama-3.1-70b-instruct"
medir "meta/llama-3.3-70b-instruct"
