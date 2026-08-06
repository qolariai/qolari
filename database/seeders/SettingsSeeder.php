<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SettingsSeeder extends Seeder
{
    public function run(): void
    {
        // Idempotente: só insere keys em falta — NUNCA sobrescreve valores editados no admin.
        $defaults = [
            ['key' => 'conversion_fee_percent', 'value' => '10', 'is_secret' => false],
            ['key' => 'credit_expiry_months', 'value' => '12', 'is_secret' => false],
            ['key' => 'default_margin_multiplier', 'value' => '3.00', 'is_secret' => false],
            ['key' => 'influencer_default_percent', 'value' => '15', 'is_secret' => false],
            ['key' => 'site_name', 'value' => 'Qolari', 'is_secret' => false],
            ['key' => 'support_email', 'value' => 'qolari@qolari.com', 'is_secret' => false],
            ['key' => 'openrouter_api_key', 'value' => null, 'is_secret' => true],
            ['key' => 'deepseek_api_key', 'value' => null, 'is_secret' => true],
            ['key' => 'nvidia_api_key', 'value' => null, 'is_secret' => true],
            ['key' => 'stripe_secret_key', 'value' => null, 'is_secret' => true],
            ['key' => 'stripe_webhook_secret', 'value' => null, 'is_secret' => true],
        ];

        foreach ($defaults as $row) {
            DB::table('settings')->insertOrIgnore($row + ['updated_at' => now()]);
        }
    }
}
