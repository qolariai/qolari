<?php

namespace App\Http\Controllers\Api;

use App\Domain\Proxy\OpenRouterProxyService;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ProxyController extends Controller
{
    public function __construct(private OpenRouterProxyService $proxyService)
    {
    }

    /**
     * POST /api/v1/chat/completions — nao-streaming
     */
    public function completions(Request $request): JsonResponse
    {
        $body = $request->validate([
            'messages' => 'required|array|min:1',
            'messages.*.role' => 'required|string|in:system,user,assistant',
            'messages.*.content' => 'required|string',
            'temperature' => 'nullable|numeric|min:0|max:2',
            'max_tokens' => 'nullable|integer|min:1',
        ]);

        $result = $this->proxyService->completions($request->user()->id, $body);

        return response()->json($result);
    }

    /**
     * POST /api/v1/chat — streaming SSE
     */
    public function chat(Request $request): StreamedResponse
    {
        $body = $request->validate([
            'messages' => 'required|array|min:1',
            'messages.*.role' => 'required|string|in:system,user,assistant',
            'messages.*.content' => 'required|string',
            'temperature' => 'nullable|numeric|min:0|max:2',
            'max_tokens' => 'nullable|integer|min:1',
        ]);

        return $this->proxyService->stream($request->user()->id, $body);
    }
}
