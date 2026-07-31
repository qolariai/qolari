<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SettingsSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('settings')->insert([
            ['key' => 'conversion_fee_percent', 'value' => '10', 'is_secret' => false, 'updated_at' => now()],
            ['key' => 'credit_expiry_months', 'value' => '12', 'is_secret' => false, 'updated_at' => now()],
            ['key' => 'default_margin_multiplier', 'value' => '3.00', 'is_secret' => false, 'updated_at' => now()],
            ['key' => 'influencer_default_percent', 'value' => '15', 'is_secret' => false, 'updated_at' => now()],
            ['key' => 'site_name', 'value' => 'Qolari', 'is_secret' => false, 'updated_at' => now()],
            ['key' => 'support_email', 'value' => 'qolari@qolari.com', 'is_secret' => false, 'updated_at' => now()],
            ['key' => 'openrouter_api_key', 'value' => null, 'is_secret' => true, 'updated_at' => now()],
            ['key' => 'stripe_secret_key', 'value' => null, 'is_secret' => true, 'updated_at' => now()],
            ['key' => 'stripe_webhook_secret', 'value' => null, 'is_secret' => true, 'updated_at' => now()],
        ]);
    }
}
