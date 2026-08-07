<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Subscrição Chat do utilizador. O uso de tokens conta aqui (tokens_used)
 * e NUNCA debita a wallet de créditos (Code).
 */
class Subscription extends Model
{
    protected $fillable = [
        'user_id', 'plan_id', 'stripe_subscription_id', 'stripe_customer_id',
        'status', 'current_period_start', 'current_period_end', 'tokens_used',
        'cancel_at_period_end',
    ];

    protected function casts(): array
    {
        return [
            'current_period_start' => 'datetime',
            'current_period_end' => 'datetime',
            'tokens_used' => 'integer',
            'cancel_at_period_end' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function plan(): BelongsTo
    {
        return $this->belongsTo(SubscriptionPlan::class, 'plan_id');
    }

    public function scopeUsable($query)
    {
        return $query->whereIn('status', ['active', 'trialing']);
    }
}
