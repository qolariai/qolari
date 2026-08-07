<?php

namespace App\Domain\Billing;

use App\Domain\Wallet\WalletService;
use App\Models\Commission;
use App\Models\ExchangeRate;
use App\Models\Order;
use App\Models\PaymentEvent;
use App\Models\Product;
use App\Models\Setting;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Stripe\Checkout\Session;
use Stripe\Customer;
use Stripe\Stripe;
use Stripe\Subscription as StripeSubscription;
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
     * Cria a subscrição pendente e uma Stripe Checkout Session (mode subscription).
     * Padrão idêntico ao createCheckout: registo local primeiro, webhook confirma.
     *
     * @return array{subscription: Subscription, checkout_url: string, session_id: string}
     */
    public function createSubscriptionCheckout(User $user, SubscriptionPlan $plan, string $currency): array
    {
        $currency = strtoupper($currency);
        $price = $plan->priceFor($currency);
        if (!$price) {
            throw new \InvalidArgumentException("Sem preco para a moeda: {$currency}");
        }
        if (!$plan->stripe_price_id) {
            throw new \InvalidArgumentException('Plano sem stripe_price_id configurado.');
        }

        // Subscrição local em estado incomplete — o webhook ativa-a
        $subscription = Subscription::create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'status' => 'incomplete',
            'tokens_used' => 0,
        ]);

        // Cliente Stripe: reutiliza o de uma subscrição anterior do user, senão cria
        $stripeCustomerId = Subscription::where('user_id', $user->id)
            ->whereNotNull('stripe_customer_id')
            ->latest('id')
            ->value('stripe_customer_id');

        if (!$stripeCustomerId) {
            $customer = Customer::create([
                'email' => $user->email,
                'name' => $user->name,
                'metadata' => ['user_id' => $user->id],
            ]);
            $stripeCustomerId = $customer->id;
        }

        $subscription->update(['stripe_customer_id' => $stripeCustomerId]);

        $session = Session::create([
            'mode' => 'subscription',
            'client_reference_id' => (string) $user->id,
            'customer' => $stripeCustomerId,
            'line_items' => [[
                'price' => $plan->stripe_price_id,
                'quantity' => 1,
            ]],
            'success_url' => config('app.frontend_url', config('app.url')) . '/dashboard?checkout=success',
            'cancel_url' => config('app.frontend_url', config('app.url')) . '/pricing?checkout=cancelled',
            'metadata' => [
                'subscription_id' => $subscription->id,
                'user_id' => $user->id,
            ],
            'subscription_data' => [
                'metadata' => ['subscription_id' => $subscription->id],
            ],
        ]);

        return [
            'subscription' => $subscription,
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
            'checkout.session.completed' => $this->handleCheckoutCompleted($event, $orderId),
            'customer.subscription.updated' => $this->syncSubscription($event),
            'customer.subscription.deleted' => $this->markSubscriptionDeleted($event),
            'invoice.payment_failed' => $this->markSubscriptionPastDue($event),
            default => null, // outros eventos: so registar
        };
    }

    /**
     * checkout.session.completed: mode payment → fulfillOrder (créditos Code);
     * mode subscription → ativa a subscrição Chat.
     */
    private function handleCheckoutCompleted(\Stripe\Event $event, ?int $orderId): void
    {
        $session = $event->data->object;

        if (($session->mode ?? null) !== 'subscription') {
            $this->fulfillOrder($orderId);
            return;
        }

        $subscription = $this->findSubscriptionFromSession($session);
        if (!$subscription) {
            Log::warning('Webhook subscription: subscrição local não encontrada.', [
                'session_id' => $session->id ?? null,
            ]);
            return;
        }

        // Idempotência defensiva: já ativada por outro evento
        if (in_array($subscription->status, ['active', 'trialing'], true)) {
            return;
        }

        $stripeSubscriptionId = $session->subscription ?? null;

        $subscription->update([
            'stripe_subscription_id' => $stripeSubscriptionId,
            'status' => 'active',
            'tokens_used' => 0,
            'cancel_at_period_end' => false,
        ]);

        // Datas reais do período: da Stripe quando possível, senão deriva do plano
        $stripeSubscription = $this->syncPeriodFromStripe($subscription, $stripeSubscriptionId);

        // Checkout de trial: a Stripe reporta a subscription já em 'trialing'
        if ($stripeSubscription && ($stripeSubscription->status ?? null) === 'trialing') {
            $subscription->update(['status' => 'trialing']);
        }
    }

    /**
     * Localiza a subscrição local a partir da Checkout Session
     * (metadata.subscription_id → fallback: client_reference_id + incomplete).
     */
    private function findSubscriptionFromSession(object $session): ?Subscription
    {
        $subscriptionId = $session->metadata->subscription_id ?? null;
        if ($subscriptionId) {
            return Subscription::find((int) $subscriptionId);
        }

        $userId = $session->client_reference_id ?? ($session->metadata->user_id ?? null);
        if (!$userId) {
            return null;
        }

        return Subscription::where('user_id', (int) $userId)
            ->whereIn('status', ['incomplete', 'incomplete_expired'])
            ->latest('id')
            ->first();
    }

    /**
     * Busca a subscription na Stripe para sincronizar datas do período.
     * Falhas são toleradas: deriva do period_days do plano.
     * Devolve o objeto Stripe quando o retrieve teve sucesso.
     */
    private function syncPeriodFromStripe(Subscription $subscription, ?string $stripeSubscriptionId): ?StripeSubscription
    {
        $stripeSubscription = null;

        if ($stripeSubscriptionId && Stripe::getApiKey()) {
            try {
                $stripeSubscription = StripeSubscription::retrieve($stripeSubscriptionId);
            } catch (\Throwable $e) {
                Log::warning('Webhook subscription: retrieve na Stripe falhou.', [
                    'subscription_id' => $subscription->id,
                    'stripe_subscription_id' => $stripeSubscriptionId,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        $start = $stripeSubscription?->current_period_start ?? null;
        $end = $stripeSubscription?->current_period_end ?? null;

        if ($start && $end) {
            $subscription->update([
                'current_period_start' => now()->setTimestamp((int) $start),
                'current_period_end' => now()->setTimestamp((int) $end),
            ]);
            return $stripeSubscription;
        }

        $periodDays = $subscription->plan?->period_days ?? 30;
        $subscription->update([
            'current_period_start' => now(),
            'current_period_end' => now()->addDays($periodDays),
        ]);

        return $stripeSubscription;
    }

    /**
     * customer.subscription.updated → sincroniza status/período/cancel_at_period_end.
     */
    private function syncSubscription(\Stripe\Event $event): void
    {
        $object = $event->data->object;
        $subscription = Subscription::where('stripe_subscription_id', $object->id ?? null)->first();
        if (!$subscription) {
            return;
        }

        $updates = [];

        // 'incomplete' é transitório (pagamento em curso) — não sobrescrever
        // um estado local já saudável por causa dele.
        if (!empty($object->status) && $object->status !== 'incomplete') {
            $updates['status'] = $this->mapStripeStatus((string) $object->status);
        }
        if (!empty($object->current_period_start)) {
            $updates['current_period_start'] = now()->setTimestamp((int) $object->current_period_start);
        }
        if (!empty($object->current_period_end)) {
            $updates['current_period_end'] = now()->setTimestamp((int) $object->current_period_end);
        }
        if (isset($object->cancel_at_period_end)) {
            $updates['cancel_at_period_end'] = (bool) $object->cancel_at_period_end;
        }

        if ($updates) {
            $subscription->update($updates);
        }
    }

    /**
     * customer.subscription.deleted → canceled.
     */
    private function markSubscriptionDeleted(\Stripe\Event $event): void
    {
        $object = $event->data->object;
        Subscription::where('stripe_subscription_id', $object->id ?? null)
            ->update(['status' => 'canceled']);
    }

    /**
     * invoice.payment_failed → past_due (só se ainda ativa/trialing).
     */
    private function markSubscriptionPastDue(\Stripe\Event $event): void
    {
        $object = $event->data->object;
        $stripeSubscriptionId = $object->subscription ?? null;
        if (!$stripeSubscriptionId) {
            return;
        }

        Subscription::where('stripe_subscription_id', $stripeSubscriptionId)
            ->whereIn('status', ['active', 'trialing'])
            ->update(['status' => 'past_due']);
    }

    /**
     * Stripe → estados locais. Estados fora do conjunto previsto ficam
     * como past_due (conservador: não dar acesso sem estado reconhecido).
     */
    private function mapStripeStatus(string $status): string
    {
        return match ($status) {
            'trialing', 'active', 'past_due', 'canceled', 'paused', 'incomplete_expired' => $status,
            default => 'past_due',
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
