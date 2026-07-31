<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ExchangeRate extends Model
{
    protected $primaryKey = 'currency';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = ['currency', 'rate_to_usd'];

    protected function casts(): array
    {
        return [
            'rate_to_usd' => 'decimal:6',
            'updated_at' => 'datetime',
        ];
    }

    public static function toUsd(string $currency, float $amount): float
    {
        if ($currency === 'USD') {
            return $amount;
        }

        $rate = static::find($currency);
        return $rate ? $amount * (float) $rate->rate_to_usd : $amount;
    }
}
