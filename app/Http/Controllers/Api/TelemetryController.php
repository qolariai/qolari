<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QualitySignal;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TelemetryController extends Controller
{
    /**
     * POST /v1/telemetry — sinais de qualidade do IDE (Fase 4.5).
     * Aceita batch de eventos: aceitação de código, retries, abortos, edições
     * pós-resposta. Alimenta o shadow testing, canary e o MODEL_CHANGELOG.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'events' => 'required|array|min:1|max:100',
            'events.*.tier' => 'required|string|max:50',
            'events.*.event' => 'required|string|in:accept,retry,abort,edit_after,regenerate',
            'events.*.engine' => 'nullable|string|max:150',
            'events.*.conversation_id' => 'nullable|string|max:100',
            'events.*.meta' => 'nullable|array',
        ]);

        $userId = $request->user()->id;
        $now = now();

        QualitySignal::insert(
            collect($validated['events'])
                ->map(fn ($e) => [
                    'user_id' => $userId,
                    'tier' => $e['tier'],
                    'engine' => $e['engine'] ?? null,
                    'event' => $e['event'],
                    'conversation_id' => $e['conversation_id'] ?? null,
                    'meta' => isset($e['meta']) ? json_encode($e['meta']) : null,
                    'created_at' => $now,
                ])
                ->all()
        );

        return response()->json(['message' => 'ok'], 201);
    }
}
