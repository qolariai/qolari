<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $this->call([
            AiModelsSeeder::class,
            ExchangeRatesSeeder::class,
            SettingsSeeder::class,
        ]);

        // Admin inicial
        User::factory()->create([
            'name' => 'Admin Qolari',
            'email' => 'qolari@qolari.com',
            'password' => Hash::make('password'),
            'is_admin' => true,
            'preferred_currency' => 'EUR',
            'language' => 'pt',
        ]);
    }
}
