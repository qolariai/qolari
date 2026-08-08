<?php

namespace App\Domain\Geo;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;

/**
 * Geo-detecção leve por IP (geo-pricing Angola).
 * Usa ipapi.co (free tier, HTTPS) com cache de 24h por IP e falha
 * silenciosa — qualquer erro devolve null (frontend fica em EUR).
 */
class GeoService
{
    public function countryForIp(?string $ip): ?string
    {
        if (!$ip || $this->isPrivateIp($ip)) {
            return null;
        }

        return Cache::remember("geo_country_{$ip}", now()->addHours(24), function () use ($ip) {
            try {
                $response = Http::timeout(3)->get("https://ipapi.co/{$ip}/country/");
                $code = strtoupper(trim((string) $response->body()));

                return $response->successful() && preg_match('/^[A-Z]{2}$/', $code) === 1
                    ? $code
                    : null;
            } catch (\Throwable) {
                return null;
            }
        });
    }

    /**
     * Moeda sugerida a partir do país. Só Angola tem tratamento
     * especial (AOA/Multicaixa); o resto fica no default (EUR).
     */
    public function suggestedCurrency(?string $country): ?string
    {
        return $country === 'AO' ? 'AOA' : null;
    }

    private function isPrivateIp(string $ip): bool
    {
        return filter_var(
            $ip,
            FILTER_VALIDATE_IP,
            FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE
        ) === false;
    }
}
