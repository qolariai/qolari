<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AiModelsSeeder extends Seeder
{
    public function run(): void
    {
        $models = [
            // ── Tiers Nexus (white-label) ──────────────────────────────
            [
                'slug' => 'nexus-high',
                'display_name' => 'Nexus High',
                'description' => 'Tier topo: máxima qualidade, multimodal',
                'provider' => 'openrouter',
                'provider_model_id' => 'moonshotai/kimi-k2.7-code',
                'supports_vision' => true,
                'margin_multiplier' => 3.00,
                'is_active' => true,
                'sort_order' => 1,
            ],
            [
                'slug' => 'nexus-medium',
                'display_name' => 'Nexus Medium',
                'description' => 'Tier equilibrado: qualidade/custo para o dia a dia',
                'provider' => 'openrouter',
                'provider_model_id' => 'deepseek/deepseek-v4-pro',
                'supports_vision' => false,
                'margin_multiplier' => 3.00,
                'is_active' => true,
                'sort_order' => 2,
            ],
            [
                'slug' => 'nexus-low',
                'display_name' => 'Nexus Low',
                'description' => 'Tier económico: tarefas simples e rápidas',
                'provider' => 'openrouter',
                'provider_model_id' => 'qwen/qwen3-coder',
                'supports_vision' => false,
                'margin_multiplier' => 3.00,
                'is_active' => true,
                'sort_order' => 3,
            ],
            [
                'slug' => 'nexus-vision',
                'display_name' => 'Nexus Vision',
                'description' => 'Multimodal económico — NUNCA visível ao cliente: entra silenciosamente quando há imagem/ficheiro e o tier ativo não suporta visão',
                'provider' => 'openrouter',
                'provider_model_id' => 'google/gemini-2.0-flash-001',
                'supports_vision' => true,
                'margin_multiplier' => 3.00,
                'is_active' => true,
                'sort_order' => 99,
            ],
            // ── Legacy (compatibilidade com clients antigos sem tier) ──
            [
                'slug' => 'qolari',
                'display_name' => 'Qolari',
                'description' => 'Legacy: alias do Nexus High (Kimi K2.7 Code)',
                'provider' => 'openrouter',
                'provider_model_id' => 'moonshotai/kimi-k2.7-code',
                'supports_vision' => true,
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
        }
    }
}
