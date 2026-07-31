<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AiModelsSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('ai_models')->insert([
            [
                'slug' => 'qolari',
                'display_name' => 'Qolari',
                'description' => 'Modelo chefe: Kimi K2.7 Code (multimodal) — escolhido 27-07-2026',
                'provider' => 'openrouter',
                'provider_model_id' => 'moonshotai/kimi-k2.7-code',
                'margin_multiplier' => 3.00,
                'is_active' => true,
                'sort_order' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'slug' => 'max',
                'display_name' => 'Qolari Max',
                'description' => '(reserva) multimodal',
                'provider' => 'openrouter',
                'provider_model_id' => 'moonshotai/kimi-k2-0905-preview',
                'margin_multiplier' => 3.00,
                'is_active' => false,
                'sort_order' => 2,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'slug' => 'medium',
                'display_name' => 'Qolari Medium',
                'description' => '(reserva) económico — DeepSeek V4 Pro',
                'provider' => 'openrouter',
                'provider_model_id' => 'deepseek/deepseek-v4-pro',
                'margin_multiplier' => 3.00,
                'is_active' => false,
                'sort_order' => 3,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
