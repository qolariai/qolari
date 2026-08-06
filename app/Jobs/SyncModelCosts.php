<?php

namespace App\Jobs;

use App\Domain\Proxy\AiProviderResolver;
use App\Models\AiModel;
use App\Models\ModelCost;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Sincroniza precos de custo dos providers com catalogo remoto
 * (supports_catalog=true em config/ai_providers.php — hoje so a OpenRouter).
 * Corre diariamente.
 *
 * Modelos de providers diretos (DeepSeek, NVIDIA, ...) NAO sao tocados:
 * os seus custos sao geridos manualmente no admin.
 */
class SyncModelCosts implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(AiProviderResolver $providers): void
    {
        foreach ($providers->catalogProviders() as $slug => $provider) {
            $this->syncProvider($slug, $provider);
        }

        Log::info('SyncModelCosts: concluido.');
    }

    private function syncProvider(string $slug, array $provider): void
    {
        if (!$provider['api_key']) {
            Log::warning("SyncModelCosts: API key do provider '$slug' nao configurada.");
            return;
        }

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $provider['api_key'],
        ])->get($provider['base_url'] . '/models');

        if ($response->failed()) {
            Log::error("SyncModelCosts: falha ao contactar o provider '$slug'.", [
                'status' => $response->status(),
            ]);
            return;
        }

        $models = collect($response->json('data', []))->keyBy('id');

        AiModel::where('provider', $slug)->each(function (AiModel $aiModel) use ($models) {
            $remote = $models->get($aiModel->provider_model_id);
            if (!$remote || !isset($remote['pricing'])) {
                return;
            }

            // Guard: modelos ':free' custam $0 na OpenRouter — nunca sincronizar
            // custos deles (mataria a faturacao em dev/staging; em producao nem
            // deviam existir). Capacidades continuam a sincronizar.
            $isFreeTier = str_ends_with($aiModel->provider_model_id, ':free');

            if (!$isFreeTier) {
                // OpenRouter retorna preco por token; converter para por MTok
                $inputPerMtok = (float) ($remote['pricing']['prompt'] ?? 0) * 1_000_000;
                $outputPerMtok = (float) ($remote['pricing']['completion'] ?? 0) * 1_000_000;

                ModelCost::create([
                    'ai_model_id' => $aiModel->id,
                    'input_cost_per_mtok' => round($inputPerMtok, 6),
                    'output_cost_per_mtok' => round($outputPerMtok, 6),
                    'synced_at' => now(),
                    'created_at' => now(),
                ]);
            }

            // Capacidades dinamicas (1.7): visao + contexto, sem logica hardcoded
            $inputModalities = $remote['architecture']['input_modalities'] ?? [];
            $aiModel->supports_vision = in_array('image', $inputModalities, true);
            $aiModel->context_limit = $remote['context_length'] ?? null;
            $aiModel->save();
        });
    }
}
