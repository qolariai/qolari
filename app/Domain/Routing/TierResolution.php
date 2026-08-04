<?php

namespace App\Domain\Routing;

use App\Models\AiModel;

/**
 * Resultado da resolução de tier:
 *  - tier:   modelo comercial escolhido pelo cliente (define wallet e margem)
 *  - engine: modelo realmente enviado ao provider (define custo real)
 *  - routed: true quando houve routing silencioso (ex: Vision)
 */
class TierResolution
{
    public function __construct(
        public readonly AiModel $tier,
        public readonly AiModel $engine,
        public readonly bool $routed,
    ) {
    }
}
