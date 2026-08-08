<?php

namespace App\Http\Controllers\Api;

use App\Domain\Billing\AppyPayService;
use App\Domain\Billing\StripeService;
use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CheckoutController extends Controller
{
    public function __construct(
        private StripeService $stripeService,
        private AppyPayService $appypayService,
    ) {
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'currency' => 'required|in:EUR,USD,GBP,AOA',
            'promo_code' => 'nullable|string|exists:promo_codes,code',
            // Obrigatório em AOA (Multicaixa Express): telemóvel angolano
            'phone' => 'nullable|string|max:20',
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

        // AOA → AppyPay (Multicaixa Express); restantes moedas → Stripe
        if ($validated['currency'] === 'AOA') {
            $phone = AppyPayService::normalizePhone((string) ($validated['phone'] ?? ''));
            if (!$phone) {
                return response()->json([
                    'message' => 'Número de telemóvel angolano inválido (formato: 9XXXXXXXX).',
                    'errors' => ['phone' => ['Número de telemóvel angolano inválido (formato: 9XXXXXXXX).']],
                ], 422);
            }

            $result = $this->appypayService->createCheckout(
                product: $product,
                currency: 'AOA',
                user: $request->user(),
                phone: $phone,
                promoCodeId: $promoCodeId,
            );

            return response()->json([
                'order_id' => $result['order']->id,
                'gateway' => 'appypay',
                'status' => $result['status'],
                'payment_method' => 'multicaixa_express',
            ]);
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
