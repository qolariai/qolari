<?php

namespace App\Http\Controllers\Api;

use App\Domain\Subscription\SubscriptionService;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * GET /api/v1/subscription — estado da subscrição Chat do utilizador.
 * WHITE-LABEL: nunca expor IDs Stripe nem nomes de providers.
 */
class SubscriptionController extends Controller
{
    public function __construct(private SubscriptionService $subscriptionService)
    {
    }

    public function show(Request $request): JsonResponse
    {
        $subscription = $this->subscriptionService->activeFor($request->user());

        if (!$subscription) {
            return response()->json([
                'subscription' => null,
            ]);
        }

        $plan = $subscription->plan;

        return response()->json([
            'subscription' => [
                'status' => $subscription->status,
                'plan' => [
                    'slug' => $plan?->slug,
                    'name' => $plan?->name,
                    'token_limit' => $plan ? (int) $plan->token_limit : null,
                    'period_days' => $plan ? (int) $plan->period_days : null,
                ],
                'tokens_used' => (int) $subscription->tokens_used,
                'current_period_start' => $subscription->current_period_start?->toIso8601String(),
                'current_period_end' => $subscription->current_period_end?->toIso8601String(),
                'cancel_at_period_end' => (bool) $subscription->cancel_at_period_end,
                'throttled' => $this->subscriptionService->isThrottled($subscription),
            ],
        ]);
    }
}
