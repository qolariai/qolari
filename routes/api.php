<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\CheckoutController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\ProxyController;
use App\Http\Controllers\Api\RecommendationController;
use App\Http\Controllers\Api\StripeWebhookController;
use App\Http\Controllers\Api\SubscriptionCheckoutController;
use App\Http\Controllers\Api\SubscriptionController;
use App\Http\Controllers\Api\SubscriptionPlanController;
use App\Http\Controllers\Api\TokenController;
use App\Http\Controllers\Api\UsageController;
use App\Http\Controllers\Api\WalletController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — Qolari v1
|--------------------------------------------------------------------------
*/

// Webhook Stripe (sem auth — a propria Stripe assina)
Route::post('/v1/webhooks/stripe', [StripeWebhookController::class, 'handle'])
    ->name('webhooks.stripe');

// Webhook AppyPay (sem auth — assinatura HMAC no header X-AppyPay-Signature)
Route::post('/v1/webhooks/appypay', [\App\Http\Controllers\Api\AppyPayWebhookController::class, 'handle'])
    ->name('webhooks.appypay');

// Auth publica
Route::post('/v1/register', [AuthController::class, 'register'])->name('auth.register');
Route::post('/v1/login', [AuthController::class, 'login'])->name('auth.login');

// Produtos (publico — pagina de precos)
Route::get('/v1/products', [ProductController::class, 'index'])->name('products.index');

// Planos de subscrição Chat (publico — pagina de precos; sem IDs Stripe)
Route::get('/v1/subscription-plans', [SubscriptionPlanController::class, 'index'])->name('subscription-plans.index');

// Geo-pricing: moeda sugerida por IP (publico, falha silenciosa)
Route::get('/v1/geo', [\App\Http\Controllers\Api\GeoController::class, 'show'])
    ->middleware('throttle:30,1')
    ->name('geo.show');

// Validacao publica de codigos de influenciador (rate limit generoso)
Route::get('/v1/promo-codes/{code}', [\App\Http\Controllers\Api\PromoCodeController::class, 'show'])
    ->middleware('throttle:30,1')
    ->name('promo-codes.show');

// Rotas autenticadas (Sanctum)
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/v1/logout', [AuthController::class, 'logout'])->name('auth.logout');
    Route::get('/v1/me', [AuthController::class, 'me'])->name('auth.me');
    Route::put('/v1/profile', [AuthController::class, 'update'])->name('auth.update');

    // Checkout
    Route::post('/v1/checkout', [CheckoutController::class, 'store'])->name('checkout.store');

    // Subscrição Chat (mundo separado dos pacotes de créditos)
    Route::post('/v1/checkout/subscription', [SubscriptionCheckoutController::class, 'store'])->name('checkout.subscription');
    Route::get('/v1/subscription', [SubscriptionController::class, 'show'])->name('subscription.show');

    // Wallets
    Route::get('/v1/wallets', [WalletController::class, 'index'])->name('wallets.index');

    // Orders
    Route::get('/v1/orders', [OrderController::class, 'index'])->name('orders.index');

    // Usage
    Route::get('/v1/usage', [UsageController::class, 'index'])->name('usage.index');
    Route::get('/v1/usage/summary', [UsageController::class, 'summary'])->name('usage.summary');

    // API Tokens
    Route::get('/v1/tokens', [TokenController::class, 'index'])->name('tokens.index');
    Route::post('/v1/tokens', [TokenController::class, 'store'])->name('tokens.store');
    Route::delete('/v1/tokens/{id}', [TokenController::class, 'destroy'])->name('tokens.destroy');

    // Telemetria de qualidade (sinais do IDE)
    Route::post('/v1/telemetry', [\App\Http\Controllers\Api\TelemetryController::class, 'store'])->name('telemetry.store');

    // Session Briefing (continuidade entre tiers)
    Route::get('/v1/conversations/{externalId}/briefing', [\App\Http\Controllers\Api\BriefingController::class, 'show'])->name('briefings.show');
    Route::put('/v1/conversations/{externalId}/briefing', [\App\Http\Controllers\Api\BriefingController::class, 'update'])->name('briefings.update');

    // Recomendador de tiers
    Route::post('/v1/recommendations/suggest', [RecommendationController::class, 'suggest'])->name('recommendations.suggest');
    Route::post('/v1/recommendations/dismiss', [RecommendationController::class, 'dismiss'])->name('recommendations.dismiss');

    // Proxy IA (rate limited)
    Route::middleware('throttle:60,1')->group(function () {
        Route::post('/v1/chat', [ProxyController::class, 'chat'])->name('proxy.chat');
        Route::post('/v1/chat/completions', [ProxyController::class, 'completions'])->name('proxy.completions');
    });

    // Chat por subscrição (rate limited; faturação no contador do período)
    Route::middleware('throttle:30,1')->prefix('v1/chat')->group(function () {
        Route::get('/conversations', [ChatController::class, 'index'])->name('chat.conversations.index');
        Route::post('/conversations', [ChatController::class, 'store'])->name('chat.conversations.store');
        Route::delete('/conversations/{id}', [ChatController::class, 'destroy'])->name('chat.conversations.destroy');
        Route::get('/conversations/{id}/messages', [ChatController::class, 'messages'])->name('chat.messages.index');
        Route::post('/conversations/{id}/messages', [ChatController::class, 'sendMessage'])->name('chat.messages.store');
    });
});
