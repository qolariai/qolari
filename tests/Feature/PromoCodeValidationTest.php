<?php

namespace Tests\Feature;

use App\Models\PromoCode;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PromoCodeValidationTest extends TestCase
{
    use RefreshDatabase;

    public function test_active_code_is_valid(): void
    {
        PromoCode::create([
            'code' => 'TECHPT',
            'owner_name' => 'Canal TechPT',
            'commission_percent' => 15,
            'is_active' => true,
        ]);

        $this->getJson('/api/v1/promo-codes/TECHPT')
            ->assertOk()
            ->assertExactJson(['valid' => true]);
    }

    public function test_inactive_code_is_invalid(): void
    {
        PromoCode::create([
            'code' => 'OFF',
            'owner_name' => 'Desativado',
            'commission_percent' => 15,
            'is_active' => false,
        ]);

        $this->getJson('/api/v1/promo-codes/OFF')
            ->assertOk()
            ->assertExactJson(['valid' => false]);
    }

    public function test_unknown_code_is_invalid(): void
    {
        $this->getJson('/api/v1/promo-codes/NAO-EXISTE')
            ->assertOk()
            ->assertExactJson(['valid' => false]);
    }

    public function test_endpoint_never_leaks_owner_or_commission(): void
    {
        PromoCode::create([
            'code' => 'SEGREDO',
            'owner_name' => 'Dono Privado',
            'owner_contact' => 'dono@privado.com',
            'commission_percent' => 20,
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/v1/promo-codes/SEGREDO');

        $response->assertOk();
        $this->assertEquals(['valid' => true], $response->json());
    }
}
