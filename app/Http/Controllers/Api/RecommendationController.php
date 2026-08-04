<?php

namespace App\Http\Controllers\Api;

use App\Domain\Routing\SuggestionGate;
use App\Domain\Routing\TierRecommender;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RecommendationController extends Controller
{
    /**
     * POST /v1/recommendations/suggest — preview de sugestão de tier para um
     * rascunho de prompt (usado pelo IDE ANTES de enviar). Não conta pedidos
     * no gate nem regista "mostrada" — o caminho canónico é o header do proxy.
     */
    public function suggest(Request $request, TierRecommender $recommender, SuggestionGate $gate): JsonResponse
    {
        $validated = $request->validate([
            'tier' => 'required|string|max:50',
            'prompt' => 'required|string|max:10000',
        ]);

        $user = $request->user();

        // Nexus Auto escolhe em silêncio — não há nada para sugerir
        if ($user->nexus_auto) {
            return response()->json(['suggestion' => null]);
        }

        $suggestion = $recommender->suggest($validated['tier'], [
            'messages' => [['role' => 'user', 'content' => $validated['prompt']]],
        ]);

        if (!$suggestion || !$gate->allows($user->id, $suggestion['tier'])) {
            return response()->json(['suggestion' => null]);
        }

        return response()->json(['suggestion' => $suggestion]);
    }

    /**
     * POST /v1/recommendations/dismiss — cliente recusou uma sugestão de tier.
     * Após 2 recusas do mesmo tier, deixa de ser sugerido durante 7 dias (2.4).
     */
    public function dismiss(Request $request, SuggestionGate $gate): JsonResponse
    {
        $validated = $request->validate([
            'tier' => 'required|string|max:50',
        ]);

        $gate->dismiss($request->user()->id, $validated['tier']);

        return response()->json(['message' => 'Sugestão registada.']);
    }
}
