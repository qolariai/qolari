<?php

namespace App\Jobs;

use App\Models\AiModel;
use App\Models\ModelCost;
use App\Models\Setting;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Sincroniza precos de custo da OpenRouter (por milhao de tokens).
 * Corre diariamente.
 */
class SyncModelCosts implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(): void
    {
        $apiKey = Setting::get('openrouter_api_key');
        if (!$apiKey) {
            Log::warning('SyncModelCosts: openrouter_api_key nao configurada.');
            return;
        }

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $apiKey,
        ])->get('https://openrouter.ai/api/v1/models');

        if ($response->failed()) {
            Log::error('SyncModelCosts: falha ao contactar OpenRouter.', [
                'status' => $response->status(),
            ]);
            return;
        }

        $models = collect($response->json('data', []))->keyBy('id');

        AiModel::where('provider', 'openrouter')->each(function (AiModel $aiModel) use ($models) {
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

        Log::info('SyncModelCosts: concluido.');
    }
}
