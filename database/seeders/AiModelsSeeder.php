<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AiModelsSeeder extends Seeder
{
    /**
     * Custos iniciais dos providers diretos (por MTok), só semeados se o
     * modelo ainda não tiver NENHUM custo — nunca sobrescreve edições
     * manuais no admin. O SyncModelCosts não toca nestes providers
     * (supports_catalog=false), por isso os custos vivem aqui/admin.
     */
    private const INITIAL_COSTS = [
        'deepseek-chat' => ['input' => 0.27, 'output' => 1.10],
        'deepseek-reasoner' => ['input' => 0.55, 'output' => 2.19],
        'meta/llama-3.1-8b-instruct' => ['input' => 0.0, 'output' => 0.0], // NVIDIA free tier
    ];

    public function run(): void
    {
        $models = [
            // ── Tiers Nexus (white-label) ──────────────────────────────
            [
                'slug' => 'nexus-high',
                'display_name' => 'Nexus High',
                'description' => 'Tier topo: raciocínio/máxima qualidade (DeepSeek Reasoner direto)',
                'provider' => 'deepseek',
                'provider_model_id' => 'deepseek-reasoner',
                'supports_vision' => false,
                'margin_multiplier' => 3.00,
                'is_active' => true,
                'sort_order' => 1,
            ],
            [
                'slug' => 'nexus-medium',
                'display_name' => 'Nexus Medium',
                'description' => 'Tier equilibrado: motor de produção (DeepSeek Chat direto)',
                'provider' => 'deepseek',
                'provider_model_id' => 'deepseek-chat',
                'supports_vision' => false,
                'margin_multiplier' => 3.00,
                'is_active' => true,
                'sort_order' => 2,
            ],
            [
                'slug' => 'nexus-low',
                'display_name' => 'Nexus Low',
                'description' => 'Tier económico: tarefas simples (NVIDIA NIM free tier — dev/testes)',
                'provider' => 'nvidia',
                'provider_model_id' => 'meta/llama-3.1-8b-instruct',
                'supports_vision' => false,
                'margin_multiplier' => 3.00,
                'is_active' => true,
                'sort_order' => 3,
            ],
            [
                // DORMENTE: DeepSeek não tem visão; reativar quando houver
                // motor de visão direto (GLM futuro). Inativo → o routing
                // silencioso não o escolhe e o upstream devolve erro (SSE error frame).
                'slug' => 'nexus-vision',
                'display_name' => 'Nexus Vision',
                'description' => 'DORMENTE — multimodal económico; entra silenciosamente quando há imagem/ficheiro e o tier ativo não suporta visão',
                'provider' => 'openrouter',
                'provider_model_id' => 'google/gemini-2.0-flash-001',
                'supports_vision' => true,
                'margin_multiplier' => 3.00,
                'is_active' => false,
                'sort_order' => 99,
            ],
            // ── Legacy (compatibilidade com clients antigos sem tier) ──
            [
                // Products ainda referenciam este modelo (ver ROADMAP-NEXUS:
                // pendente) — mantém-se ativo e funcional, agora no motor de produção.
                'slug' => 'qolari',
                'display_name' => 'Qolari',
                'description' => 'Legacy: alias do motor de produção (DeepSeek Chat)',
                'provider' => 'deepseek',
                'provider_model_id' => 'deepseek-chat',
                'supports_vision' => false,
                'margin_multiplier' => 3.00,
                'is_active' => true,
                'sort_order' => 50,
            ],
            [
                'slug' => 'max',
                'display_name' => 'Qolari Max',
                'description' => '(reserva) multimodal',
                'provider' => 'openrouter',
                'provider_model_id' => 'moonshotai/kimi-k2-0905-preview',
                'supports_vision' => true,
                'margin_multiplier' => 3.00,
                'is_active' => false,
                'sort_order' => 51,
            ],
            [
                'slug' => 'medium',
                'display_name' => 'Qolari Medium',
                'description' => '(reserva) legacy — substituído por nexus-medium',
                'provider' => 'openrouter',
                'provider_model_id' => 'deepseek/deepseek-v4-pro',
                'supports_vision' => false,
                'margin_multiplier' => 3.00,
                'is_active' => false,
                'sort_order' => 52,
            ],
        ];

        foreach ($models as $model) {
            DB::table('ai_models')->updateOrInsert(
                ['slug' => $model['slug']],
                array_merge($model, ['updated_at' => now()])
            );

            $this->seedInitialCost($model);
        }
    }

    /**
     * Semeia o custo inicial de modelos de providers diretos APENAS se o
     * modelo ainda não tiver custos (idempotente, nunca sobrescreve o admin).
     */
    private function seedInitialCost(array $model): void
    {
        $cost = self::INITIAL_COSTS[$model['provider_model_id']] ?? null;
        if (!$cost) {
            return;
        }

        $aiModelId = DB::table('ai_models')->where('slug', $model['slug'])->value('id');
        if (!$aiModelId) {
            return;
        }

        $hasCosts = DB::table('model_costs')->where('ai_model_id', $aiModelId)->exists();
        if ($hasCosts) {
            return;
        }

        DB::table('model_costs')->insert([
            'ai_model_id' => $aiModelId,
            'input_cost_per_mtok' => $cost['input'],
            'output_cost_per_mtok' => $cost['output'],
            'synced_at' => now(),
            'created_at' => now(),
        ]);
    }
}
