<?php

namespace App\Jobs;

use App\Domain\Proxy\UsageMeter;
use App\Models\Setting;
use App\Models\UsageLog;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Reconcilia o metering de um stream cujo usage nao chegou no ultimo chunk SSE.
 * Consulta /api/v1/generation da OpenRouter com retries; na ultima tentativa,
 * aplica a estimativa de tokens calculada no momento do stream.
 */
class ReconcileStreamUsage implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 5;

    public function __construct(
        private string $requestId,
        private ?string $generationId,
        private int $estimatedPromptTokens,
        private int $estimatedCompletionTokens,
    ) {
    }

    public function handle(UsageMeter $meter): void
    {
        $log = UsageLog::where('request_id', $this->requestId)
            ->where('status', 'pending')
            ->first();

        if (!$log) {
            // Ja reconciliado (ou inexistente) — nada a fazer
            return;
        }

        $usage = $this->fetchGenerationUsage();

        if ($usage) {
            $meter->meter(
                userId: $log->user_id,
                tierModelId: $log->ai_model_id,
                engineModelId: $log->engine_model_id ?? $log->ai_model_id,
                requestId: $this->requestId,
                promptTokens: $usage['prompt_tokens'],
                completionTokens: $usage['completion_tokens'],
                status: 'ok',
                generationId: $this->generationId,
            );
            return;
        }

        if ($this->attempts() < $this->tries) {
            // Geracao ainda nao disponivel na OpenRouter — tenta mais tarde
            $this->release(30);
            return;
        }

        // Ultima tentativa: aplica estimativa para nunca ficar a $0 silencioso
        Log::warning('ReconcileStreamUsage: fallback para estimativa.', [
            'request_id' => $this->requestId,
            'generation_id' => $this->generationId,
        ]);

        $meter->meter(
            userId: $log->user_id,
            tierModelId: $log->ai_model_id,
            engineModelId: $log->engine_model_id ?? $log->ai_model_id,
            requestId: $this->requestId,
            promptTokens: $this->estimatedPromptTokens,
            completionTokens: $this->estimatedCompletionTokens,
            status: 'estimated',
            generationId: $this->generationId,
        );
    }

    /**
     * @return array{prompt_tokens: int, completion_tokens: int}|null
     */
    private function fetchGenerationUsage(): ?array
    {
        if (!$this->generationId) {
            return null;
        }

        $apiKey = Setting::get('openrouter_api_key') ?? config('services.openrouter.api_key', '');
        if (!$apiKey) {
            return null;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
            ])
                ->timeout(15)
                ->get('https://openrouter.ai/api/v1/generation', ['id' => $this->generationId]);

            if ($response->failed()) {
                return null;
            }

            $data = $response->json('data');
            if (!is_array($data)) {
                return null;
            }

            $prompt = (int) ($data['tokens_prompt'] ?? 0);
            $completion = (int) ($data['tokens_completion'] ?? 0);

            if ($prompt === 0 && $completion === 0) {
                return null;
            }

            return ['prompt_tokens' => $prompt, 'completion_tokens' => $completion];
        } catch (\Throwable $e) {
            Log::warning('ReconcileStreamUsage: erro ao consultar /generation.', [
                'request_id' => $this->requestId,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }
}
