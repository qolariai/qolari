<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TokenController extends Controller
{
    /**
     * Lista tokens do utilizador (sem mostrar o token em si).
     */
    public function index(Request $request): JsonResponse
    {
        $tokens = $request->user()
            ->tokens()
            ->get(['id', 'name', 'created_at', 'last_used_at']);

        return response()->json($tokens);
    }

    /**
     * Cria novo token API (para usar no IDE).
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
        ]);

        $token = $request->user()->createToken($validated['name']);

        return response()->json([
            'id' => $token->accessToken->id,
            'name' => $token->accessToken->name,
            'token' => $token->plainTextToken,
            'created_at' => $token->accessToken->created_at,
        ], 201);
    }

    /**
     * Revoga um token.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $deleted = $request->user()
            ->tokens()
            ->where('id', $id)
            ->delete();

        if (!$deleted) {
            return response()->json(['message' => 'Token nao encontrado.'], 404);
        }

        return response()->json(['message' => 'Token revogado.']);
    }
}
