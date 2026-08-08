<?php

namespace App\Domain\Billing;

use App\Domain\Wallet\WalletService;
use App\Models\Commission;
use App\Models\Order;

/**
 * Fulfillment de ordens de créditos — gateway-agnostic.
 * Marca a order como paga, credita a wallet e cria comissão de
 * influenciador quando aplicável. Idempotente: orders já pagas são
 * ignoradas e o crédito usa chave de idempotência estável.
 */
class OrderFulfillmentService
{
    public function __construct(
        private WalletService $walletService,
    ) {
    }

    public function fulfill(?int $orderId): void
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
