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
     * Regras partilhadas. content pode ser string (texto) ou array de
     * content parts (multimodal: text/image_url/file) — ver 1.5.
     */
    private function rules(): array
    {
        return [
            'model' => 'nullable|string|max:100', // tier comercial (ex: nexus-medium)
            'messages' => 'required|array|min:1',
            'messages.*.role' => 'required|string|in:system,user,assistant,tool',
            'messages.*.content' => 'required',
            'messages.*.content.*.type' => 'sometimes|required|string|in:text,image_url,image,input_image,file',
            'messages.*.name' => 'nullable|string|max:100',
            'messages.*.tool_call_id' => 'nullable|string|max:100',
            'temperature' => 'nullable|numeric|min:0|max:2',
            'max_tokens' => 'nullable|integer|min:1',
        ];
    }

    /**
     * POST /api/v1/chat/completions — nao-streaming
     */
    public function completions(Request $request): JsonResponse
    {
        $body = $this->validatedBody($request);

        $result = $this->proxyService->completions($request->user(), $body);

        $response = response()->json($result['data']);
        if ($result['suggestion']) {
            $response->headers->set('X-Nexus-Suggestion', json_encode($result['suggestion']));
        }

        return $response;
    }

    /**
     * POST /api/v1/chat — streaming SSE
     */
    public function chat(Request $request): StreamedResponse
    {
        $body = $this->validatedBody($request);

        return $this->proxyService->stream($request->user(), $body);
    }

    /**
     * Valida os campos base mas preserva campos agênticos extra
     * (tools, tool_choice, response_format, reasoning, ...) que o IDE envia.
     */
    private function validatedBody(Request $request): array
    {
        $validated = $request->validate($this->rules());

        return array_merge($request->except(['_token']), $validated);
    }
}
