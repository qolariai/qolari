<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use Illuminate\Http\JsonResponse;

/**
 * GET /api/v1/subscription-plans — planos Chat ativos (página de preços).
 * WHITE-LABEL: apenas nome white-label, preços por moeda e teto de tokens.
 * Nunca expõe IDs Stripe nem planos inativos.
 */
class SubscriptionPlanController extends Controller
{
    public function index(): JsonResponse
    {
        $plans = SubscriptionPlan::active()
            ->with('prices')
            ->orderBy('sort_order')
            ->get()
            ->map(fn (SubscriptionPlan $plan) => [
                'id' => $plan->id,
                'slug' => $plan->slug,
                'name' => $plan->name,
                'token_limit' => (int) $plan->token_limit,
                'token_limit_human' => $this->humanTokens((int) $plan->token_limit),
                'period_days' => (int) $plan->period_days,
                'prices' => $plan->prices
                    ->map(fn ($price) => [
                        'currency' => $price->currency,
                        'amount' => $price->amount,
                    ])
                    ->values(),
            ])
            ->values();

        return response()->json($plans);
    }

    /**
     * Teto de tokens em formato humano: 1_000_000 → "1M", 500_000 → "500K".
     */
    private function humanTokens(int $tokens): string
    {
        if ($tokens >= 1_000_000) {
            return rtrim(rtrim(number_format($tokens / 1_000_000, 1), '0'), '.') . 'M';
        }

        if ($tokens >= 1_000) {
            return rtrim(rtrim(number_format($tokens / 1_000, 1), '0'), '.') . 'K';
        }

        return (string) $tokens;
    }
}
