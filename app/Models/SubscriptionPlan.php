<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Plano de subscrição do Chat (mundo separado da wallet de créditos).
 * Nome white-label: o admin edita, o cliente nunca vê nomes de providers.
 */
class SubscriptionPlan extends Model
{
    protected $fillable = [
        'slug', 'name', 'token_limit', 'period_days', 'throttle_percent',
        'stripe_price_id', 'is_active', 'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'token_limit' => 'integer',
            'period_days' => 'integer',
            'throttle_percent' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    public function prices(): HasMany
    {
        return $this->hasMany(SubscriptionPlanPrice::class, 'plan_id');
    }

    public function priceFor(string $currency): ?SubscriptionPlanPrice
    {
        return $this->prices()->where('currency', strtoupper($currency))->first();
    }

    public function subscriptions(): HasMany
    {
        return $this->hasMany(Subscription::class, 'plan_id');
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
