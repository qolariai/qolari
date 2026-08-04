<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AiModel extends Model
{
    protected $fillable = [
        'slug', 'display_name', 'description', 'provider',
        'provider_model_id', 'supports_vision', 'context_limit',
        'margin_multiplier', 'is_active', 'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'margin_multiplier' => 'decimal:2',
            'is_active' => 'boolean',
            'supports_vision' => 'boolean',
        ];
    }

    public function modelCosts(): HasMany
    {
        return $this->hasMany(ModelCost::class);
    }

    public function latestCost(): ?ModelCost
    {
        return $this->modelCosts()->latest('synced_at')->first();
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function wallets(): HasMany
    {
        return $this->hasMany(Wallet::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
