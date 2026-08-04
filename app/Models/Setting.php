<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Crypt;

class Setting extends Model
{
    protected $primaryKey = 'key';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = ['key', 'value', 'is_secret'];

    protected function casts(): array
    {
        return [
            'is_secret' => 'boolean',
            'updated_at' => 'datetime',
        ];
    }

    public function getValueAttribute(?string $value): ?string
    {
        if ($value === null) {
            return null;
        }

        if ($this->is_secret) {
            try {
                return Crypt::decryptString($value);
            } catch (\Exception) {
                return null;
            }
        }

        return $value;
    }

    public function setValueAttribute(?string $value): void
    {
        if ($value !== null && $this->is_secret) {
            $this->attributes['value'] = Crypt::encryptString($value);
        } else {
            $this->attributes['value'] = $value;
        }
    }

    public static function get(string $key, ?string $default = null): ?string
    {
        $setting = static::find($key);
        return $setting?->value ?? $default;
    }

    public static function set(string $key, ?string $value, bool $isSecret = false): void
    {
        // Ordem importa: is_secret tem de estar definido ANTES de value,
        // senao o mutator setValueAttribute nao encripta (mas a leitura desencripta → null)
        $setting = static::firstOrNew(['key' => $key]);
        $setting->is_secret = $isSecret;
        $setting->value = $value;
        $setting->updated_at = now();
        $setting->save();
    }
}
