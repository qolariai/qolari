<?php

namespace App\Domain\Proxy;

use App\Domain\Wallet\WalletService;
use App\Models\AiModel;
use App\Models\UsageLog;
use Illuminate\Support\Facades\Log;

/**
 * Metering centralizado: calcula custo, debita wallet (idempotente)
 * e regista/atualiza o UsageLog. Usado pelo proxy (sync e stream)
 * e pelo job de reconciliacao pos-stream.
 */
class UsageMeter
{
    public function __construct(private WalletService $walletService)
    {
    }

    /**
     * Mede tokens, debita e regista. Idempotente por requestId:
     * se ja existir um debito com esta key, o WalletService devolve o existente.
     */
    public function meter(
        int $userId,
        int $aiModelId,
        string $requestId,
        int $promptTokens,
        int $completionTokens,
        string $status = 'ok',
        ?string $generationId = null,
    ): UsageLog {
        $model = AiModel::findOrFail($aiModelId);

        $cost = $this->calculateCost($model, $promptTokens, $completionTokens);
        $charged = round($cost * (float) $model->margin_multiplier, 8);

        // Debita wallet (idempotente por requestId)
        $ledgerEntry = null;
        if ($charged > 0) {
            try {
                $ledgerEntry = $this->walletService->debit(
                    userId: $userId,
                    aiModelId: $model->id,
                    amountUsd: $charged,
                    idempotencyKey: $requestId,
                    referenceType: 'usage_log',
                    meta: ['request_id' => $requestId, 'status' => $status],
                );
            } catch (\Exception) {
                // Saldo insuficiente apos o request — regista mas nao bloqueia
            }
        }

        return UsageLog::updateOrCreate(
            ['request_id' => $requestId],
            [
                'user_id' => $userId,
                'ai_model_id' => $model->id,
                'generation_id' => $generationId,
                'prompt_tokens' => $promptTokens,
                'completion_tokens' => $completionTokens,
                'cost_usd' => $cost,
                'charged_usd' => $charged,
                'ledger_entry_id' => $ledgerEntry?->id,
                'status' => $status,
                'created_at' => now(),
            ]
        );
    }

    /**
     * Regista um stream a aguardar reconciliacao (usage nao veio no SSE).
     */
    public function recordPending(
        int $userId,
        int $aiModelId,
        string $requestId,
        ?string $generationId,
    ): UsageLog {
        return UsageLog::firstOrCreate(
            ['request_id' => $requestId],
            [
                'user_id' => $userId,
                'ai_model_id' => $aiModelId,
                'generation_id' => $generationId,
                'prompt_tokens' => 0,
                'completion_tokens' => 0,
                'cost_usd' => 0,
                'charged_usd' => 0,
                'status' => 'pending',
                'created_at' => now(),
            ]
        );
    }

    /**
     * Regista um request falhado (erro HTTP do provider).
     */
    public function recordError(int $userId, int $aiModelId, string $requestId): UsageLog
    {
        return UsageLog::firstOrCreate(
            ['request_id' => $requestId],
            [
                'user_id' => $userId,
                'ai_model_id' => $aiModelId,
                'prompt_tokens' => 0,
                'completion_tokens' => 0,
                'cost_usd' => 0,
                'charged_usd' => 0,
                'status' => 'error',
                'created_at' => now(),
            ]
        );
    }

    private function calculateCost(AiModel $model, int $promptTokens, int $completionTokens): float
    {
        $cost = $model->latestCost();
        if (!$cost) {
            Log::warning('UsageMeter: modelo sem custo sincronizado.', ['ai_model_id' => $model->id]);
            return 0.0;
        }

        $inputCost = ($promptTokens / 1_000_000) * (float) $cost->input_cost_per_mtok;
        $outputCost = ($completionTokens / 1_000_000) * (float) $cost->output_cost_per_mtok;

        return round($inputCost + $outputCost, 8);
    }
}
