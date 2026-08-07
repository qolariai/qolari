<?php

namespace App\Domain\Subscription;

use Illuminate\Http\JsonResponse;

/**
 * Teto de tokens do período atingido → HTTP 429.
 * Mensagem white-label: nunca mencionar providers/modelos reais.
 */
class TokenCeilingExceededException extends \Exception
{
    public function __construct(string $message = 'Atingiu o limite de utilização do seu plano neste período.')
    {
        parent::__construct($message);
    }

    public function render(): JsonResponse
    {
        return response()->json([
            'error' => [
                'message' => $this->getMessage(),
                'code' => 'token_ceiling_exceeded',
            ],
        ], 429);
    }
}
