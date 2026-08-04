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
 *
 * Tier vs engine: o custo real vem do motor usado (engine), mas a margem
 * e a wallet debitada sao do tier escolhido pelo cliente. Quando houve
 * routing silencioso (ex: Nexus Vision), engine != tier.
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
        int $tierModelId,
        int $engineModelId,
        string $requestId,
        int $promptTokens,
        int $completionTokens,
        string $status = 'ok',
        ?string $generationId = null,
    ): UsageLog {
        $tier = AiModel::findOrFail($tierModelId);
        $engine = AiModel::findOrFail($engineModelId);

        // Custo real = motor usado; margem = tier escolhido pelo cliente
        $cost = $this->calculateCost($engine, $promptTokens, $completionTokens);
        $charged = round($cost * (float) $tier->margin_multiplier, 8);

        // Debita a wallet do TIER (idempotente por requestId)
        $ledgerEntry = null;
        if ($charged > 0) {
            try {
                $ledgerEntry = $this->walletService->debit(
                    userId: $userId,
                    aiModelId: $tier->id,
                    amountUsd: $charged,
                    idempotencyKey: $requestId,
                    referenceType: 'usage_log',
                    meta: [
                        'request_id' => $requestId,
                        'status' => $status,
                        'engine_model_id' => $engine->id,
                        'routed' => $engine->id !== $tier->id,
                    ],
                );
            } catch (\Exception) {
                // Saldo insuficiente apos o request — regista mas nao bloqueia
            }
        }

        return UsageLog::updateOrCreate(
            ['request_id' => $requestId],
            [
                'user_id' => $userId,
                'ai_model_id' => $tier->id,
                'engine_model_id' => $engine->id,
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
        int $tierModelId,
        int $engineModelId,
        string $requestId,
        ?string $generationId,
    ): UsageLog {
        return UsageLog::firstOrCreate(
            ['request_id' => $requestId],
            [
                'user_id' => $userId,
                'ai_model_id' => $tierModelId,
                'engine_model_id' => $engineModelId,
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
    public function recordError(int $userId, int $tierModelId, ?int $engineModelId, string $requestId): UsageLog
    {
        return UsageLog::firstOrCreate(
            ['request_id' => $requestId],
            [
                'user_id' => $userId,
                'ai_model_id' => $tierModelId,
                'engine_model_id' => $engineModelId,
                'prompt_tokens' => 0,
                'completion_tokens' => 0,
                'cost_usd' => 0,
                'charged_usd' => 0,
                'status' => 'error',
                'created_at' => now(),
            ]
        );
    }

    private function calculateCost(AiModel $engine, int $promptTokens, int $completionTokens): float
    {
        $cost = $engine->latestCost();
        if (!$cost) {
            Log::warning('UsageMeter: motor sem custo sincronizado.', ['ai_model_id' => $engine->id]);
            return 0.0;
        }

        $inputCost = ($promptTokens / 1_000_000) * (float) $cost->input_cost_per_mtok;
        $outputCost = ($completionTokens / 1_000_000) * (float) $cost->output_cost_per_mtok;

        return round($inputCost + $outputCost, 8);
    }
}
