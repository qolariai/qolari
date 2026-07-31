<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CreditLot extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'wallet_id', 'order_id', 'amount', 'remaining', 'expires_at', 'created_at',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:4',
            'remaining' => 'decimal:4',
            'expires_at' => 'datetime',
            'created_at' => 'datetime',
        ];
    }

    public function wallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class);
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function scopeAvailable($query)
    {
        return $query->where('remaining', '>', 0)->where('expires_at', '>', now());
    }

    public function scopeExpired($query)
    {
        return $query->where('remaining', '>', 0)->where('expires_at', '<=', now());
    }
}
