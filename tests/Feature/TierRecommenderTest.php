<?php

namespace Tests\Feature;

use App\Domain\Routing\SuggestionGate;
use App\Domain\Routing\TierRecommender;
use App\Domain\Routing\TierResolver;
use App\Models\AiModel;
use App\Models\ModelCost;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TierRecommenderTest extends TestCase
{
    use RefreshDatabase;

    private TierRecommender $recommender;

    protected function setUp(): void
    {
        parent::setUp();
        $this->recommender = app(TierRecommender::class);

        foreach ([
            ['nexus-high', 'test/high', true, 1],
            ['nexus-medium', 'test/medium', false, 2],
            ['nexus-low', 'test/low', false, 3],
            ['nexus-vision', 'test/vision', true, 99],
        ] as [$slug, $pid, $vision, $order]) {
            AiModel::create([
                'slug' => $slug, 'display_name' => $slug, 'provider' => 'openrouter',
                'provider_model_id' => $pid, 'supports_vision' => $vision,
                'margin_multiplier' => 3.00, 'is_active' => true, 'sort_order' => $order,
            ]);
        }
    }

    private function body(string $text, ?string $model = 'nexus-high'): array
    {
        return ['model' => $model, 'messages' => [['role' => 'user', 'content' => $text]]];
    }

    public function test_simple_task_in_high_suggests_low(): void
    {
        $s = $this->recommender->suggest('nexus-high', $this->body('corrige este typo'));

        $this->assertNotNull($s);
        $this->assertEquals('nexus-low', $s['tier']);
        $this->assertEquals('down', $s['direction']);
        $this->assertEquals('simple_task', $s['reason']);
    }

    public function test_simple_task_in_low_suggests_nothing(): void
    {
        $this->assertNull($this->recommender->suggest('nexus-low', $this->body('corrige este typo', 'nexus-low')));
    }

    public function test_complex_phrase_suggests_high(): void
    {
        $s = $this->recommender->suggest('nexus-low', $this->body('preciso de migrar a arquitetura do projeto', 'nexus-low'));

        $this->assertEquals('nexus-high', $s['tier']);
        $this->assertEquals('up', $s['direction']);
        $this->assertEquals('complex_task', $s['reason']);
    }

    public function test_large_context_suggests_high(): void
    {
        $s = $this->recommender->suggest('nexus-medium', $this->body(str_repeat('x', 400_000), 'nexus-medium'));

        $this->assertEquals('nexus-high', $s['tier']);
        $this->assertEquals('large_context', $s['reason']);
    }

    public function test_vision_content_never_suggests(): void
    {
        $body = [
            'model' => 'nexus-high',
            'messages' => [[
                'role' => 'user',
                'content' => [
                    ['type' => 'text', 'text' => 'corrige este typo'],
                    ['type' => 'image_url', 'image_url' => ['url' => 'data:image/png;base64,x']],
                ],
            ]],
        ];

        $this->assertNull($this->recommender->suggest('nexus-high', $body));
    }

    public function test_normal_task_suggests_nothing(): void
    {
        $this->assertNull($this->recommender->suggest('nexus-medium', $this->body('implementa o endpoint de checkout com Stripe', 'nexus-medium')));
    }

    public function test_gate_rate_limits_and_dismissals(): void
    {
        $gate = app(SuggestionGate::class);
        $userId = 42;

        // 5 ticks → permite a 1ª sugestão
        for ($i = 0; $i < 5; $i++) {
            $gate->tick($userId);
        }
        $this->assertTrue($gate->allows($userId, 'nexus-low'));

        // Após mostrar, bloqueia até +5 pedidos
        $gate->recordShown($userId);
        $this->assertFalse($gate->allows($userId, 'nexus-low'));
        for ($i = 0; $i < 5; $i++) {
            $gate->tick($userId);
        }
        $this->assertTrue($gate->allows($userId, 'nexus-low'));

        // 2 recusas → nunca mais sugere esse tier
        $gate->dismiss($userId, 'nexus-low');
        $gate->dismiss($userId, 'nexus-low');
        $this->assertFalse($gate->allows($userId, 'nexus-low'));
        // ...mas outros tiers continuam permitidos
        $this->assertTrue($gate->allows($userId, 'nexus-high'));
    }

    public function test_nexus_auto_overrides_tier_silently(): void
    {
        $user = User::factory()->create(['nexus_auto' => true]);
        $resolver = app(TierResolver::class);

        // Pede High para um typo → Auto manda para o Low (e cobra ao Low)
        $r = $resolver->resolve($this->body('corrige este typo', 'nexus-high'), $user);

        $this->assertTrue($r->auto);
        $this->assertEquals('nexus-low', $r->tier->slug);
        $this->assertEquals('nexus-low', $r->engine->slug);
    }

    public function test_completions_sanitizes_real_model_and_sends_suggestion(): void
    {
        Setting::set('openrouter_api_key', 'test-key', true);
        Setting::set('credit_expiry_months', '12');
        $engine = AiModel::where('slug', 'nexus-high')->first();
        ModelCost::create([
            'ai_model_id' => $engine->id,
            'input_cost_per_mtok' => 1.0, 'output_cost_per_mtok' => 1.0,
            'synced_at' => now(), 'created_at' => now(),
        ]);

        Http::fake([
            'openrouter.ai/api/v1/chat/completions' => Http::response([
                'id' => 'gen-1',
                'model' => 'test/high', // ← ID REAL do motor (nunca pode chegar ao cliente)
                'choices' => [['message' => ['role' => 'assistant', 'content' => 'feito'], 'finish_reason' => 'stop']],
                'usage' => ['prompt_tokens' => 10, 'completion_tokens' => 5],
            ]),
        ]);

        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/chat/completions', $this->body('corrige este typo', 'nexus-high'));

        $response->assertOk();
        // White-label: o cliente vê o tier, nunca "test/high"
        $this->assertEquals('nexus-high', $response->json('model'));
        // Recomendador: typo no High → sugestão de downgrade para o Low
        $response->assertHeader('X-Nexus-Suggestion');
        $suggestion = json_decode($response->headers->get('X-Nexus-Suggestion'), true);
        $this->assertEquals('nexus-low', $suggestion['tier']);
        $this->assertEquals('down', $suggestion['direction']);
    }
}
