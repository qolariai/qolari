<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Commission extends Model
{
    protected $fillable = [
        'promo_code_id', 'order_id', 'amount_usd', 'status', 'paid_at', 'notes',
    ];

    protected function casts(): array
    {
        return [
            'amount_usd' => 'decimal:2',
            'paid_at' => 'datetime',
        ];
    }

    public function promoCode(): BelongsTo
    {
        return $this->belongsTo(PromoCode::class);
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}
