<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * LEDGER IMUTAVEL — append-only.
 * Nunca UPDATE, nunca DELETE. Sem updated_at.
 */
class LedgerEntry extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'wallet_id', 'type', 'amount', 'balance_after', 'credit_lot_id',
        'reference_type', 'reference_id', 'idempotency_key', 'meta', 'created_at',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:4',
            'balance_after' => 'decimal:4',
            'meta' => 'array',
            'created_at' => 'datetime',
        ];
    }

    public function wallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class);
    }

    public function creditLot(): BelongsTo
    {
        return $this->belongsTo(CreditLot::class);
    }

    /**
     * Protecao: impedir update e delete a nivel de modelo.
     */
    public function update(array $attributes = [], array $options = []): bool
    {
        throw new \RuntimeException('LedgerEntry e imutavel. UPDATE nao e permitido.');
    }

    public function delete(): ?bool
    {
        throw new \RuntimeException('LedgerEntry e imutavel. DELETE nao e permitido.');
    }
}
