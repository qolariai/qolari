<?php

namespace Tests\Feature;

use App\Domain\Geo\GeoService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

/**
 * Geo-pricing: deteção de país por IP (ipapi.co, faked) e moeda sugerida.
 */
class GeoPricingTest extends TestCase
{
    use RefreshDatabase;

    public function test_angolan_ip_suggests_aoa(): void
    {
        Http::fake(['ipapi.co/*' => Http::response('AO')]);

        $geo = app(GeoService::class);
        $country = $geo->countryForIp('197.218.90.10'); // IP público (Angola Telecom)

        $this->assertSame('AO', $country);
        $this->assertSame('AOA', $geo->suggestedCurrency($country));
    }

    public function test_non_angolan_ip_suggests_nothing(): void
    {
        Http::fake(['ipapi.co/*' => Http::response('PT')]);

        $geo = app(GeoService::class);
        $country = $geo->countryForIp('85.240.10.10');

        $this->assertSame('PT', $country);
        $this->assertNull($geo->suggestedCurrency($country));
    }

    public function test_private_ip_never_calls_external_service(): void
    {
        Http::fake();

        $this->assertNull(app(GeoService::class)->countryForIp('127.0.0.1'));
        $this->assertNull(app(GeoService::class)->countryForIp('192.168.1.10'));

        Http::assertNothingSent();
    }

    public function test_external_failure_fails_silently(): void
    {
        Cache::flush();
        Http::fake(['ipapi.co/*' => Http::response('error', 500)]);

        $this->assertNull(app(GeoService::class)->countryForIp('197.218.90.11'));
    }

    public function test_geo_endpoint_returns_nulls_for_local_requests(): void
    {
        // Em testes o IP é 127.0.0.1 (privado) → sem lookup externo
        $this->getJson('/api/v1/geo')
            ->assertOk()
            ->assertJson(['country' => null, 'suggested_currency' => null]);
    }

    public function test_profile_accepts_aoa_as_preferred_currency(): void
    {
        $user = \App\Models\User::factory()->create();
        \Laravel\Sanctum\Sanctum::actingAs($user);

        $this->putJson('/api/v1/profile', ['preferred_currency' => 'AOA'])
            ->assertOk();

        $this->assertSame('AOA', $user->fresh()->preferred_currency);
    }
}
