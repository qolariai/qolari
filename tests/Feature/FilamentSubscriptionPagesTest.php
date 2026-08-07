<?php

namespace Tests\Feature;

use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Smoke test: os recursos Filament novos têm de renderizar sem erros
 * (form com repeater de preços, table, infolist de view).
 */
class FilamentSubscriptionPagesTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::factory()->create(['is_admin' => true]);
    }

    public function test_subscription_plans_pages_render(): void
    {
        $plan = SubscriptionPlan::create([
            'slug' => 'chat-basic',
            'name' => 'Chat Essencial',
            'token_limit' => 1_000_000,
            'period_days' => 30,
            'throttle_percent' => 80,
            'is_active' => true,
        ]);
        $plan->prices()->create(['currency' => 'EUR', 'amount' => 9.99]);

        $this->actingAs($this->admin)->get('/admin/subscription-plans')->assertOk();
        $this->actingAs($this->admin)->get('/admin/subscription-plans/create')->assertOk();
        $this->actingAs($this->admin)->get("/admin/subscription-plans/{$plan->id}/edit")->assertOk();
    }

    public function test_subscriptions_pages_render(): void
    {
        $plan = SubscriptionPlan::create([
            'slug' => 'chat-basic',
            'name' => 'Chat Essencial',
            'token_limit' => 1_000_000,
            'period_days' => 30,
            'throttle_percent' => 80,
            'is_active' => true,
        ]);

        $subscription = Subscription::create([
            'user_id' => $this->admin->id,
            'plan_id' => $plan->id,
            'status' => 'active',
            'current_period_start' => now(),
            'current_period_end' => now()->addDays(30),
        ]);

        $this->actingAs($this->admin)->get('/admin/subscriptions')->assertOk();
        $this->actingAs($this->admin)->get("/admin/subscriptions/{$subscription->id}")->assertOk();
    }

    public function test_non_admin_cannot_access_panel(): void
    {
        $user = User::factory()->create(['is_admin' => false]);

        $this->actingAs($user)->get('/admin/subscription-plans')->assertForbidden();
    }
}
