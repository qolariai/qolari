<?php

namespace Tests\Feature;

use App\Domain\Proxy\UsageMeter;
use App\Jobs\ReconcileStreamUsage;
use App\Models\AiModel;
use App\Models\ModelCost;
use App\Models\Setting;
use App\Models\UsageLog;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class StreamMeteringTest extends TestCase
{
    use RefreshDatabase;

    private UsageMeter $meter;
    private User $user;
    private AiModel $model;

    protected function setUp(): void
    {
        parent::setUp();

        $this->meter = app(UsageMeter::class);
        $this->user = User::factory()->create();
        $this->model = AiModel::create([
            'slug' => 'test',
            'display_name' => 'Test Model',
            'provider' => 'openrouter',
            'provider_model_id' => 'test/model',
            'margin_multiplier' => 3.00,
            'is_active' => true,
        ]);

        // Custo: $1/MTok input, $2/MTok output
        ModelCost::create([
            'ai_model_id' => $this->model->id,
            'input_cost_per_mtok' => 1.0,
            'output_cost_per_mtok' => 2.0,
            'synced_at' => now(),
            'created_at' => now(),
        ]);

        Setting::create([
            'key' => 'credit_expiry_months',
            'value' => '12',
            'is_secret' => false,
            'updated_at' => now(),
        ]);
        // Secret: usar o setter estatico (encripta corretamente)
        Setting::set('openrouter_api_key', 'test-key', true);
    }

    public function test_meter_debits_with_margin_and_logs(): void
    {
        // Credita saldo suficiente
        app(\App\Domain\Wallet\WalletService::class)->credit($this->user->id, $this->model->id, 10.00);

        // 100k prompt ($0.10) + 50k completion ($0.10) = $0.20 custo → $0.60 debitado (3x)
        $log = $this->meter->meter(
            userId: $this->user->id,
            aiModelId: $this->model->id,
            requestId: 'req-1',
            promptTokens: 100_000,
            completionTokens: 50_000,
        );

        $this->assertEquals('ok', $log->status);
        $this->assertEqualsWithDelta(0.20, (float) $log->cost_usd, 0.000001);
        $this->assertEqualsWithDelta(0.60, (float) $log->charged_usd, 0.000001);
        $this->assertEqualsWithDelta(9.40, \App\Models\Wallet::where('user_id', $this->user->id)->first()->balance, 0.000001);
    }

    public function test_pending_log_is_created_without_debit(): void
    {
        $log = $this->meter->recordPending($this->user->id, $this->model->id, 'req-2', 'gen-abc');

        $this->assertEquals('pending', $log->status);
        $this->assertEquals('gen-abc', $log->generation_id);
        $this->assertEquals(0, (float) $log->charged_usd);
    }

    public function test_reconcile_job_meters_from_generation_endpoint(): void
    {
        app(\App\Domain\Wallet\WalletService::class)->credit($this->user->id, $this->model->id, 10.00);
        $this->meter->recordPending($this->user->id, $this->model->id, 'req-3', 'gen-xyz');

        Http::fake([
            'openrouter.ai/api/v1/generation*' => Http::response([
                'data' => [
                    'id' => 'gen-xyz',
                    'tokens_prompt' => 200_000,
                    'tokens_completion' => 100_000,
                ],
            ]),
        ]);

        (new ReconcileStreamUsage('req-3', 'gen-xyz', 1, 1))->handle($this->meter);

        $log = UsageLog::where('request_id', 'req-3')->first();

        $this->assertEquals('ok', $log->status);
        $this->assertEquals(200_000, $log->prompt_tokens);
        $this->assertEquals(100_000, $log->completion_tokens);
        // $0.20 + $0.20 = $0.40 custo → $1.20 debitado
        $this->assertEqualsWithDelta(1.20, (float) $log->charged_usd, 0.000001);
    }

    public function test_reconcile_job_ignores_non_pending_logs(): void
    {
        $this->meter->meter($this->user->id, $this->model->id, 'req-4', 1000, 500);

        Http::fake([
            'openrouter.ai/api/v1/generation*' => Http::response([
                'data' => ['tokens_prompt' => 999_999, 'tokens_completion' => 999_999],
            ]),
        ]);

        (new ReconcileStreamUsage('req-4', 'gen-z', 1, 1))->handle($this->meter);

        $log = UsageLog::where('request_id', 'req-4')->first();
        $this->assertEquals(1000, $log->prompt_tokens); // inalterado
        Http::assertNothingSent();
    }
}
