<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PromoCode;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'email' => 'required|email|max:190|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'promo_code' => 'nullable|string|exists:promo_codes,code',
            'country' => 'nullable|string|size:2',
            'preferred_currency' => 'nullable|in:EUR,USD,GBP',
            'language' => 'nullable|in:pt,en',
        ]);

        $promoCodeId = null;
        if (!empty($validated['promo_code'])) {
            $promo = PromoCode::where('code', $validated['promo_code'])
                ->where('is_active', true)
                ->first();
            $promoCodeId = $promo?->id;
        }

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => $validated['password'],
            'country' => $validated['country'] ?? null,
            'preferred_currency' => $validated['preferred_currency'] ?? 'EUR',
            'language' => $validated['language'] ?? 'pt',
            'promo_code_id' => $promoCodeId,
        ]);

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Credenciais invalidas.'],
            ]);
        }

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Sessao terminada.']);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json($request->user());
    }

    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|string|max:100',
            'preferred_currency' => 'sometimes|in:EUR,USD,GBP',
            'language' => 'sometimes|in:pt,en',
            'country' => 'sometimes|nullable|string|size:2',
            'nexus_auto' => 'sometimes|boolean',
            'password' => 'sometimes|string|min:8|confirmed',
        ]);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $user->update($validated);

        return response()->json($user->fresh());
    }
}
