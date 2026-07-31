<?php

namespace App\Domain\Billing;

use App\Domain\Wallet\WalletService;
use App\Models\Commission;
use App\Models\ExchangeRate;
use App\Models\Order;
use App\Models\PaymentEvent;
use App\Models\Product;
use App\Models\Setting;
use Illuminate\Support\Str;
use Stripe\Checkout\Session;
use Stripe\Stripe;
use Stripe\Webhook;

class StripeService
{
    public function __construct(
        private WalletService $walletService,
    ) {
        $secret = Setting::get('stripe_secret_key') ?? config('services.stripe.secret');
        if ($secret) {
            Stripe::setApiKey($secret);
        }
    }

    /**
     * Cria uma ordem pendente e uma Stripe Checkout Session.
     */
    public function createCheckout(Product $product, string $currency, int $userId, ?int $promoCodeId = null): array
    {
        $price = $product->priceFor(strtoupper($currency));
        if (!$price) {
            throw new \InvalidArgumentException("Sem preco para a moeda: {$currency}");
        }

        $rate = ExchangeRate::find(strtoupper($currency));
        $rateToUsd = $rate ? (float) $rate->rate_to_usd : 1.0;
        $amountUsd = round((float) $price->price * $rateToUsd, 2);

        $order = Order::create([
            'user_id' => $userId,
            'product_id' => $product->id,
            'currency' => strtoupper($currency),
            'amount' => $price->price,
            'exchange_rate_used' => $rateToUsd,
            'amount_usd' => $amountUsd,
            'gateway' => 'stripe',
            'status' => 'pending',
            'promo_code_id' => $promoCodeId,
            'idempotency_key' => Str::uuid()->toString(),
            'fulfillment_status' => 'pending',
        ]);

        $session = Session::create([
            'mode' => 'payment',
            'line_items' => [[
                'price_data' => [
                    'currency' => strtolower($currency),
                    'unit_amount' => (int) round((float) $price->price * 100),
                    'product_data' => [
                        'name' => $product->name,
                        'description' => $product->description ?? "Pacote de creditos Qolari",
                    ],
                ],
                'quantity' => 1,
            ]],
            'success_url' => config('app.frontend_url', config('app.url')) . '/dashboard?checkout=success',
            'cancel_url' => config('app.frontend_url', config('app.url')) . '/pricing?checkout=cancelled',
            'metadata' => [
                'order_id' => $order->id,
            ],
        ]);

        return [
            'order' => $order,
            'checkout_url' => $session->url,
            'session_id' => $session->id,
        ];
    }

    /**
     * Processa webhook da Stripe com idempotencia.
     */
    public function handleWebhook(string $payload, string $signature): void
    {
        $webhookSecret = Setting::get('stripe_webhook_secret') ?? config('services.stripe.webhook_secret');
        $event = Webhook::constructEvent($payload, $signature, $webhookSecret);

        // Idempotencia: nunca processar o mesmo evento 2x
        $exists = PaymentEvent::where('gateway_event_id', $event->id)->exists();
        if ($exists) {
            return;
        }

        $orderId = $event->data->object->metadata->order_id ?? null;

        // Regista o evento
        PaymentEvent::create([
            'order_id' => $orderId,
            'gateway' => 'stripe',
            'gateway_event_id' => $event->id,
            'gateway_payment_id' => $event->data->object->payment_intent ?? null,
            'event_type' => $event->type,
            'payload' => json_decode($payload, true),
            'processed_at' => now(),
            'created_at' => now(),
        ]);

        match ($event->type) {
            'checkout.session.completed' => $this->fulfillOrder($orderId),
            default => null, // outros eventos: so registar
        };
    }

    /**
     * Marca order como paga, credita wallet, cria comissao se aplicavel.
     */
    private function fulfillOrder(?int $orderId): void
    {
        if (!$orderId) {
            return;
        }

        $order = Order::find($orderId);
        if (!$order || $order->status === 'paid') {
            return;
        }

        $order->update(['status' => 'paid', 'fulfillment_status' => 'delivered']);

        $product = $order->product;

        // Credita a wallet (valor facial em USD do pacote)
        $this->walletService->credit(
            userId: $order->user_id,
            aiModelId: $product->ai_model_id,
            amountUsd: (float) $product->credits_usd,
            orderId: $order->id,
            type: 'purchase',
            idempotencyKey: "order-{$order->id}-credit",
        );

        // Comissao de influenciador
        if ($order->promo_code_id) {
            $promo = $order->promoCode;
            if ($promo && $promo->is_active) {
                $commissionAmount = round((float) $order->amount_usd * ((float) $promo->commission_percent / 100), 2);
                Commission::create([
                    'promo_code_id' => $promo->id,
                    'order_id' => $order->id,
                    'amount_usd' => $commissionAmount,
                    'status' => 'pending',
                ]);
            }
        }
    }
}
