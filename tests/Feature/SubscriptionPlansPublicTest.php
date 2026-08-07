<?php

namespace Tests\Feature;

use App\Models\SubscriptionPlan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Endpoint público dos planos de subscrição Chat (página de preços).
 * WHITE-LABEL: sem IDs Stripe, sem planos inativos.
 */
class SubscriptionPlansPublicTest extends TestCase
{
    use RefreshDatabase;

    public function test_lists_only_active_plans_with_white_label_shape(): void
    {
        $pro = SubscriptionPlan::create([
            'slug' => 'chat-pro',
            'name' => 'Chat Avançado',
            'token_limit' => 500_000,
            'period_days' => 30,
            'throttle_percent' => 80,
            'stripe_price_id' => 'price_secret_pro',
            'is_active' => true,
            'sort_order' => 1,
        ]);
        $pro->prices()->create(['currency' => 'EUR', 'amount' => 19.99]);

        $basic = SubscriptionPlan::create([
            'slug' => 'chat-start',
            'name' => 'Chat Essencial',
            'token_limit' => 1_000_000,
            'period_days' => 30,
            'throttle_percent' => 80,
            'stripe_price_id' => 'price_secret_start',
            'is_active' => true,
            'sort_order' => 2,
        ]);
        $basic->prices()->create(['currency' => 'EUR', 'amount' => 9.99]);
        $basic->prices()->create(['currency' => 'USD', 'amount' => 10.99]);
        $basic->prices()->create(['currency' => 'GBP', 'amount' => 8.99]);

        $inactive = SubscriptionPlan::create([
            'slug' => 'chat-old',
            'name' => 'Chat Antigo',
            'token_limit' => 100_000,
            'period_days' => 30,
            'throttle_percent' => 80,
            'stripe_price_id' => 'price_secret_old',
            'is_active' => false,
            'sort_order' => 0,
        ]);
        $inactive->prices()->create(['currency' => 'EUR', 'amount' => 4.99]);

        $response = $this->getJson('/api/v1/subscription-plans');

        $response->assertOk()
            ->assertJsonCount(2)
            // Ordem por sort_order
            ->assertJsonPath('0.slug', 'chat-pro')
            ->assertJsonPath('0.name', 'Chat Avançado')
            ->assertJsonPath('0.token_limit', 500000)
            ->assertJsonPath('0.token_limit_human', '500K')
            ->assertJsonPath('0.period_days', 30)
            ->assertJsonCount(1, '0.prices')
            ->assertJsonPath('1.slug', 'chat-start')
            ->assertJsonPath('1.token_limit_human', '1M')
            ->assertJsonCount(3, '1.prices')
            ->assertJsonPath('1.prices.0.currency', 'EUR')
            ->assertJsonPath('1.prices.0.amount', '9.99');

        // WHITE-LABEL: nenhum ID Stripe nem planos inativos na resposta
        $content = $response->getContent();
        $this->assertStringNotContainsString('price_secret_pro', $content);
        $this->assertStringNotContainsString('price_secret_start', $content);
        $this->assertStringNotContainsString('price_secret_old', $content);
        $this->assertStringNotContainsString('chat-old', $content);
        $this->assertStringNotContainsString('stripe', strtolower($content));
    }

    public function test_returns_empty_list_when_no_active_plans(): void
    {
        $this->getJson('/api/v1/subscription-plans')
            ->assertOk()
            ->assertJsonCount(0);
    }
}
