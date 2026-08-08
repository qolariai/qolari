<?php

namespace App\Domain\Proxy;

use App\Domain\Routing\SuggestionGate;
use App\Domain\Routing\TierRecommender;
use App\Domain\Routing\TierResolver;
use App\Jobs\ReconcileStreamUsage;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Proxy OpenAI-compatible multi-provider (OpenRouter, DeepSeek direto,
 * NVIDIA NIM, ...). O provider (base_url + key) vem do motor resolvido
 * pelo TierResolver — ver config/ai_providers.php e AiProviderResolver.
 * O nome da classe é histórico: os controllers/testes dependem dele.
 */
class OpenRouterProxyService
{
    public function __construct(
        private UsageMeter $meter,
        private TierResolver $tierResolver,
        private TierRecommender $recommender,
        private SuggestionGate $suggestionGate,
        private AiProviderResolver $providers,
    ) {
    }

    /**
     * Proxy nao-streaming: encaminha request, mede tokens, debita.
     *
     * $billTo: 'wallet' (Code, default) ou 'subscription' (Chat — regista o
     * custo mas nunca debita a wallet). Call sites existentes nao mudam.
     *
     * @return array{data: array, suggestion: array|null, status: int}
     */
    public function completions(User $user, array $body, string $billTo = 'wallet'): array
    {
        $resolution = $this->tierResolver->resolve($body, $user);
        $tier = $resolution->tier;
        $engine = $resolution->engine;

        $requestId = Str::uuid()->toString();
        $body['model'] = $engine->provider_model_id;
        // Defesa: este caminho é não-streaming — se o cliente enviar stream
        // (ou stream_options), o upstream devolveria SSE e o parse JSON falharia.
        $body['stream'] = false;
        unset($body['stream_options']);
        $body = $this->sanitizeBody($body);

        $provider = $this->providers->forModel($engine);
        // Defaults do provider (ex: nvidia enable_thinking=false) — os campos
        // do pedido do cliente ganham sempre.
        $body = array_merge($provider['extra_body'], $body);

        $response = Http::withHeaders(array_merge([
            'Authorization' => 'Bearer ' . $provider['api_key'],
            'Content-Type' => 'application/json',
        ], $provider['headers']))
            ->timeout(300)
            ->post($provider['base_url'] . '/chat/completions', $body);

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
            billTo: $billTo,
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
        $body = $this->sanitizeBody($body);

        // Estimativa de prompt (fallback de metering): ~4 chars por token
        $estimatedPromptTokens = (int) ceil(mb_strlen(json_encode($body['messages'] ?? [])) / 4);

        $provider = $this->providers->forModel($engine);
        // Defaults do provider (ver completions()).
        $body = array_merge($provider['extra_body'], $body);
        $baseUrl = $provider['base_url'];
        $apiKey = $provider['api_key'];
        $providerSlug = $provider['slug'];
        $providerHeaders = $provider['headers'];
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

        return new StreamedResponse(function () use ($user, $tier, $engine, $requestId, $body, $baseUrl, $apiKey, $providerSlug, $providerHeaders, $meter, $estimatedPromptTokens, $engineModelId, $tierSlug) {
            $buffer = '';
            $errorBody = '';

            $ch = curl_init($baseUrl . '/chat/completions');
            curl_setopt_array($ch, [
                CURLOPT_POST => true,
                CURLOPT_HTTPHEADER => array_merge([
                    'Authorization: Bearer ' . $apiKey,
                    'Content-Type: application/json',
                ], array_map(
                    fn (string $name, string $value) => $name . ': ' . $value,
                    array_keys($providerHeaders),
                    $providerHeaders,
                )),
                CURLOPT_POSTFIELDS => json_encode($body),
                CURLOPT_TIMEOUT => 300,
                CURLOPT_WRITEFUNCTION => function ($ch, $chunk) use (&$buffer, &$errorBody, $engineModelId, $tierSlug) {
                    // cURL exige o tamanho ORIGINAL do chunk no retorno;
                    // a reescrita white-label muda o comprimento.
                    $length = strlen($chunk);
                    // Erros upstream (ex: 429 free-models-per-day) chegam como JSON
                    // simples, nao como SSE. Este StreamedResponse ja sai com HTTP 200,
                    // por isso o corpo de erro NAO pode ser ecoado cru — seria descartado
                    // pelo parser SSE do cliente. Acumular e converter abaixo num frame
                    // SSE de erro bem formado.
                    if ((int) curl_getinfo($ch, CURLINFO_RESPONSE_CODE) >= 400) {
                        $errorBody .= $chunk;
                        return $length;
                    }
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
                Log::warning('Proxy stream falhou.', [
                    'provider' => $providerSlug,
                    'request_id' => $requestId,
                    'curl_errno' => $curlError,
                    'http_code' => $httpCode,
                ]);
                $meter->recordError($user->id, $tier->id, $engine->id, $requestId);

                // Converte o erro upstream num frame SSE OpenAI-compatible, para o
                // cliente mostrar a mensagem real em vez de um erro generico.
                echo $this->sseErrorFrame($errorBody, $httpCode, $engineModelId, $tierSlug);
                if (ob_get_level()) {
                    ob_flush();
                }
                flush();
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
     * Frame SSE OpenAI-compatible para um erro upstream (qualquer provider).
     * O StreamedResponse ja sai com HTTP 200, por isso o corpo de erro do
     * upstream NAO pode ser ecoado cru — seria descartado pelo parser SSE
     * do cliente. Emite `data: {"error":{...}}` + `data: [DONE]`.
     * WHITE-LABEL: o ID real do motor nunca aparece na mensagem.
     */
    public function sseErrorFrame(string $errorBody, int $httpCode, string $engineModelId, string $tierSlug): string
    {
        $payload = json_decode($errorBody, true);
        $message = $payload['error']['message'] ?? null;
        if (!is_string($message) || $message === '') {
            $message = 'Upstream error (HTTP ' . ($httpCode ?: 'desconhecido') . ')';
        }
        // WHITE-LABEL: nunca expor o ID real do motor na mensagem de erro
        $message = str_replace($engineModelId, $tierSlug, $message);
        $code = $payload['error']['code'] ?? ($httpCode ?: 'unknown');

        return 'data: ' . json_encode(['error' => ['message' => $message, 'code' => $code]]) . "\n\n"
            . "data: [DONE]\n\n";
    }

    /**
     * Faz parse do buffer SSE acumulado: extrai o usage (ultimo evento que o
     * contenha), o generation id (primeiro evento) e o texto gerado (deltas).
     * Publico para reutilizacao pelo Chat (que persiste o texto gerado).
     *
     * @return array{usage: array|null, generation_id: string|null, completion_text: string}
     */
    public function parseSseBuffer(string $buffer): array
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

    /**
     * JSON objects vazios (ex: "provider":{}) chegam como [] apos o
     * json_decode associativo do PHP e seriam reenviados como array,
     * o que a OpenRouter rejeita ("expected object, received array").
     */
    private function sanitizeBody(array $body): array
    {
        foreach (['provider', 'reasoning', 'response_format'] as $key) {
            if (isset($body[$key]) && $body[$key] === []) {
                unset($body[$key]);
            }
        }

        return $body;
    }
}
