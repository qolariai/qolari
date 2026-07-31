<?php

namespace App\Jobs;

use App\Models\CreditLot;
use App\Models\LedgerEntry;
use App\Models\Wallet;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Expira lotes de credito com mais de 12 meses.
 * Corre mensalmente.
 */
class ExpireCreditLots implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(): void
    {
        $expiredLots = CreditLot::expired()->get();
        $count = 0;

        foreach ($expiredLots as $lot) {
            DB::transaction(function () use ($lot, &$count) {
                $wallet = Wallet::lockForUpdate()->find($lot->wallet_id);
                if (!$wallet) {
                    return;
                }

                $expiredAmount = (float) $lot->remaining;

                // Zera o lote
                $lot->remaining = 0;
                $lot->save();

                // Atualiza balance cache
                $newBalance = (float) $wallet->balance - $expiredAmount;
                $wallet->balance = max(0, $newBalance);
                $wallet->save();

                // Ledger entry de expiracao
                LedgerEntry::create([
                    'wallet_id' => $wallet->id,
                    'type' => 'expiration',
                    'amount' => -$expiredAmount,
                    'balance_after' => $wallet->balance,
                    'credit_lot_id' => $lot->id,
                    'reference_type' => null,
                    'reference_id' => null,
                    'idempotency_key' => "expire-lot-{$lot->id}",
                    'meta' => ['lot_amount' => $lot->amount, 'expired_at' => now()->toIso8601String()],
                    'created_at' => now(),
                ]);

                $count++;
            });
        }

        Log::info("ExpireCreditLots: {$count} lotes expirados.");
    }
}
