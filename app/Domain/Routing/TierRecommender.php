<?php

namespace App\Domain\Routing;

/**
 * Recomendador de tiers (v1, rule-based).
 *
 * Analisa o pedido e sugere um tier mais adequado que o atual — tanto
 * upgrade (qualidade) como downgrade (poupança = confiança do cliente).
 * Sugere, NUNCA impõe. O Nexus Auto (flag do user) é que aplica em silêncio.
 */
class TierRecommender
{
    /** Frases que indicam tarefa complexa (pt/en, minúsculas) */
    private const COMPLEX_PHRASES = [
        'arquitetura', 'arquitectura', 'architecture',
        'migrar', 'migração', 'migrate', 'migration',
        'refatorar tudo', 'refatorar o projeto', 'refactor',
        'otimizar tudo', 'optimize everything', 'otimiza o projeto',
        'desenha do zero', 'from scratch', 'do zero',
        'em produção', 'in production', 'produção',
        'porque não funciona', 'porque nao funciona', 'why does', "why doesn't",
        'debug', 'race condition', 'memory leak',
    ];

    /** Padrões de tarefa simples (pt/en, minúsculas) */
    private const SIMPLE_PATTERNS = [
        'typo', 'renomeia', 'rename', 'formata', 'format',
        'corrige', 'corrija', 'fix this', 'fix the',
        'explica', 'explain', 'o que faz', 'what does',
        'comenta', 'add a comment', 'traduz', 'translate',
    ];

    /** Janela de referência do Medium para a regra de contexto */
    private const MEDIUM_CONTEXT = 128_000;

    /**
     * @return array{tier: string, direction: 'up'|'down', reason: string}|null
     */
    public function suggest(string $currentTier, array $body): ?array
    {
        // Com imagem/ficheiro o routing de visão trata — não sugerir nada
        if ($this->hasVisionContent($body)) {
            return null;
        }

        $text = $this->lastUserText($body);
        $estimatedTokens = (int) ceil(mb_strlen(json_encode($body['messages'] ?? [])) / 4);

        // Contexto grande → High (não é questão de qualidade, é de cabimento)
        if ($estimatedTokens > self::MEDIUM_CONTEXT * 0.6 && $currentTier !== 'nexus-high') {
            return ['tier' => 'nexus-high', 'direction' => 'up', 'reason' => 'large_context'];
        }

        // Tarefa complexa → High
        if ($currentTier !== 'nexus-high' && $this->matchesAny($text, self::COMPLEX_PHRASES)) {
            return ['tier' => 'nexus-high', 'direction' => 'up', 'reason' => 'complex_task'];
        }

        // Tarefa simples (e curta) → Low (poupança)
        if ($currentTier !== 'nexus-low'
            && mb_strlen($text) < 200
            && $this->matchesAny($text, self::SIMPLE_PATTERNS)) {
            return ['tier' => 'nexus-low', 'direction' => 'down', 'reason' => 'simple_task'];
        }

        return null;
    }

    /**
     * Escolha silenciosa para o Nexus Auto: devolve o tier ideal para o pedido,
     * ou null para manter o tier atual. Reutiliza a mesma matriz.
     */
    public function pickForAuto(string $currentTier, array $body): ?string
    {
        return $this->suggest($currentTier, $body)['tier'] ?? null;
    }

    private function matchesAny(string $text, array $needles): bool
    {
        $text = mb_strtolower($text);
        foreach ($needles as $needle) {
            if (str_contains($text, $needle)) {
                return true;
            }
        }
        return false;
    }

    private function lastUserText(array $body): string
    {
        $messages = array_filter(
            $body['messages'] ?? [],
            fn ($m) => ($m['role'] ?? null) === 'user'
        );
        $last = end($messages);
        $content = $last['content'] ?? '';

        if (is_string($content)) {
            return $content;
        }

        // content parts → junta os textos
        return collect($content)->where('type', 'text')->pluck('text')->implode(' ');
    }

    private function hasVisionContent(array $body): bool
    {
        foreach ($body['messages'] ?? [] as $message) {
            $content = $message['content'] ?? null;
            if (!is_array($content)) {
                continue;
            }
            foreach ($content as $part) {
                if (in_array($part['type'] ?? null, ['image_url', 'image', 'input_image', 'file'], true)) {
                    return true;
                }
            }
        }
        return false;
    }
}
