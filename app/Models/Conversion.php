<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Conversion extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id', 'from_wallet_id', 'to_wallet_id', 'amount',
        'fee_percent', 'fee_amount', 'credited_amount', 'created_at',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:4',
            'fee_percent' => 'decimal:2',
            'fee_amount' => 'decimal:4',
            'credited_amount' => 'decimal:4',
            'created_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function fromWallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class, 'from_wallet_id');
    }

    public function toWallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class, 'to_wallet_id');
    }
}
