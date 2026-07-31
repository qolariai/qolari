<?php

namespace App\Domain\Wallet;

use App\Models\CreditLot;
use App\Models\LedgerEntry;
use App\Models\Setting;
use App\Models\Wallet;
use Illuminate\Support\Facades\DB;

class WalletService
{
    /**
     * Credita saldo: cria lote + ledger entry + atualiza cache da wallet.
     */
    public function credit(
        int $userId,
        int $aiModelId,
        float $amountUsd,
        ?int $orderId = null,
        string $type = 'purchase',
        ?string $idempotencyKey = null,
        ?array $meta = null,
    ): LedgerEntry {
        return DB::transaction(function () use ($userId, $aiModelId, $amountUsd, $orderId, $type, $idempotencyKey, $meta) {
            // Idempotencia: se ja existe esta key, retorna a entry existente
            if ($idempotencyKey) {
                $existing = LedgerEntry::where('idempotency_key', $idempotencyKey)->first();
                if ($existing) {
                    return $existing;
                }
            }

            // Obtem ou cria wallet com lock
            $wallet = Wallet::lockForUpdate()->firstOrCreate(
                ['user_id' => $userId, 'ai_model_id' => $aiModelId],
                ['balance' => 0]
            );

            $expiryMonths = (int) (Setting::get('credit_expiry_months', '12'));

            // Cria lote de credito
            $lot = CreditLot::create([
                'wallet_id' => $wallet->id,
                'order_id' => $orderId,
                'amount' => $amountUsd,
                'remaining' => $amountUsd,
                'expires_at' => now()->addMonths($expiryMonths),
                'created_at' => now(),
            ]);

            // Atualiza balance cache
            $newBalance = (float) $wallet->balance + $amountUsd;
            $wallet->balance = $newBalance;
            $wallet->save();

            // Ledger entry (append-only)
            return LedgerEntry::create([
                'wallet_id' => $wallet->id,
                'type' => $type,
                'amount' => $amountUsd,
                'balance_after' => $newBalance,
                'credit_lot_id' => $lot->id,
                'reference_type' => $orderId ? 'order' : null,
                'reference_id' => $orderId,
                'idempotency_key' => $idempotencyKey,
                'meta' => $meta,
                'created_at' => now(),
            ]);
        });
    }

    /**
     * Debita saldo via FIFO nos lotes. Idempotente por idempotencyKey.
     * Lanca excecao se saldo insuficiente.
     */
    public function debit(
        int $userId,
        int $aiModelId,
        float $amountUsd,
        string $idempotencyKey,
        ?string $referenceType = null,
        ?int $referenceId = null,
        ?array $meta = null,
    ): LedgerEntry {
        return DB::transaction(function () use ($userId, $aiModelId, $amountUsd, $idempotencyKey, $referenceType, $referenceId, $meta) {
            // Idempotencia: nunca duplicar um debito
            $existing = LedgerEntry::where('idempotency_key', $idempotencyKey)->first();
            if ($existing) {
                return $existing;
            }

            // Wallet com lock
            $wallet = Wallet::lockForUpdate()
                ->where('user_id', $userId)
                ->where('ai_model_id', $aiModelId)
                ->first();

            if (!$wallet || (float) $wallet->balance < $amountUsd) {
                throw new InsufficientBalanceException(
                    "Saldo insuficiente. Necessario: \${$amountUsd}, disponivel: $" . ($wallet?->balance ?? '0.00')
                );
            }

            $remaining = $amountUsd;

            // Consumo FIFO: lotes ordenados por expires_at
            $lots = CreditLot::where('wallet_id', $wallet->id)
                ->where('remaining', '>', 0)
                ->where('expires_at', '>', now())
                ->orderBy('expires_at')
                ->lockForUpdate()
                ->get();

            foreach ($lots as $lot) {
                if ($remaining <= 0) {
                    break;
                }

                $deduct = min($remaining, (float) $lot->remaining);
                $lot->remaining = (float) $lot->remaining - $deduct;
                $lot->save();
                $remaining -= $deduct;
            }

            if ($remaining > 0.0001) {
                throw new InsufficientBalanceException(
                    "Saldo insuficiente nos lotes (FIFO). Faltam: \${$remaining}"
                );
            }

            // Atualiza balance cache
            $newBalance = (float) $wallet->balance - $amountUsd;
            $wallet->balance = $newBalance;
            $wallet->save();

            // Ledger entry
            return LedgerEntry::create([
                'wallet_id' => $wallet->id,
                'type' => 'debit',
                'amount' => -$amountUsd,
                'balance_after' => $newBalance,
                'credit_lot_id' => null,
                'reference_type' => $referenceType,
                'reference_id' => $referenceId,
                'idempotency_key' => $idempotencyKey,
                'meta' => $meta,
                'created_at' => now(),
            ]);
        });
    }

    /**
     * Saldo atual (cache da wallet).
     */
    public function balance(int $userId, int $aiModelId): float
    {
        $wallet = Wallet::where('user_id', $userId)
            ->where('ai_model_id', $aiModelId)
            ->first();

        return $wallet ? (float) $wallet->balance : 0.0;
    }

    /**
     * Ajuste manual pelo admin (positivo ou negativo).
     */
    public function adminAdjust(
        int $userId,
        int $aiModelId,
        float $amountUsd,
        string $reason,
    ): LedgerEntry {
        return DB::transaction(function () use ($userId, $aiModelId, $amountUsd, $reason) {
            $wallet = Wallet::lockForUpdate()->firstOrCreate(
                ['user_id' => $userId, 'ai_model_id' => $aiModelId],
                ['balance' => 0]
            );

            $newBalance = (float) $wallet->balance + $amountUsd;
            $wallet->balance = $newBalance;
            $wallet->save();

            // Se positivo, cria lote
            $lotId = null;
            if ($amountUsd > 0) {
                $expiryMonths = (int) (Setting::get('credit_expiry_months', '12'));
                $lot = CreditLot::create([
                    'wallet_id' => $wallet->id,
                    'order_id' => null,
                    'amount' => $amountUsd,
                    'remaining' => $amountUsd,
                    'expires_at' => now()->addMonths($expiryMonths),
                    'created_at' => now(),
                ]);
                $lotId = $lot->id;
            }

            return LedgerEntry::create([
                'wallet_id' => $wallet->id,
                'type' => 'admin_adjustment',
                'amount' => $amountUsd,
                'balance_after' => $newBalance,
                'credit_lot_id' => $lotId,
                'reference_type' => null,
                'reference_id' => null,
                'idempotency_key' => null,
                'meta' => ['reason' => $reason],
                'created_at' => now(),
            ]);
        });
    }
}
