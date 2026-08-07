<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * FASE DE TESTES: aponta todos os tiers ativos para modelos NVIDIA NIM
 * (gratuitos, key já configurada) enquanto não há key DeepSeek. Serve os
 * dois mundos — Code (proxy/wallets) e Chat (subscrição) — porque ambos
 * resolvem o motor via TierResolver/AiProviderResolver.
 *
 * Para restaurar o mapeamento oficial de produção (DeepSeek direto),
 * correr: php artisan db:seed --class=AiModelsSeeder
 */
class NvidiaTestModelsSeeder extends Seeder
{
    private const MODELS = [
        'nexus-high' => [
            'provider_model_id' => 'meta/llama-3.3-70b-instruct',
            'supports_vision' => false,
            'is_active' => true,
        ],
        'nexus-medium' => [
            'provider_model_id' => 'meta/llama-3.1-70b-instruct',
            'supports_vision' => false,
            'is_active' => true,
        ],
        'nexus-low' => [
            'provider_model_id' => 'meta/llama-3.1-8b-instruct',
            'supports_vision' => false,
            'is_active' => true,
        ],
        // Vision ativo na fase de testes: permite validar o routing
        // silencioso (imagem → nexus-vision) com um motor NVIDIA gratuito.
        'nexus-vision' => [
            'provider_model_id' => 'meta/llama-3.2-90b-vision-instruct',
            'supports_vision' => true,
            'is_active' => true,
        ],
        // Legacy: Products antigos referenciam este slug.
        'qolari' => [
            'provider_model_id' => 'meta/llama-3.1-70b-instruct',
            'supports_vision' => false,
            'is_active' => true,
        ],
    ];

    public function run(): void
    {
        foreach (self::MODELS as $slug => $model) {
            DB::table('ai_models')->where('slug', $slug)->update([
                'provider' => 'nvidia',
                'provider_model_id' => $model['provider_model_id'],
                'supports_vision' => $model['supports_vision'],
                'is_active' => $model['is_active'],
                'updated_at' => now(),
            ]);

            $this->ensureZeroCost($slug);
        }
    }

    /** Custos 0/0 (NVIDIA NIM gratuito) só se o modelo ainda não tiver custos. */
    private function ensureZeroCost(string $slug): void
    {
        $aiModelId = DB::table('ai_models')->where('slug', $slug)->value('id');
        if (!$aiModelId) {
            return;
        }

        if (DB::table('model_costs')->where('ai_model_id', $aiModelId)->exists()) {
            return;
        }

        DB::table('model_costs')->insert([
            'ai_model_id' => $aiModelId,
            'input_cost_per_mtok' => 0,
            'output_cost_per_mtok' => 0,
            'synced_at' => now(),
            'created_at' => now(),
        ]);
    }
}
