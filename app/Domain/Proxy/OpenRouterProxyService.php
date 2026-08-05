<?php

namespace App\Domain\Proxy;

use App\Domain\Routing\SuggestionGate;
use App\Domain\Routing\TierRecommender;
use App\Domain\Routing\TierResolver;
use App\Jobs\ReconcileStreamUsage;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\StreamedResponse;

class OpenRouterProxyService
{
    public function __construct(
        private UsageMeter $meter,
        private TierResolver $tierResolver,
        private TierRecommender $recommender,
        private SuggestionGate $suggestionGate,
    ) {
    }

    /**
     * Proxy nao-streaming: encaminha request, mede tokens, debita.
     *
     * @return array{data: array, suggestion: array|null, status: int}
     */
    public function completions(User $user, array $body): array
    {
        $resolution = $this->tierResolver->resolve($body, $user);
        $tier = $resolution->tier;
        $engine = $resolution->engine;

        $requestId = Str::uuid()->toString();
        $body['model'] = $engine->provider_model_id;

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey(),
            'Content-Type' => 'application/json',
            'HTTP-Referer' => config('app.url'),
            'X-Title' => 'Qolari',
        ])
            ->timeout(300)
            ->post('https://openrouter.ai/api/v1/chat/completions', $body);

        $data = $response->json() ?? [];

        // WHITE-LABEL: nunca expor o ID real do motor ao cliente
        if (isset($data['model'])) {
            $data['model'] = $tier->slug;
        }

        if ($response->failed()) {
            $this->meter->recordError($user->id, $tier->id, $engine->id, $requestId);

            return ['data' => $data, 'suggestion' => null, 'status' => $response->status()];
        }

        $usage = $data['usage'] ?? [];

        $this->meter->meter(
            userId: $user->id,
            tierModelId: $tier->id,
            engineModelId: $engine->id,
            requestId: $requestId,
            promptTokens: $usage['prompt_tokens'] ?? 0,
            completionTokens: $usage['completion_tokens'] ?? 0,
            generationId: $data['id'] ?? null,
        );

        return ['data' => $data, 'suggestion' => $this->suggestionFor($user, $tier->slug, $body), 'status' => 200];
    }

    /**
     * Proxy streaming SSE: encaminha com stream, mede no fim.
     *
     * Estrategia de metering (nunca debitar $0 silencioso):
     *  1. stream_options.include_usage → OpenRouter envia usage no ultimo chunk SSE
     *  2. Fallback: job ReconcileStreamUsage consulta /api/v1/generation
     *  3. Ultimo recurso: estimativa de tokens (status 'estimated')
     */
    public function stream(User $user, array $body): StreamedResponse
    {
        $resolution = $this->tierResolver->resolve($body, $user);
        $tier = $resolution->tier;
        $engine = $resolution->engine;

        $requestId = Str::uuid()->toString();
        $body['model'] = $engine->provider_model_id;
        $body['stream'] = true;
        $body['stream_options'] = ['include_usage' => true];

        // Estimativa de prompt (fallback de metering): ~4 chars por token
        $estimatedPromptTokens = (int) ceil(mb_strlen(json_encode($body['messages'] ?? [])) / 4);

        $apiKey = $this->apiKey();
        $meter = $this->meter;
        $engineModelId = $engine->provider_model_id;
        $tierSlug = $tier->slug;

        $headers = [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive',
            'X-Accel-Buffering' => 'no',
            'X-Request-Id' => $requestId,
        ];

        $suggestion = $this->suggestionFor($user, $tierSlug, $body);
        if ($suggestion) {
            $headers['X-Nexus-Suggestion'] = json_encode($suggestion);
        }

        return new StreamedResponse(function () use ($user, $tier, $engine, $requestId, $body, $apiKey, $meter, $estimatedPromptTokens, $engineModelId, $tierSlug) {
            $buffer = '';

            $ch = curl_init('https://openrouter.ai/api/v1/chat/completions');
            curl_setopt_array($ch, [
                CURLOPT_POST => true,
                CURLOPT_HTTPHEADER => [
                    'Authorization: Bearer ' . $apiKey,
                    'Content-Type: application/json',
                    'HTTP-Referer: ' . config('app.url'),
                    'X-Title: Qolari',
                ],
                CURLOPT_POSTFIELDS => json_encode($body),
                CURLOPT_TIMEOUT => 300,
                CURLOPT_WRITEFUNCTION => function ($ch, $chunk) use (&$buffer, $engineModelId, $tierSlug) {
                    // cURL exige o tamanho ORIGINAL do chunk no retorno;
                    // a reescrita white-label muda o comprimento.
                    $length = strlen($chunk);
                    // WHITE-LABEL: reescreve o ID real do motor no SSE
                    $chunk = str_replace($engineModelId, $tierSlug, $chunk);
                    echo $chunk;
                    $buffer .= $chunk;
                    if (ob_get_level()) {
                        ob_flush();
                    }
                    flush();
                    return $length;
                },
            ]);

            curl_exec($ch);
            $curlError = curl_errno($ch);
            $httpCode = (int) curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
            curl_close($ch);

            if ($curlError !== 0 || $httpCode >= 400) {
                Log::warning('OpenRouter stream falhou.', [
                    'request_id' => $requestId,
                    'curl_errno' => $curlError,
                    'http_code' => $httpCode,
                ]);
                $meter->recordError($user->id, $tier->id, $engine->id, $requestId);
                return;
            }

            // Extrai usage, generation id e texto do buffer SSE
            $parsed = $this->parseSseBuffer($buffer);

            if ($parsed['usage']) {
                // Caminho feliz: usage veio no ultimo chunk SSE
                $meter->meter(
                    userId: $user->id,
                    tierModelId: $tier->id,
                    engineModelId: $engine->id,
                    requestId: $requestId,
                    promptTokens: $parsed['usage']['prompt_tokens'] ?? 0,
                    completionTokens: $parsed['usage']['completion_tokens'] ?? 0,
                    generationId: $parsed['generation_id'],
                );
                return;
            }

            // Fallback: regista pendente e reconcilia via /generation (queue)
            $meter->recordPending($user->id, $tier->id, $engine->id, $requestId, $parsed['generation_id']);

            $estimatedCompletionTokens = (int) ceil(mb_strlen($parsed['completion_text']) / 4);

            ReconcileStreamUsage::dispatch(
                requestId: $requestId,
                generationId: $parsed['generation_id'],
                estimatedPromptTokens: $estimatedPromptTokens,
                estimatedCompletionTokens: $estimatedCompletionTokens,
            )->delay(now()->addSeconds(10));
        }, 200, $headers);
    }

    /**
     * Sugestao de tier para este pedido (2.1-2.4). Null quando:
     * Nexus Auto ativo (ja escolhe em silencio), matriz nao tem nada a dizer,
     * ou as regras de comportamento bloqueiam (rate limit / recusas).
     */
    private function suggestionFor(User $user, string $tierSlug, array $body): ?array
    {
        $this->suggestionGate->tick($user->id);

        if ($user->nexus_auto) {
            return null;
        }

        $suggestion = $this->recommender->suggest($tierSlug, $body);
        if (!$suggestion) {
            return null;
        }

        if (!$this->suggestionGate->allows($user->id, $suggestion['tier'])) {
            return null;
        }

        $this->suggestionGate->recordShown($user->id);

        return $suggestion;
    }

    /**
     * Faz parse do buffer SSE acumulado: extrai o usage (ultimo evento que o
     * contenha), o generation id (primeiro evento) e o texto gerado (deltas).
     *
     * @return array{usage: array|null, generation_id: string|null, completion_text: string}
     */
    private function parseSseBuffer(string $buffer): array
    {
        $usage = null;
        $generationId = null;
        $completionText = '';

        foreach (preg_split('/\r?\n\r?\n/', $buffer) as $event) {
            foreach (preg_split('/\r?\n/', $event) as $line) {
                if (!str_starts_with($line, 'data:')) {
                    continue;
                }

                $json = trim(substr($line, 5));
                if ($json === '' || $json === '[DONE]') {
                    continue;
                }

                $decoded = json_decode($json, true);
                if (!is_array($decoded)) {
                    continue;
                }

                $generationId ??= $decoded['id'] ?? null;

                if (!empty($decoded['usage']) && is_array($decoded['usage'])) {
                    $usage = $decoded['usage'];
                }

                foreach ($decoded['choices'] ?? [] as $choice) {
                    $delta = $choice['delta']['content'] ?? null;
                    if (is_string($delta)) {
                        $completionText .= $delta;
                    }
                }
            }
        }

        return [
            'usage' => $usage,
            'generation_id' => $generationId,
            'completion_text' => $completionText,
        ];
    }

    private function apiKey(): string
    {
        return Setting::get('openrouter_api_key') ?? config('services.openrouter.api_key', '');
    }
}
