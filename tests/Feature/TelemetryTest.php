<?php

namespace Tests\Feature;

use App\Models\QualitySignal;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TelemetryTest extends TestCase
{
    use RefreshDatabase;

    public function test_accepts_batch_of_quality_signals(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/v1/telemetry', [
            'events' => [
                ['tier' => 'nexus-high', 'event' => 'accept', 'conversation_id' => 'sess-1'],
                ['tier' => 'nexus-low', 'event' => 'retry', 'meta' => ['reason' => 'wrong_output']],
                ['tier' => 'nexus-low', 'event' => 'abort'],
            ],
        ])->assertCreated();

        $this->assertEquals(3, QualitySignal::count());
        $this->assertEquals(2, QualitySignal::where('event', 'retry')->orWhere('event', 'abort')->count());
    }

    public function test_rejects_invalid_events(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/v1/telemetry', [
            'events' => [['tier' => 'nexus-high', 'event' => 'explode']],
        ])->assertStatus(422);
    }

    public function test_requires_authentication(): void
    {
        $this->postJson('/api/v1/telemetry', [
            'events' => [['tier' => 'nexus-high', 'event' => 'accept']],
        ])->assertStatus(401);
    }
}
