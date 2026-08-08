<?php

namespace App\Domain\Billing;

use App\Models\ExchangeRate;
use App\Models\Order;
use App\Models\PaymentEvent;
use App\Models\Product;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * AppyPay — gateway angolana (Multicaixa Express / GPO, Pagamento por
 * Referência, UNITEL Money). Aqui só o fluxo GPO (Multicaixa Express):
 * cobrança iniciada pelo comerciante, confirmada pelo cliente na app
 * Multicaixa Express, e confirmada ao servidor via webhook assinado.
 *
 * Contrato (v2.0):
 *  - Auth: POST {auth_url} form(client_credentials) → access_token (Azure AD)
 *  - Cobrança: POST {base_url}/charges, Bearer token,
 *    paymentMethod = "GPO_{api_key}", paymentInfo.phoneNumber
 *  - Webhook: POST callback_url, assinatura HMAC-SHA256 no header
 *    X-AppyPay-Signature com o webhook_secret partilhado.
 */
class AppyPayService
{
    public function __construct(
        private OrderFulfillmentService $fulfillment,
    ) {
    }

    /**
     * Cria a order pendente (gateway=appypay) e dispara a cobrança GPO
     * para o telemóvel do cliente. A confirmação chega via webhook.
     *
     * @return array{order: Order, charge_id: string|null, status: string}
     */
    public function createCheckout(Product $product, string $currency, User $user, string $phone, ?int $promoCodeId = null): array
    {
        $currency = strtoupper($currency);
        if ($currency !== 'AOA') {
            throw new \InvalidArgumentException("AppyPay so suporta AOA, recebido: {$currency}");
        }

        $price = $product->priceFor('AOA');
        if (!$price) {
            throw new \InvalidArgumentException('Sem preco para a moeda: AOA');
        }

        $rate = ExchangeRate::find('AOA');
        $rateToUsd = $rate ? (float) $rate->rate_to_usd : 0.0;
        $amountUsd = round((float) $price->price * $rateToUsd, 2);

        $order = Order::create([
            'user_id' => $user->id,
            'product_id' => $product->id,
            'currency' => 'AOA',
            'amount' => $price->price,
            'exchange_rate_used' => $rateToUsd,
            'amount_usd' => $amountUsd,
            'gateway' => 'appypay',
            'status' => 'pending',
            'promo_code_id' => $promoCodeId,
            'idempotency_key' => Str::uuid()->toString(),
            'fulfillment_status' => 'pending',
        ]);

        $merchantTxId = $this->merchantTransactionId($order->id);

        $response = Http::withToken($this->accessToken())
            ->accept('application/vnd.appypay.asyncapi+json')
            ->withHeaders(['X-AppyPay-Callback' => 'true'])
            ->timeout(30)
            ->post($this->config('base_url') . '/charges', [
                'amount' => number_format((float) $price->price, 2, '.', ''),
                'currency' => 'AOA',
                'description' => "Qolari — {$product->name}",
                'merchantTransactionId' => $merchantTxId,
                'paymentMethod' => 'GPO_' . $this->config('api_key'),
                'paymentInfo' => ['phoneNumber' => $phone],
                'notify' => [
                    'name' => $user->name,
                    'telephone' => $phone,
                    'email' => $user->email,
                    'smsNotification' => false,
                    'emailNotification' => false,
                ],
                'callback_url' => route('webhooks.appypay'),
            ]);

        $body = $response->json() ?? [];

        if ($response->failed() || !isset($body['id'])) {
            Log::error('AppyPay: falha ao criar cobrança.', [
                'order_id' => $order->id,
                'status' => $response->status(),
                'body' => $body,
            ]);
            $order->update(['status' => 'failed']);
            throw new \RuntimeException($body['message'] ?? 'Falha ao iniciar pagamento Multicaixa Express.');
        }

        $order->update(['gateway_reference' => (string) $body['id']]);

        $status = (string) ($body['responseStatus']['status'] ?? 'Pending');

        // Recusa imediata (ex.: número não registado no Multicaixa Express)
        if ($status === 'Failed') {
            $order->update(['status' => 'failed']);
        }

        return [
            'order' => $order,
            'charge_id' => (string) $body['id'],
            'status' => $status,
        ];
    }

    /**
     * Webhook AppyPay: valida assinatura HMAC-SHA256, regista o evento
     * com idempotência e faz fulfillment quando status=Success.
     */
    public function handleWebhook(string $payload, ?string $signature): void
    {
        $secret = $this->config('webhook_secret');
        if (!$secret) {
            throw new \RuntimeException('AppyPay webhook_secret não configurado.');
        }

        $computed = hash_hmac('sha256', $payload, $secret);
        if (!$signature || !hash_equals($computed, $signature)) {
            throw new \InvalidArgumentException('Assinatura de webhook inválida.');
        }

        $data = json_decode($payload, true);
        if (!is_array($data) || empty($data['id'])) {
            throw new \InvalidArgumentException('Payload de webhook inválido.');
        }

        $chargeId = (string) $data['id'];
        $status = (string) ($data['responseStatus']['status'] ?? $data['status'] ?? 'Unknown');

        // Idempotencia: charge id + status (a mesma transição nunca repete)
        $eventId = "appypay-{$chargeId}-{$status}";
        if (PaymentEvent::where('gateway_event_id', $eventId)->exists()) {
            return;
        }

        $order = $this->findOrder($chargeId, $data['merchantTransactionId'] ?? null);

        PaymentEvent::create([
            'order_id' => $order?->id,
            'gateway' => 'appypay',
            'gateway_event_id' => $eventId,
            'gateway_payment_id' => $chargeId,
            'event_type' => "charge.{$status}",
            'payload' => $data,
            'processed_at' => now(),
            'created_at' => now(),
        ]);

        if (!$order) {
            Log::warning('AppyPay webhook: order não encontrada.', ['charge_id' => $chargeId]);
            return;
        }

        match ($status) {
            'Success' => $this->fulfillment->fulfill($order->id),
            'Failed', 'Expired' => $order->status === 'pending' ? $order->update(['status' => 'failed']) : null,
            default => null, // Pending/outros: só registar
        };
    }

    /**
     * Normaliza telemóvel angolano: aceita "+244 9XX XXX XXX" e devolve
     * "9XXXXXXXX". Devolve null se inválido.
     */
    public static function normalizePhone(string $phone): ?string
    {
        $digits = preg_replace('/\D+/', '', $phone) ?? '';
        if (str_starts_with($digits, '244') && strlen($digits) === 12) {
            $digits = substr($digits, 3);
        }

        return preg_match('/^9\d{8}$/', $digits) === 1 ? $digits : null;
    }

    private function findOrder(string $chargeId, ?string $merchantTxId): ?Order
    {
        $order = Order::where('gateway', 'appypay')
            ->where('gateway_reference', $chargeId)
            ->first();
        if ($order) {
            return $order;
        }

        // Fallback: merchantTransactionId = "Q{orderId}{random}"
        if ($merchantTxId && preg_match('/^Q(\d+)/', $merchantTxId, $m) === 1) {
            return Order::where('gateway', 'appypay')->find((int) $m[1]);
        }

        return null;
    }

    /**
     * GPO limita merchantTransactionId a 15 caracteres:
     * "Q" + order id + 6 hex aleatórios (ex.: Q123A4B5C6).
     */
    private function merchantTransactionId(int $orderId): string
    {
        return substr('Q' . $orderId . strtoupper(bin2hex(random_bytes(4))), 0, 15);
    }

    private function accessToken(): string
    {
        return Cache::remember('appypay_access_token', 3000, function () {
            $response = Http::asForm()->acceptJson()->timeout(15)
                ->post($this->config('auth_url'), [
                    'grant_type' => 'client_credentials',
                    'client_id' => $this->config('client_id'),
                    'client_secret' => $this->config('client_secret'),
                    'resource' => $this->config('resource'),
                ]);

            $token = $response->json('access_token');
            if ($response->failed() || !$token) {
                Log::error('AppyPay: falha ao obter access token.', ['body' => $response->json()]);
                throw new \RuntimeException('Falha na autenticação com a AppyPay.');
            }

            return $token;
        });
    }

    private function config(string $key): ?string
    {
        // Credenciais editáveis no admin (Setting encriptada) com fallback env/config
        static $map = [
            'client_id' => 'appypay_client_id',
            'client_secret' => 'appypay_client_secret',
            'resource' => 'appypay_resource',
            'api_key' => 'appypay_api_key',
            'webhook_secret' => 'appypay_webhook_secret',
        ];

        $settingKey = $map[$key] ?? null;
        if ($settingKey) {
            $value = Setting::get($settingKey);
            if ($value) {
                return $value;
            }
        }

        return config("services.appypay.{$key}");
    }
}
