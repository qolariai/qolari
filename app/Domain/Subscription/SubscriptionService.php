<?php

namespace App\Domain\Subscription;

use App\Models\Subscription;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

/**
 * Regras de negócio da subscrição Chat (mundo separado da wallet):
 * acesso, teto de tokens por período e throttling acima do throttle_percent.
 */
class SubscriptionService
{
    /**
     * Subscrição ativa/trialing do utilizador, com roll-forward preguiçoso
     * do período: se o período terminou (e a subscrição continua ativa),
     * avança para agora/+period_days e repõe o contador de tokens.
     * Sem job agendado — acontece no acesso.
     */
    public function activeFor(User $user): ?Subscription
    {
        $subscription = Subscription::usable()
            ->where('user_id', $user->id)
            ->with('plan')
            ->latest('id')
            ->first();

        if (!$subscription) {
            return null;
        }

        if ($subscription->current_period_end && $subscription->current_period_end->isPast()) {
            $periodDays = $subscription->plan?->period_days ?? 30;

            $subscription->update([
                'current_period_start' => now(),
                'current_period_end' => now()->addDays($periodDays),
                'tokens_used' => 0,
            ]);
        }

        return $subscription;
    }

    /**
     * Porta de entrada do Chat: exige subscrição ativa e teto com folga.
     *
     * @throws NoActiveSubscriptionException  → HTTP 402
     * @throws TokenCeilingExceededException  → HTTP 429
     */
    public function ensureChatAccess(User $user): Subscription
    {
        $subscription = $this->activeFor($user);

        if (!$subscription) {
            throw new NoActiveSubscriptionException();
        }

        $limit = (int) ($subscription->plan?->token_limit ?? 0);
        if ($limit > 0 && $subscription->tokens_used >= $limit) {
            throw new TokenCeilingExceededException();
        }

        return $subscription;
    }

    /**
     * Incrementa o contador de tokens do período (lock para evitar lost updates).
     */
    public function recordUsage(Subscription $subscription, int $tokens): void
    {
        if ($tokens <= 0) {
            return;
        }

        DB::transaction(function () use ($subscription, $tokens) {
            $fresh = Subscription::lockForUpdate()->find($subscription->id);
            $fresh?->increment('tokens_used', $tokens);
        });

        $subscription->tokens_used += $tokens;
    }

    /**
     * Acima de throttle_percent% do teto → respostas artificialmente mais lentas.
     */
    public function isThrottled(Subscription $subscription): bool
    {
        $limit = (int) ($subscription->plan?->token_limit ?? 0);
        if ($limit <= 0) {
            return false;
        }

        $percent = (int) ($subscription->plan?->throttle_percent ?? 80);

        return $subscription->tokens_used > ($limit * $percent / 100);
    }

    /**
     * Cancelamento pelo admin (Filament): marca canceled localmente e, se
     * houver key da Stripe configurada, cancela também do lado da Stripe.
     */
    public function cancelByAdmin(Subscription $subscription): void
    {
        $stripeSubscriptionId = $subscription->stripe_subscription_id;
        $secret = \App\Models\Setting::get('stripe_secret_key') ?? config('services.stripe.secret');

        if ($secret && $stripeSubscriptionId) {
            try {
                \Stripe\Stripe::setApiKey($secret);
                \Stripe\Subscription::retrieve($stripeSubscriptionId)->cancel();
            } catch (\Throwable $e) {
                // Falha na Stripe não impede o cancelamento local (decisão do admin)
                Log::warning('Cancelamento Stripe falhou; a cancelar apenas localmente.', [
                    'subscription_id' => $subscription->id,
                    'stripe_subscription_id' => $stripeSubscriptionId,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        $subscription->update(['status' => 'canceled']);
    }
}
