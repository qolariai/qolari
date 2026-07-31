<?php

namespace Tests\Feature;

use App\Domain\Wallet\InsufficientBalanceException;
use App\Domain\Wallet\WalletService;
use App\Models\AiModel;
use App\Models\LedgerEntry;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WalletServiceTest extends TestCase
{
    use RefreshDatabase;

    private WalletService $service;
    private User $user;
    private AiModel $model;

    protected function setUp(): void
    {
        parent::setUp();

        $this->service = app(WalletService::class);
        $this->user = User::factory()->create();
        $this->model = AiModel::create([
            'slug' => 'test',
            'display_name' => 'Test Model',
            'provider' => 'openrouter',
            'provider_model_id' => 'test/model',
            'margin_multiplier' => 3.00,
            'is_active' => true,
        ]);

        // Setting necessaria para expiracao
        \App\Models\Setting::create([
            'key' => 'credit_expiry_months',
            'value' => '12',
            'is_secret' => false,
            'updated_at' => now(),
        ]);
    }

    public function test_credit_creates_lot_and_ledger_entry(): void
    {
        $entry = $this->service->credit($this->user->id, $this->model->id, 10.00);

        $this->assertEquals('purchase', $entry->type);
        $this->assertEquals(10.00, (float) $entry->amount);
        $this->assertEquals(10.00, (float) $entry->balance_after);

        // Wallet cache atualizada
        $wallet = Wallet::where('user_id', $this->user->id)->first();
        $this->assertEquals(10.00, (float) $wallet->balance);

        // Lote criado
        $this->assertDatabaseHas('credit_lots', [
            'wallet_id' => $wallet->id,
            'amount' => 10.00,
            'remaining' => 10.00,
        ]);
    }

    public function test_debit_consumes_fifo_and_updates_balance(): void
    {
        // Credita 2 lotes
        $this->service->credit($this->user->id, $this->model->id, 5.00, null, 'purchase', 'key-1');
        $this->service->credit($this->user->id, $this->model->id, 10.00, null, 'purchase', 'key-2');

        // Debita 7 (deve consumir 5 do 1o lote + 2 do 2o)
        $entry = $this->service->debit($this->user->id, $this->model->id, 7.00, 'debit-1');

        $this->assertEquals('debit', $entry->type);
        $this->assertEquals(-7.00, (float) $entry->amount);
        $this->assertEquals(8.00, (float) $entry->balance_after);

        // Balance cache
        $this->assertEquals(8.00, $this->service->balance($this->user->id, $this->model->id));
    }

    public function test_debit_is_idempotent(): void
    {
        $this->service->credit($this->user->id, $this->model->id, 10.00);

        $entry1 = $this->service->debit($this->user->id, $this->model->id, 3.00, 'same-key');
        $entry2 = $this->service->debit($this->user->id, $this->model->id, 3.00, 'same-key');

        // Mesmo ID — nao duplicou
        $this->assertEquals($entry1->id, $entry2->id);
        $this->assertEquals(7.00, $this->service->balance($this->user->id, $this->model->id));
    }

    public function test_debit_throws_on_insufficient_balance(): void
    {
        $this->service->credit($this->user->id, $this->model->id, 2.00);

        $this->expectException(InsufficientBalanceException::class);
        $this->service->debit($this->user->id, $this->model->id, 5.00, 'debit-fail');
    }

    public function test_ledger_is_immutable(): void
    {
        $entry = $this->service->credit($this->user->id, $this->model->id, 10.00);

        $this->expectException(\RuntimeException::class);
        $entry->update(['amount' => 999]);
    }

    public function test_ledger_sum_equals_wallet_balance(): void
    {
        $this->service->credit($this->user->id, $this->model->id, 20.00);
        $this->service->debit($this->user->id, $this->model->id, 5.50, 'd1');
        $this->service->credit($this->user->id, $this->model->id, 3.00, null, 'bonus');

        $wallet = Wallet::where('user_id', $this->user->id)
            ->where('ai_model_id', $this->model->id)
            ->first();

        $ledgerSum = LedgerEntry::where('wallet_id', $wallet->id)->sum('amount');

        $this->assertEqualsWithDelta((float) $wallet->balance, (float) $ledgerSum, 0.0001);
    }
}
