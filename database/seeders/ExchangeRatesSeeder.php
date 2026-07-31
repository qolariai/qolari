<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ExchangeRatesSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('exchange_rates')->insert([
            ['currency' => 'USD', 'rate_to_usd' => 1.000000, 'updated_at' => now()],
            ['currency' => 'EUR', 'rate_to_usd' => 1.137200, 'updated_at' => now()],
            ['currency' => 'GBP', 'rate_to_usd' => 1.270000, 'updated_at' => now()],
            ['currency' => 'AOA', 'rate_to_usd' => 0.001100, 'updated_at' => now()],
        ]);
    }
}
