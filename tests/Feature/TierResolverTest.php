<?php

namespace Tests\Feature;

use App\Domain\Routing\TierResolver;
use App\Domain\Proxy\UsageMeter;
use App\Domain\Wallet\WalletService;
use App\Models\AiModel;
use App\Models\ModelCost;
use App\Models\Setting;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TierResolverTest extends TestCase
{
    use RefreshDatabase;

    private TierResolver $resolver;
    private AiModel $high;
    private AiModel $medium;
    private AiModel $low;
    private AiModel $vision;

    protected function setUp(): void
    {
        parent::setUp();

        $this->resolver = app(TierResolver::class);

        $this->high = AiModel::create([
            'slug' => 'nexus-high', 'display_name' => 'Nexus High', 'provider' => 'openrouter',
            'provider_model_id' => 'test/high', 'supports_vision' => true,
            'margin_multiplier' => 3.00, 'is_active' => true, 'sort_order' => 1,
        ]);
        $this->medium = AiModel::create([
            'slug' => 'nexus-medium', 'display_name' => 'Nexus Medium', 'provider' => 'openrouter',
            'provider_model_id' => 'test/medium', 'supports_vision' => false,
            'margin_multiplier' => 3.00, 'is_active' => true, 'sort_order' => 2,
        ]);
        $this->low = AiModel::create([
            'slug' => 'nexus-low', 'display_name' => 'Nexus Low', 'provider' => 'openrouter',
            'provider_model_id' => 'test/low', 'supports_vision' => false,
            'margin_multiplier' => 3.00, 'is_active' => true, 'sort_order' => 3,
        ]);
        $this->vision = AiModel::create([
            'slug' => 'nexus-vision', 'display_name' => 'Nexus Vision', 'provider' => 'openrouter',
            'provider_model_id' => 'test/vision', 'supports_vision' => true,
            'margin_multiplier' => 3.00, 'is_active' => true, 'sort_order' => 99,
        ]);
    }

    private function textBody(?string $model): array
    {
        return [
            'model' => $model,
            'messages' => [['role' => 'user', 'content' => 'corrige este typo']],
        ];
    }

    private function imageBody(string $model): array
    {
        return [
            'model' => $model,
            'messages' => [[
                'role' => 'user',
                'content' => [
                    ['type' => 'text', 'text' => 'o que vês?'],
                    ['type' => 'image_url', 'image_url' => ['url' => 'data:image/png;base64,xxx']],
                ],
            ]],
        ];
    }

    public function test_resolves_requested_tier(): void
    {
        $r = $this->resolver->resolve($this->textBody('nexus-medium'));

        $this->assertEquals($this->medium->id, $r->tier->id);
        $this->assertEquals($this->medium->id, $r->engine->id);
        $this->assertFalse($r->routed);
    }

    public function test_accepts_provider_prefixed_slug(): void
    {
        $r = $this->resolver->resolve($this->textBody('qolari/nexus-low'));

        $this->assertEquals($this->low->id, $r->tier->id);
    }

    public function test_legacy_fallback_without_model(): void
    {
        $r = $this->resolver->resolve(['messages' => [['role' => 'user', 'content' => 'ola']]]);

        // Primeiro ativo por sort_order = nexus-high
        $this->assertEquals($this->high->id, $r->tier->id);
    }

    public function test_silent_vision_routing_when_tier_has_no_vision(): void
    {
        $r = $this->resolver->resolve($this->imageBody('nexus-medium'));

        $this->assertEquals($this->medium->id, $r->tier->id, 'tier comercial mantém-se Medium');
        $this->assertEquals($this->vision->id, $r->engine->id, 'motor passa a Vision');
        $this->assertTrue($r->routed);
    }

    public function test_no_routing_when_tier_supports_vision(): void
    {
        $r = $this->resolver->resolve($this->imageBody('nexus-high'));

        $this->assertEquals($this->high->id, $r->engine->id);
        $this->assertFalse($r->routed);
    }

    public function test_no_routing_for_text_only(): void
    {
        $r = $this->resolver->resolve($this->textBody('nexus-low'));

        $this->assertEquals($this->low->id, $r->engine->id);
        $this->assertFalse($r->routed);
    }

    public function test_vision_routing_charges_tier_margin_with_engine_cost(): void
    {
        Setting::create(['key' => 'credit_expiry_months', 'value' => '12', 'is_secret' => false, 'updated_at' => now()]);

        // Medium: custo $1/MTok. Vision: custo $0.10/MTok (super barato)
        ModelCost::create(['ai_model_id' => $this->medium->id, 'input_cost_per_mtok' => 1.0, 'output_cost_per_mtok' => 1.0, 'synced_at' => now(), 'created_at' => now()]);
        ModelCost::create(['ai_model_id' => $this->vision->id, 'input_cost_per_mtok' => 0.1, 'output_cost_per_mtok' => 0.1, 'synced_at' => now(), 'created_at' => now()]);

        $user = User::factory()->create();
        app(WalletService::class)->credit($user->id, $this->medium->id, 10.00);

        $r = $this->resolver->resolve($this->imageBody('nexus-medium'));
        $this->assertTrue($r->routed);

        $log = app(UsageMeter::class)->meter(
            userId: $user->id,
            tierModelId: $r->tier->id,
            engineModelId: $r->engine->id,
            requestId: 'req-vision-1',
            promptTokens: 1_000_000,
            completionTokens: 0,
        );

        // Custo real do Vision ($0.10) × margem do Medium (3x) = $0.30
        // (Se fosse o Medium real: $1 × 3 = $3 → a margem silenciosa lucra $2.70)
        $this->assertEqualsWithDelta(0.10, (float) $log->cost_usd, 0.000001);
        $this->assertEqualsWithDelta(0.30, (float) $log->charged_usd, 0.000001);
        $this->assertEquals($this->medium->id, $log->ai_model_id);
        $this->assertEquals($this->vision->id, $log->engine_model_id);

        // Débito saiu da wallet do MEDIUM (tier escolhido), não do Vision
        $this->assertEqualsWithDelta(9.70, (float) Wallet::where('user_id', $user->id)->where('ai_model_id', $this->medium->id)->first()->balance, 0.000001);
    }
}
