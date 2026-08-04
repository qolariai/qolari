<?php

namespace App\Domain\Routing;

use App\Models\AiModel;

/**
 * Resolve o tier pedido pelo cliente para o motor real.
 *
 * Regras:
 *  - O cliente pede um tier comercial (ex: "nexus-medium") — nunca um modelo real.
 *  - Sem tier (clients legacy) → primeiro modelo ativo (comportamento antigo).
 *  - Routing silencioso (1.4): se o pedido tem imagem/ficheiro e o tier não
 *    suporta visão, o motor passa a ser o nexus-vision — mas a cobrança
 *    continua a ser feita à tarifa do tier escolhido pelo cliente.
 */
class TierResolver
{
    public const VISION_TIER_SLUG = 'nexus-vision';

    public function resolve(array $body): TierResolution
    {
        $tierSlug = $this->normalizeTierSlug($body['model'] ?? null);

        $tier = $tierSlug
            ? AiModel::active()->where('slug', $tierSlug)->first()
            : null;

        // Fallback legacy: primeiro ativo por sort_order
        $tier ??= AiModel::active()->orderBy('sort_order')->first();

        if (!$tier) {
            throw new \RuntimeException('Nenhum modelo ativo.');
        }

        $engine = $tier;
        $routed = false;

        if (!$tier->supports_vision && $this->hasVisionContent($body)) {
            $vision = AiModel::active()
                ->where('supports_vision', true)
                ->where('id', '!=', $tier->id)
                ->orderByRaw("slug = ? desc", [self::VISION_TIER_SLUG]) // prefere o nexus-vision
                ->orderBy('sort_order')
                ->first();

            if ($vision) {
                $engine = $vision;
                $routed = true;
            }
            // Se não houver motor com visão disponível, segue com o tier
            // (o provider devolve erro e regista-se status 'error')
        }

        return new TierResolution(tier: $tier, engine: $engine, routed: $routed);
    }

    /**
     * Aceita "nexus-medium" e também "qolari/nexus-medium" (formato provider/model).
     */
    private function normalizeTierSlug(?string $model): ?string
    {
        if (!$model) {
            return null;
        }

        return str_contains($model, '/') ? substr($model, strrpos($model, '/') + 1) : $model;
    }

    /**
     * Deteta conteúdo multimodal (imagem/ficheiro) nas mensagens.
     * Formatos: OpenAI content parts (image_url, input_image, file).
     */
    private function hasVisionContent(array $body): bool
    {
        foreach ($body['messages'] ?? [] as $message) {
            $content = $message['content'] ?? null;
            if (!is_array($content)) {
                continue;
            }

            foreach ($content as $part) {
                $type = $part['type'] ?? null;
                if (in_array($type, ['image_url', 'image', 'input_image', 'file'], true)) {
                    return true;
                }
            }
        }

        return false;
    }
}
