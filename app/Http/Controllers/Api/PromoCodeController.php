<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PromoCode;
use Illuminate\Http\JsonResponse;

class PromoCodeController extends Controller
{
    /**
     * GET /v1/promo-codes/{code} — validação pública (sem auth).
     * Nunca revela dados do código (dono, comissão) — só se existe e está ativo.
     */
    public function show(string $code): JsonResponse
    {
        $valid = PromoCode::active()->where('code', $code)->exists();

        return response()->json(['valid' => $valid]);
    }
}
