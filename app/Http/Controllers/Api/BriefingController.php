<?php

namespace App\Http\Controllers\Api;

use App\Domain\Briefing\BriefingService;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BriefingController extends Controller
{
    public function __construct(private BriefingService $briefings)
    {
    }

    /**
     * GET /v1/conversations/{externalId}/briefing
     */
    public function show(Request $request, string $externalId): JsonResponse
    {
        $briefing = $this->briefings->get($request->user()->id, $externalId);

        if (!$briefing) {
            return response()->json(['content' => null, 'version' => 0]);
        }

        return response()->json([
            'content' => $briefing->content,
            'version' => $briefing->version,
            'updated_at' => $briefing->updated_at,
        ]);
    }

    /**
     * PUT /v1/conversations/{externalId}/briefing
     */
    public function update(Request $request, string $externalId): JsonResponse
    {
        $validated = $request->validate([
            'content' => 'required|string|max:8000',
            'version' => 'nullable|integer|min:0',
            'title' => 'nullable|string|max:150',
        ]);

        $briefing = $this->briefings->put(
            $request->user()->id,
            $externalId,
            $validated['content'],
            $validated['version'] ?? null,
            $validated['title'] ?? null,
        );

        return response()->json([
            'content' => $briefing->content,
            'version' => $briefing->version,
            'updated_at' => $briefing->updated_at,
        ]);
    }
}
