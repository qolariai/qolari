#!/usr/bin/env bash
# Verificacao final pos-deploy do fecho da Fase 1
code() { curl -s -o /dev/null -w '%{http_code}' "$1"; }
echo "=== API (rotas reais /api/v1) ==="
echo "products:        $(code https://api.qolari.com/api/v1/products)"
echo "plans:           $(code https://api.qolari.com/api/v1/subscription-plans)"
echo "plans body:      $(curl -s https://api.qolari.com/api/v1/subscription-plans | head -c 120)"
echo "promo-code 404:  $(code https://api.qolari.com/api/v1/promo-codes/naoexiste)"
echo ""
echo "=== Compat extensao (/v1 via rewrite) ==="
echo "v1/products:     $(code https://api.qolari.com/v1/products)"
echo ""
echo "=== Webhook Stripe (sem assinatura -> 400 esperado) ==="
echo "webhook:         $(curl -s -o /dev/null -w '%{http_code}' -X POST https://api.qolari.com/api/v1/webhooks/stripe -H 'Content-Type: application/json' -d '{}')"
echo ""
echo "=== Frontend ==="
echo "home /pt:        $(code https://qolari.com/pt)"
echo "home /en:        $(code https://qolari.com/en)"
echo "pricing /pt:     $(code https://qolari.com/pt/pricing)"
echo "dashboard/chat:  $(code https://qolari.com/pt/dashboard/chat)"
echo "marketplace:     $(code https://qolari.com/pt/marketplace)"
echo "admin (302):     $(code https://api.qolari.com/admin)"
echo ""
echo "=== Servicos ==="
supervisorctl status | head -4
echo ""
echo "=== Erros novos no laravel.log apos deploy ==="
grep -c 'ERROR' /var/www/qolari/api/storage/logs/laravel.log 2>/dev/null || echo 0
date -u
