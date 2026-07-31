<?php

namespace App\Domain\Proxy;

use App\Domain\Wallet\WalletService;
use App\Models\AiModel;
use App\Models\ModelCost;
use App\Models\Setting;
use App\Models\UsageLog;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\StreamedResponse;

class OpenRouterProxyService
{
    public function __construct(private WalletService $walletService)
    {
    }

    /**
     * Proxy nao-streaming: encaminha request, mede tokens, debita.
     */
    public function completions(int $userId, array $body): array
    {
        $model = AiModel::active()->first();
        if (!$model) {
            throw new \RuntimeException('Nenhum modelo ativo.');
        }

        $requestId = Str::uuid()->toString();
        $body['model'] = $model->provider_model_id;

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey(),
            'Content-Type' => 'application/json',
            'HTTP-Referer' => config('app.url'),
            'X-Title' => 'Qolari',
        ])
            ->timeout(300)
            ->post('https://openrouter.ai/api/v1/chat/completions', $body);

        $data = $response->json();

        if ($response->failed()) {
            UsageLog::create([
                'user_id' => $userId,
                'ai_model_id' => $model->id,
                'request_id' => $requestId,
                'prompt_tokens' => 0,
                'completion_tokens' => 0,
                'cost_usd' => 0,
                'charged_usd' => 0,
                'status' => 'error',
                'created_at' => now(),
            ]);

            return $data;
        }

        $this->meterAndDebit($userId, $model, $requestId, $data);

        return $data;
    }

    /**
     * Proxy streaming SSE: encaminha com stream, mede no fim.
     */
    public function stream(int $userId, array $body): StreamedResponse
    {
        $model = AiModel::active()->first();
        if (!$model) {
            throw new \RuntimeException('Nenhum modelo ativo.');
        }

        $requestId = Str::uuid()->toString();
        $body['model'] = $model->provider_model_id;
        $body['stream'] = true;

        $apiKey = $this->apiKey();
        $walletService = $this->walletService;

        return new StreamedResponse(function () use ($userId, $model, $requestId, $body, $apiKey, $walletService) {
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
                CURLOPT_WRITEFUNCTION => function ($ch, $chunk) {
                    echo $chunk;
                    if (ob_get_level()) {
                        ob_flush();
                    }
                    flush();
                    return strlen($chunk);
                },
            ]);

            curl_exec($ch);
            curl_close($ch);

            // Apos o stream, buscar usage via request_id na OpenRouter
            // (a OpenRouter inclui usage no ultimo chunk SSE com stream_options)
            // Fallback: estimar pelo generation endpoint
            $this->meterPostStream($userId, $model, $requestId, $walletService);
        }, 200, [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive',
            'X-Accel-Buffering' => 'no',
            'X-Request-Id' => $requestId,
        ]);
    }

    /**
     * Mede tokens e debita (resposta nao-streaming).
     */
    private function meterAndDebit(int $userId, AiModel $model, string $requestId, array $data): void
    {
        $usage = $data['usage'] ?? [];
        $promptTokens = $usage['prompt_tokens'] ?? 0;
        $completionTokens = $usage['completion_tokens'] ?? 0;

        $cost = $this->calculateCost($model, $promptTokens, $completionTokens);
        $charged = round($cost * (float) $model->margin_multiplier, 8);

        // Debita wallet (idempotente)
        $ledgerEntry = null;
        if ($charged > 0) {
            try {
                $ledgerEntry = $this->walletService->debit(
                    userId: $userId,
                    aiModelId: $model->id,
                    amountUsd: $charged,
                    idempotencyKey: $requestId,
                    referenceType: 'usage_log',
                    meta: ['request_id' => $requestId],
                );
            } catch (\Exception) {
                // Saldo insuficiente apos o request — regista mas nao bloqueia
            }
        }

        UsageLog::create([
            'user_id' => $userId,
            'ai_model_id' => $model->id,
            'request_id' => $requestId,
            'prompt_tokens' => $promptTokens,
            'completion_tokens' => $completionTokens,
            'cost_usd' => $cost,
            'charged_usd' => $charged,
            'ledger_entry_id' => $ledgerEntry?->id,
            'status' => 'ok',
            'created_at' => now(),
        ]);
    }

    /**
     * Metering pos-stream (fallback: consulta generation na OpenRouter).
     */
    private function meterPostStream(int $userId, AiModel $model, string $requestId, WalletService $walletService): void
    {
        // A OpenRouter expoe /api/v1/generation?id=... para obter usage apos stream
        // Por agora, registamos com zeros e o job diario reconcilia
        UsageLog::firstOrCreate(
            ['request_id' => $requestId],
            [
                'user_id' => $userId,
                'ai_model_id' => $model->id,
                'prompt_tokens' => 0,
                'completion_tokens' => 0,
                'cost_usd' => 0,
                'charged_usd' => 0,
                'status' => 'ok',
                'created_at' => now(),
            ]
        );
    }

    private function calculateCost(AiModel $model, int $promptTokens, int $completionTokens): float
    {
        $cost = $model->latestCost();
        if (!$cost) {
            return 0.0;
        }

        $inputCost = ($promptTokens / 1_000_000) * (float) $cost->input_cost_per_mtok;
        $outputCost = ($completionTokens / 1_000_000) * (float) $cost->output_cost_per_mtok;

        return round($inputCost + $outputCost, 8);
    }

    private function apiKey(): string
    {
        return Setting::get('openrouter_api_key') ?? config('services.openrouter.api_key', '');
    }
}
