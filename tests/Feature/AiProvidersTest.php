<?php

namespace Tests\Feature;

use App\Domain\Proxy\AiProviderResolver;
use App\Domain\Proxy\OpenRouterProxyService;
use App\Domain\Wallet\WalletService;
use App\Jobs\ReconcileStreamUsage;
use App\Jobs\SyncModelCosts;
use App\Models\AiModel;
use App\Models\ModelCost;
use App\Models\Setting;
use App\Models\UsageLog;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/**
 * Providers diretos (v4.3): o proxy resolve base_url + key a partir do
 * provider do motor, o frame de erro SSE é genérico e o SyncModelCosts
 * só toca em providers com catálogo (supports_catalog=true).
 */
class AiProvidersTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private AiModel $deepseekModel;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();
        $this->deepseekModel = AiModel::create([
            'slug' => 'nexus-medium',
            'display_name' => 'Nexus Medium',
            'provider' => 'deepseek',
            'provider_model_id' => 'deepseek-chat',
            'supports_vision' => false,
            'margin_multiplier' => 3.00,
            'is_active' => true,
            'sort_order' => 1,
        ]);

        ModelCost::create([
            'ai_model_id' => $this->deepseekModel->id,
            'input_cost_per_mtok' => 0.27,
            'output_cost_per_mtok' => 1.10,
            'synced_at' => now(),
            'created_at' => now(),
        ]);

        Setting::set('credit_expiry_months', '12');
        Setting::set('deepseek_api_key', 'sk-deepseek-test', true);
    }

    public function test_resolver_resolves_base_url_and_key_from_provider(): void
    {
        $resolved = app(AiProviderResolver::class)->forModel($this->deepseekModel);

        $this->assertEquals('deepseek', $resolved['slug']);
        $this->assertEquals('https://api.deepseek.com', $resolved['base_url']);
        $this->assertEquals('sk-deepseek-test', $resolved['api_key']);
        $this->assertFalse($resolved['supports_catalog']);
    }

    public function test_resolver_falls_back_to_env_config_when_setting_missing(): void
    {
        Setting::where('key', 'deepseek_api_key')->delete();
        config(['services.deepseek.api_key' => 'sk-env-fallback']);

        $resolved = app(AiProviderResolver::class)->forModel($this->deepseekModel);

        $this->assertEquals('sk-env-fallback', $resolved['api_key']);
    }

    public function test_completions_uses_direct_provider_url_key_and_whitelabel(): void
    {
        app(WalletService::class)->credit($this->user->id, $this->deepseekModel->id, 10.00);

        Http::fake([
            'api.deepseek.com/*' => Http::response([
                'id' => 'gen-ds-1',
                'model' => 'deepseek-chat', // ID real do motor
                'choices' => [['message' => ['role' => 'assistant', 'content' => 'feito'], 'finish_reason' => 'stop']],
                'usage' => ['prompt_tokens' => 10, 'completion_tokens' => 5],
            ]),
        ]);

        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/v1/chat/completions', [
            'model' => 'nexus-medium',
            'messages' => [['role' => 'user', 'content' => 'ola']],
        ]);

        $response->assertOk();
        // White-label: o cliente vê o tier, nunca "deepseek-chat"
        $this->assertEquals('nexus-medium', $response->json('model'));

        // (a) O proxy chamou a DeepSeek DIRETA com a key do provider certo
        Http::assertSent(function ($request) {
            return $request->url() === 'https://api.deepseek.com/chat/completions'
                && $request->hasHeader('Authorization', 'Bearer sk-deepseek-test')
                && $request['model'] === 'deepseek-chat';
        });
        // Nada foi para a OpenRouter
        Http::assertNotSent(fn ($request) => str_contains($request->url(), 'openrouter.ai'));

        // Metering idêntico: débito com margem 3x
        $log = UsageLog::where('user_id', $this->user->id)->first();
        $this->assertEquals('ok', $log->status);
    }

    public function test_completions_with_stream_true_returns_sse_stream(): void
    {
        app(WalletService::class)->credit($this->user->id, $this->deepseekModel->id, 10.00);

        // O IDE envia stream=true para /chat/completions (padrão OpenAI).
        // Sem o routing para stream(), o handler JSON devolveria resposta
        // vazia (o upstream responde SSE a um pedido com stream=true).
        $mock = $this->mock(OpenRouterProxyService::class);
        $mock->expects('stream')->once()->andReturn(new \Symfony\Component\HttpFoundation\StreamedResponse(
            function () {
                echo "data: [DONE]\n\n";
            },
            200,
            ['Content-Type' => 'text/event-stream'],
        ));

        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/v1/chat/completions', [
            'model' => 'nexus-medium',
            'stream' => true,
            'messages' => [['role' => 'user', 'content' => 'ola']],
        ]);

        $response->assertOk();
        $this->assertStringContainsString('text/event-stream', (string) $response->headers->get('Content-Type'));
        $this->assertStringContainsString('data: [DONE]', $response->streamedContent());
    }

    public function test_sse_error_frame_works_for_direct_provider(): void
    {
        $service = app(OpenRouterProxyService::class);

        // Erro típico da DeepSeek (HTTP 429, JSON simples) — o frame tem de
        // sair OpenAI-compatible e sem expor o ID real do motor.
        $errorBody = json_encode(['error' => ['message' => 'Model deepseek-chat is overloaded', 'code' => 429]]);

        $frame = $service->sseErrorFrame($errorBody, 429, 'deepseek-chat', 'nexus-medium');

        $this->assertStringStartsWith('data: ', $frame);
        $this->assertStringEndsWith("data: [DONE]\n\n", $frame);
        $this->assertStringNotContainsString('deepseek-chat', $frame);

        $payload = json_decode(substr(explode("\n", $frame)[0], 6), true);
        $this->assertEquals('Model nexus-medium is overloaded', $payload['error']['message']);
        $this->assertEquals(429, $payload['error']['code']);
    }

    public function test_sse_error_frame_handles_non_json_error_body(): void
    {
        $service = app(OpenRouterProxyService::class);

        $frame = $service->sseErrorFrame('<html>502 Bad Gateway</html>', 502, 'deepseek-chat', 'nexus-medium');

        $payload = json_decode(substr(explode("\n", $frame)[0], 6), true);
        $this->assertEquals('Upstream error (HTTP 502)', $payload['error']['message']);
        $this->assertStringEndsWith("data: [DONE]\n\n", $frame);
    }

    public function test_sync_model_costs_never_touches_providers_without_catalog(): void
    {
        Setting::set('openrouter_api_key', 'sk-or-test', true);

        $openrouterModel = AiModel::create([
            'slug' => 'or-model', 'display_name' => 'OR', 'provider' => 'openrouter',
            'provider_model_id' => 'or/model', 'margin_multiplier' => 3.00,
            'is_active' => true, 'sort_order' => 2,
        ]);
        // Custo manual pré-existente na DeepSeek — não pode ser apagado/alterado
        $manualCost = $this->deepseekModel->latestCost();

        Http::fake([
            'openrouter.ai/api/v1/models' => Http::response([
                'data' => [
                    [
                        'id' => 'or/model',
                        'pricing' => ['prompt' => '0.000002', 'completion' => '0.000008'],
                        'architecture' => ['input_modalities' => ['text', 'image']],
                        'context_length' => 128000,
                    ],
                    // A DeepSeek nem sequer devia ser consultada; se o job a
                    // procurasse no catálogo da OpenRouter, não a encontraria.
                ],
            ]),
        ]);

        (new SyncModelCosts)->handle(app(AiProviderResolver::class));

        // OpenRouter: custo sincronizado + capacidades atualizadas
        $orCost = $openrouterModel->fresh()->latestCost();
        $this->assertNotNull($orCost);
        $this->assertEqualsWithDelta(2.0, (float) $orCost->input_cost_per_mtok, 0.000001);
        $this->assertTrue($openrouterModel->fresh()->supports_vision);
        $this->assertEquals(128000, $openrouterModel->fresh()->context_limit);

        // DeepSeek: exatamente 1 custo (o manual), inalterado
        $this->assertEquals(1, ModelCost::where('ai_model_id', $this->deepseekModel->id)->count());
        $this->assertEquals($manualCost->id, $this->deepseekModel->fresh()->latestCost()->id);
        $this->assertEqualsWithDelta(0.27, (float) $this->deepseekModel->fresh()->latestCost()->input_cost_per_mtok, 0.000001);

        // O job só falou com a OpenRouter
        Http::assertNotSent(fn ($request) => str_contains($request->url(), 'deepseek.com'));
    }

    public function test_reconcile_goes_straight_to_estimate_for_direct_providers(): void
    {
        app(WalletService::class)->credit($this->user->id, $this->deepseekModel->id, 10.00);
        $meter = app(\App\Domain\Proxy\UsageMeter::class);
        $meter->recordPending($this->user->id, $this->deepseekModel->id, $this->deepseekModel->id, 'req-ds', 'gen-ds');

        Http::fake(); // qualquer chamada HTTP falharia o teste abaixo

        (new ReconcileStreamUsage('req-ds', 'gen-ds', 100, 50))->handle($meter);

        $log = UsageLog::where('request_id', 'req-ds')->first();
        // Sem lookup /generation na DeepSeek → estimativa direta
        $this->assertEquals('estimated', $log->status);
        $this->assertEquals(100, $log->prompt_tokens);
        $this->assertEquals(50, $log->completion_tokens);
        Http::assertNothingSent();
    }
}
