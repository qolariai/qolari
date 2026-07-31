<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Product extends Model
{
    protected $fillable = [
        'type', 'ai_model_id', 'name', 'description', 'credits_usd',
        'repo_reference', 'delivery_notes', 'is_active', 'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'credits_usd' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }

    public function aiModel(): BelongsTo
    {
        return $this->belongsTo(AiModel::class);
    }

    public function prices(): HasMany
    {
        return $this->hasMany(ProductPrice::class);
    }

    public function priceFor(string $currency): ?ProductPrice
    {
        return $this->prices()->where('currency', $currency)->first();
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
