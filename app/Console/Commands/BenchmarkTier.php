<?php

namespace App\Console\Commands;

use App\Domain\Proxy\AiProviderResolver;
use App\Models\AiModel;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

/**
 * Suite de regressão dos tiers Nexus (Fase 4.2).
 *
 * Corre a suite benchmark/tier-suite.php contra o motor de um tier
 * DIRETAMENTE no provider upstream (sem billing — é benchmark interno).
 *
 * Uso:
 *   php artisan qolari:benchmark              → todos os tiers ativos
 *   php artisan qolari:benchmark nexus-low    → um tier
 *   php artisan qolari:benchmark --category=simple
 *
 * Regra: correr SEMPRE antes de trocar o motor de um tier (MODEL_CHANGELOG).
 */
class BenchmarkTier extends Command
{
    protected $signature = 'qolari:benchmark
                            {tier? : slug do tier (nexus-high, nexus-medium, nexus-low, nexus-vision)}
                            {--category= : correr só uma categoria}
                            {--timeout=120 : timeout por prompt (segundos)}';

    protected $description = 'Corre a suite de regressão contra o motor de um tier';

    public function handle(AiProviderResolver $providers): int
    {
        $tiers = $this->argument('tier')
            ? AiModel::where('slug', $this->argument('tier'))->get()
            : AiModel::active()->orderBy('sort_order')->get();

        if ($tiers->isEmpty()) {
            $this->error('Nenhum tier encontrado.');
            return self::FAILURE;
        }

        // Resolve a key de cada provider usado pelos tiers (uma por provider)
        $providerConfigs = [];
        foreach ($tiers as $tier) {
            $providerConfigs[$tier->provider] ??= $providers->forSlug($tier->provider);
        }
        foreach ($providerConfigs as $slug => $config) {
            if (!$config['api_key']) {
                $this->error("API key do provider '$slug' não configurada.");
                return self::FAILURE;
            }
        }

        $suite = require base_path('benchmark/tier-suite.php');
        if ($category = $this->option('category')) {
            $suite = array_values(array_filter($suite, fn ($i) => $i['category'] === $category));
        }

        $globalPass = 0;
        $globalTotal = 0;

        foreach ($tiers as $tier) {
            $this->newLine();
            $this->info("═══ {$tier->display_name} ({$tier->provider_model_id} @ {$tier->provider}) ═══");

            [$pass, $total] = $this->runTier($tier, $suite, $providerConfigs[$tier->provider]);
            $globalPass += $pass;
            $globalTotal += $total;

            $pct = $total ? round($pass / $total * 100) : 0;
            $this->line("  <fg=cyan>SCORE: {$pass}/{$total} ({$pct}%)</>");
        }

        $this->newLine();
        $this->info("TOTAL GERAL: {$globalPass}/{$globalTotal}");

        return $globalPass === $globalTotal ? self::SUCCESS : self::FAILURE;
    }

    /** @return array{0: int, 1: int} [pass, total] */
    private function runTier(AiModel $tier, array $suite, array $provider): array
    {
        $pass = 0;
        $total = 0;

        foreach ($suite as $item) {
            if (($item['requires_vision'] ?? false) && !$tier->supports_vision) {
                $this->line("  <fg=yellow>SKIP</> {$item['name']} (sem visão)");
                continue;
            }

            $total++;
            $started = microtime(true);

            try {
                $response = Http::withHeaders(array_merge([
                    'Authorization' => 'Bearer ' . $provider['api_key'],
                    'Content-Type' => 'application/json',
                ], $provider['headers']))
                    ->timeout((int) $this->option('timeout'))
                    ->post($provider['base_url'] . '/chat/completions', [
                        'model' => $tier->provider_model_id,
                        'messages' => $item['messages'],
                        'max_tokens' => $item['max_tokens'] ?? 300,
                    ]);

                $elapsed = round(microtime(true) - $started, 1);

                if ($response->failed()) {
                    $this->line("  <fg=red>FAIL</> {$item['name']} <fg=red>(HTTP {$response->status()})</>");
                    continue;
                }

                $content = mb_strtolower(
                    $response->json('choices.0.message.content')
                    ?? $response->json('choices.0.message.reasoning')
                    ?? ''
                );

                $ok = $this->checkExpectations($content, $item);
                $tag = $ok ? '<fg=green>PASS</>' : '<fg=red>FAIL</>';
                $this->line("  {$tag} {$item['name']} ({$elapsed}s)");

                if ($ok) {
                    $pass++;
                } else {
                    $preview = mb_substr($content, 0, 120);
                    $this->line("       <fg=gray>↳ {$preview}…</>");
                }
            } catch (\Throwable $e) {
                $this->line("  <fg=red>FAIL</> {$item['name']} <fg=red>({$e->getMessage()})</>");
            }
        }

        return [$pass, $total];
    }

    private function checkExpectations(string $content, array $item): bool
    {
        $any = $item['expect_any'] ?? [];
        $okAny = $any === [] || collect($any)->contains(fn ($k) => str_contains($content, mb_strtolower($k)));

        $absent = $item['expect_absent'] ?? [];
        $okAbsent = collect($absent)->every(fn ($k) => !str_contains($content, mb_strtolower($k)));

        return $okAny && $okAbsent;
    }
}
