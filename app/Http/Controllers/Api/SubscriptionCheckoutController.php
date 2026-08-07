<?php

namespace App\Http\Controllers\Api;

use App\Domain\Billing\StripeService;
use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * POST /api/v1/checkout/subscription — Checkout Stripe para o Chat (subscrição).
 * Mundo separado dos pacotes de créditos (POST /v1/checkout).
 */
class SubscriptionCheckoutController extends Controller
{
    public function __construct(private StripeService $stripeService)
    {
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'plan_id' => 'required|exists:subscription_plans,id',
            'currency' => 'required|in:EUR,USD,GBP',
        ]);

        $plan = SubscriptionPlan::where('id', $validated['plan_id'])
            ->where('is_active', true)
            ->firstOrFail();

        if (!$plan->priceFor($validated['currency'])) {
            return response()->json([
                'error' => ['message' => 'Plano indisponível para a moeda selecionada.', 'code' => 'plan_price_missing'],
            ], 422);
        }

        if (!$plan->stripe_price_id) {
            return response()->json([
                'error' => ['message' => 'Plano temporariamente indisponível para subscrição.', 'code' => 'plan_not_configured'],
            ], 422);
        }

        $result = $this->stripeService->createSubscriptionCheckout(
            user: $request->user(),
            plan: $plan,
            currency: $validated['currency'],
        );

        return response()->json([
            'checkout_url' => $result['checkout_url'],
            'subscription_id' => $result['subscription']->id,
        ]);
    }
}
