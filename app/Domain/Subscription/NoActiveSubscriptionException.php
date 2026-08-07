<?php

namespace App\Domain\Subscription;

use Illuminate\Http\JsonResponse;

/**
 * Sem subscrição Chat ativa → HTTP 402 (Payment Required).
 * Mensagem white-label: nunca mencionar providers/modelos reais.
 */
class NoActiveSubscriptionException extends \Exception
{
    public function __construct(string $message = 'É necessária uma subscrição ativa para usar o Chat.')
    {
        parent::__construct($message);
    }

    public function render(): JsonResponse
    {
        return response()->json([
            'error' => [
                'message' => $this->getMessage(),
                'code' => 'subscription_required',
            ],
        ], 402);
    }
}
