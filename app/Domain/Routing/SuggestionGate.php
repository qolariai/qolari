<?php

namespace App\Domain\Routing;

use Illuminate\Support\Facades\Cache;

/**
 * Regras de comportamento do recomendador (2.4):
 *  - máximo 1 sugestão a cada N pedidos do utilizador
 *  - "lembrar escolha": tier recusado 2x deixa de ser sugerido (7 dias)
 */
class SuggestionGate
{
    private const MIN_REQUESTS_BETWEEN = 5;
    private const DISMISS_TTL_DAYS = 7;
    private const MAX_DISMISSES = 2;

    /** Conta um pedido do utilizador (chamar em cada request ao proxy). */
    public function tick(int $userId): void
    {
        $key = "nexus:gate:count:{$userId}";
        Cache::add($key, 0, now()->endOfDay());
        Cache::increment($key);
    }

    /** Pode mostrar sugestão para este tier neste pedido? */
    public function allows(int $userId, string $tierSlug): bool
    {
        if ($this->dismissCount($userId, $tierSlug) >= self::MAX_DISMISSES) {
            return false;
        }

        $count = (int) Cache::get("nexus:gate:count:{$userId}", 0);
        $lastShown = (int) Cache::get("nexus:gate:last:{$userId}", -self::MIN_REQUESTS_BETWEEN);

        return ($count - $lastShown) >= self::MIN_REQUESTS_BETWEEN;
    }

    /** Regista que uma sugestão foi mostrada. */
    public function recordShown(int $userId): void
    {
        $count = (int) Cache::get("nexus:gate:count:{$userId}", 0);
        Cache::put("nexus:gate:last:{$userId}", $count, now()->endOfDay());
    }

    /** Cliente recusou uma sugestão deste tier. */
    public function dismiss(int $userId, string $tierSlug): void
    {
        $key = "nexus:gate:dismiss:{$userId}:{$tierSlug}";
        Cache::add($key, 0, now()->addDays(self::DISMISS_TTL_DAYS));
        Cache::increment($key);
    }

    private function dismissCount(int $userId, string $tierSlug): int
    {
        return (int) Cache::get("nexus:gate:dismiss:{$userId}:{$tierSlug}", 0);
    }
}
