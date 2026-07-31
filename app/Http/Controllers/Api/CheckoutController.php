<?php

namespace App\Http\Controllers\Api;

use App\Domain\Billing\StripeService;
use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CheckoutController extends Controller
{
    public function __construct(private StripeService $stripeService)
    {
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'currency' => 'required|in:EUR,USD,GBP',
            'promo_code' => 'nullable|string|exists:promo_codes,code',
        ]);

        $product = Product::where('id', $validated['product_id'])
            ->where('is_active', true)
            ->firstOrFail();

        $promoCodeId = null;
        if (!empty($validated['promo_code'])) {
            $promo = \App\Models\PromoCode::where('code', $validated['promo_code'])
                ->where('is_active', true)
                ->first();
            $promoCodeId = $promo?->id;
        }

        $result = $this->stripeService->createCheckout(
            product: $product,
            currency: $validated['currency'],
            userId: $request->user()->id,
            promoCodeId: $promoCodeId,
        );

        return response()->json([
            'checkout_url' => $result['checkout_url'],
            'order_id' => $result['order']->id,
        ]);
    }
}
