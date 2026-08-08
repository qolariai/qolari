<?php

namespace App\Domain\Chat;

use App\Domain\Proxy\AiProviderResolver;
use App\Domain\Proxy\OpenRouterProxyService;
use App\Domain\Proxy\UsageMeter;
use App\Domain\Routing\TierResolver;
use App\Domain\Subscription\SubscriptionService;
use App\Models\ChatConversation;
use App\Models\ChatMessage;
use App\Models\Subscription;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Orquestração do Chat por subscrição. Reutiliza o caminho do proxy
 * (TierResolver + providers + UsageMeter), mas a faturação vai para o
 * contador da subscrição — NUNCA para a wallet de créditos (Code).
 */
class ChatService
{
    public function __construct(
        private OpenRouterProxyService $proxy,
        private TierResolver $tierResolver,
        private AiProviderResolver $providers,
        private UsageMeter $meter,
        private SubscriptionService $subscriptionService,
    ) {
    }

    /**
     * Mensagem não-streaming: proxy completo, persistência da resposta
     * e contagem de tokens na subscrição.
     *
     * @return array{message: ChatMessage|null, usage: array, data: array, status: int}
     */
    public function complete(User $user, ChatConversation $conversation, Subscription $subscription): array
    {
        $body = $this->buildBody($conversation);

        $result = $this->proxy->completions($user, $body, 'subscription');

        if (($result['status'] ?? 200) !== 200) {
            return ['message' => null, 'usage' => [], 'data' => $result['data'], 'status' => $result['status']];
        }

        $data = $result['data'];
        $usage = $data['usage'] ?? [];
        $promptTokens = (int) ($usage['prompt_tokens'] ?? 0);
        $completionTokens = (int) ($usage['completion_tokens'] ?? 0);

        $message = $this->persistAssistantMessage(
            $conversation,
            (string) ($data['choices'][0]['message']['content'] ?? ''),
            $completionTokens,
            ['model' => $data['model'] ?? null],
        );

        $this->subscriptionService->recordUsage($subscription, $promptTokens + $completionTokens);

        return ['message' => $message, 'usage' => $usage, 'data' => $data, 'status' => 200];
    }

    /**
     * Mensagem streaming (SSE passthrough). Espelha o buffer do stream do
     * proxy: no fim faz parse do SSE, mede (billTo subscription), persiste
     * o texto acumulado e conta os tokens na subscrição. Ao contrário do
     * proxy da wallet, finaliza sempre em sincronia (sem pending/reconciliar).
     */
    public function stream(
        User $user,
        ChatConversation $conversation,
        Subscription $subscription,
        bool $throttled = false,
    ): StreamedResponse {
        $body = $this->buildBody($conversation);

        $resolution = $this->tierResolver->resolve($body, $user);
        $tier = $resolution->tier;
        $engine = $resolution->engine;

        $requestId = Str::uuid()->toString();
        $body['model'] = $engine->provider_model_id;
        $body['stream'] = true;
        $body['stream_options'] = ['include_usage' => true];

        // Estimativa de prompt (fallback de metering): ~4 chars por token
        $estimatedPromptTokens = (int) ceil(mb_strlen(json_encode($body['messages'] ?? [])) / 4);

        $provider = $this->providers->forModel($engine);
        // Defaults do provider (ex: nvidia enable_thinking=false).
        $body = array_merge($provider['extra_body'], $body);
        $baseUrl = $provider['base_url'];
        $apiKey = $provider['api_key'];
        $providerSlug = $provider['slug'];
        $providerHeaders = $provider['headers'];
        $engineModelId = $engine->provider_model_id;
        $tierSlug = $tier->slug;

        $proxy = $this->proxy;
        $meter = $this->meter;
        $subscriptionService = $this->subscriptionService;

        $headers = [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive',
            'X-Accel-Buffering' => 'no',
            'X-Request-Id' => $requestId,
        ];
        if ($throttled) {
            $headers['X-Qolari-Throttled'] = '1';
        }

        return new StreamedResponse(function () use ($user, $tier, $engine, $conversation, $subscription, $requestId, $body, $baseUrl, $apiKey, $providerSlug, $providerHeaders, $estimatedPromptTokens, $engineModelId, $tierSlug, $proxy, $meter, $subscriptionService) {
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
                Log::warning('Chat stream falhou.', [
                    'provider' => $providerSlug,
                    'request_id' => $requestId,
                    'curl_errno' => $curlError,
                    'http_code' => $httpCode,
                ]);
                $meter->recordError($user->id, $tier->id, $engine->id, $requestId);

                echo $proxy->sseErrorFrame($errorBody, $httpCode, $engineModelId, $tierSlug);
                if (ob_get_level()) {
                    ob_flush();
                }
                flush();
                return;
            }

            $parsed = $proxy->parseSseBuffer($buffer);

            if ($parsed['usage']) {
                $promptTokens = (int) ($parsed['usage']['prompt_tokens'] ?? 0);
                $completionTokens = (int) ($parsed['usage']['completion_tokens'] ?? 0);

                // Chat na subscrição: regista custo sem tocar na wallet
                $meter->meter(
                    userId: $user->id,
                    tierModelId: $tier->id,
                    engineModelId: $engine->id,
                    requestId: $requestId,
                    promptTokens: $promptTokens,
                    completionTokens: $completionTokens,
                    generationId: $parsed['generation_id'],
                    billTo: 'subscription',
                );
            } else {
                // Sem usage no SSE: estimativa (nunca ficar a $0 nem criar pending,
                // porque o Chat não passa pela reconciliação da wallet)
                $promptTokens = $estimatedPromptTokens;
                $completionTokens = (int) ceil(mb_strlen($parsed['completion_text']) / 4);

                $meter->meter(
                    userId: $user->id,
                    tierModelId: $tier->id,
                    engineModelId: $engine->id,
                    requestId: $requestId,
                    promptTokens: $promptTokens,
                    completionTokens: $completionTokens,
                    status: 'estimated',
                    generationId: $parsed['generation_id'],
                    billTo: 'subscription',
                );
            }

            if ($parsed['completion_text'] !== '') {
                ChatMessage::create([
                    'chat_conversation_id' => $conversation->id,
                    'role' => 'assistant',
                    'content' => $parsed['completion_text'],
                    'tokens' => $completionTokens,
                    'meta' => ['request_id' => $requestId, 'model' => $tierSlug],
                    'created_at' => now(),
                ]);
            }

            $subscriptionService->recordUsage($subscription, $promptTokens + $completionTokens);
        }, 200, $headers);
    }

    /**
     * Corpo OpenAI-compatible a partir do histórico da conversa
     * (a mensagem do utilizador já vem persistida pelo controller).
     */
    private function buildBody(ChatConversation $conversation): array
    {
        $limit = (int) config('chat.history_limit', 50);

        $messages = $conversation->messages()
            ->orderByDesc('id')
            ->limit($limit)
            ->get()
            ->reverse()
            ->values()
            ->map(fn (ChatMessage $message) => ['role' => $message->role, 'content' => $message->content])
            ->all();

        return [
            'model' => $conversation->model_slug, // null → primeiro tier ativo (TierResolver)
            'messages' => $messages,
        ];
    }

    private function persistAssistantMessage(
        ChatConversation $conversation,
        string $content,
        ?int $tokens,
        ?array $meta = null,
    ): ?ChatMessage {
        if ($content === '') {
            return null;
        }

        return ChatMessage::create([
            'chat_conversation_id' => $conversation->id,
            'role' => 'assistant',
            'content' => $content,
            'tokens' => $tokens,
            'meta' => $meta,
            'created_at' => now(),
        ]);
    }
}
