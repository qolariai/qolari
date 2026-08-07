<?php

namespace Tests\Feature;

use App\Domain\Wallet\WalletService;
use App\Models\AiModel;
use App\Models\ChatConversation;
use App\Models\ModelCost;
use App\Models\Setting;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\UsageLog;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/**
 * O Chat fatura no contador da subscrição — NUNCA na wallet (Code).
 * Sem subscrição → 402; teto atingido → 429.
 */
class ChatBudgetTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private AiModel $model;
    private SubscriptionPlan $plan;
    private Subscription $subscription;
    private ChatConversation $conversation;

    protected function setUp(): void
    {
        parent::setUp();

        config(['chat.throttle_sleep_ms' => 0]);

        $this->user = User::factory()->create();

        $this->model = AiModel::create([
            'slug' => 'nexus-low',
            'display_name' => 'Nexus Low',
            'provider' => 'openrouter',
            'provider_model_id' => 'test/model',
            'margin_multiplier' => 3.00,
            'is_active' => true,
            'sort_order' => 1,
        ]);

        ModelCost::create([
            'ai_model_id' => $this->model->id,
            'input_cost_per_mtok' => 1.0,
            'output_cost_per_mtok' => 2.0,
            'synced_at' => now(),
            'created_at' => now(),
        ]);

        Setting::set('credit_expiry_months', '12');
        Setting::set('openrouter_api_key', 'sk-or-test', true);

        // Wallet com saldo — tem de ficar INTACTA com o uso do Chat
        app(WalletService::class)->credit($this->user->id, $this->model->id, 5.00);

        $this->plan = SubscriptionPlan::create([
            'slug' => 'chat-basic',
            'name' => 'Chat Essencial',
            'token_limit' => 100, // minúsculo de propósito
            'period_days' => 30,
            'throttle_percent' => 80,
            'is_active' => true,
        ]);

        $this->subscription = Subscription::create([
            'user_id' => $this->user->id,
            'plan_id' => $this->plan->id,
            'status' => 'active',
            'current_period_start' => now(),
            'current_period_end' => now()->addDays(30),
            'tokens_used' => 0,
        ]);

        $this->conversation = $this->user->chatConversations()->create([
            'title' => 'Teste',
        ]);

        Http::fake([
            'openrouter.ai/*' => Http::response([
                'id' => 'gen-chat-1',
                'model' => 'test/model',
                'choices' => [[
                    'message' => ['role' => 'assistant', 'content' => 'Olá! Em que posso ajudar?'],
                    'finish_reason' => 'stop',
                ]],
                'usage' => ['prompt_tokens' => 30, 'completion_tokens' => 20],
            ]),
        ]);
    }

    private function sendMessage(array $overrides = []): \Illuminate\Testing\TestResponse
    {
        Sanctum::actingAs($this->user);

        return $this->postJson(
            "/api/v1/chat/conversations/{$this->conversation->id}/messages",
            array_merge(['content' => 'Olá, tudo bem?'], $overrides),
        );
    }

    public function test_chat_without_subscription_returns_402(): void
    {
        $this->subscription->delete();

        $response = $this->sendMessage();

        $response->assertStatus(402)
            ->assertJsonPath('error.code', 'subscription_required');
    }

    public function test_chat_usage_bills_subscription_counter_not_wallet(): void
    {
        $response = $this->sendMessage();

        $response->assertOk()
            ->assertJsonPath('message.role', 'assistant')
            ->assertJsonPath('message.content', 'Olá! Em que posso ajudar?');

        // Contador da subscrição: 30 prompt + 20 completion
        $this->assertEquals(50, $this->subscription->fresh()->tokens_used);

        // WHITE-LABEL no corpo: nunca o provider_model_id real
        $this->assertStringNotContainsString('test/model', $response->getContent());

        // Wallet INTACTA: saldo igual e nenhum débito no ledger
        $wallet = Wallet::where('user_id', $this->user->id)
            ->where('ai_model_id', $this->model->id)
            ->first();
        $this->assertEqualsWithDelta(5.00, (float) $wallet->balance, 0.000001);
        $this->assertDatabaseMissing('ledger_entries', ['type' => 'debit']);

        // Usage log escrito (custo calculado) mas sem entrada de ledger
        $log = UsageLog::where('user_id', $this->user->id)->first();
        $this->assertEquals('ok', $log->status);
        $this->assertEquals(30, $log->prompt_tokens);
        $this->assertEquals(20, $log->completion_tokens);
        $this->assertNull($log->ledger_entry_id);

        // Histórico: mensagem do utilizador + do assistant persistidas
        $this->assertEquals(2, $this->conversation->messages()->count());
    }

    public function test_chat_returns_429_when_token_ceiling_exceeded(): void
    {
        $this->subscription->update(['tokens_used' => 100]); // = teto

        $response = $this->sendMessage();

        $response->assertStatus(429)
            ->assertJsonPath('error.code', 'token_ceiling_exceeded');

        // Nada foi ao provider nem contou mais tokens
        Http::assertNothingSent();
        $this->assertEquals(100, $this->subscription->fresh()->tokens_used);
    }

    public function test_chat_above_throttle_percent_sets_header_but_still_works(): void
    {
        // 85% > throttle_percent (80), mas < teto (100)
        $this->subscription->update(['tokens_used' => 85]);

        $response = $this->sendMessage();

        $response->assertOk();
        $this->assertEquals('1', $response->headers->get('X-Qolari-Throttled'));

        // Tokens somados na mesma
        $this->assertEquals(135, $this->subscription->fresh()->tokens_used);
    }

    public function test_subscription_state_endpoint_reflects_usage(): void
    {
        $this->subscription->update(['tokens_used' => 90]);

        Sanctum::actingAs($this->user);

        $response = $this->getJson('/api/v1/subscription');

        $response->assertOk()
            ->assertJsonPath('subscription.tokens_used', 90)
            ->assertJsonPath('subscription.plan.token_limit', 100)
            ->assertJsonPath('subscription.throttled', true); // 90% > 80%
    }
}
