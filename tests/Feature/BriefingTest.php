<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class BriefingTest extends TestCase
{
    use RefreshDatabase;

    public function test_briefing_starts_empty(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->getJson('/api/v1/conversations/sess-1/briefing')
            ->assertOk()
            ->assertJson(['content' => null, 'version' => 0]);
    }

    public function test_briefing_upsert_and_versioning(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->putJson('/api/v1/conversations/sess-1/briefing', [
            'content' => "## Estado\n**Feito:** login JWT",
            'title' => 'Sessão auth',
        ])->assertOk()->assertJson(['version' => 1]);

        $this->getJson('/api/v1/conversations/sess-1/briefing')
            ->assertOk()
            ->assertJson(['version' => 1])
            ->assertJsonPath('content', "## Estado\n**Feito:** login JWT");

        // Atualização incrementa versão
        $this->putJson('/api/v1/conversations/sess-1/briefing', [
            'content' => 'v2',
            'version' => 1,
        ])->assertOk()->assertJson(['version' => 2]);
    }

    public function test_stale_version_is_rejected(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->putJson('/api/v1/conversations/sess-1/briefing', ['content' => 'v1'])->assertOk();
        $this->putJson('/api/v1/conversations/sess-1/briefing', ['content' => 'v2', 'version' => 1])->assertOk();

        // Versão 1 outra vez → 422 (desatualizada)
        $this->putJson('/api/v1/conversations/sess-1/briefing', ['content' => 'stale', 'version' => 1])
            ->assertStatus(422);
    }

    public function test_briefings_are_isolated_per_user(): void
    {
        $alice = User::factory()->create();
        $bob = User::factory()->create();

        Sanctum::actingAs($alice);
        $this->putJson('/api/v1/conversations/shared-id/briefing', ['content' => 'da alice'])->assertOk();

        Sanctum::actingAs($bob);
        $this->getJson('/api/v1/conversations/shared-id/briefing')
            ->assertOk()
            ->assertJson(['content' => null, 'version' => 0]);
    }
}
