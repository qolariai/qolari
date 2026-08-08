<?php

namespace App\Domain\Proxy;

use App\Models\AiModel;
use App\Models\Setting;

/**
 * Resolve a config de provider upstream (config/ai_providers.php) para um
 * AiModel: base_url, API key (Setting → fallback config/env) e headers extra.
 *
 * Todos os providers são OpenAI-compatible (chat completions + SSE), por isso
 * o proxy é genérico — só muda o endpoint, a key e os headers.
 */
class AiProviderResolver
{
    /**
     * Config resolvida do provider de um modelo (motor).
     *
     * @return array{slug: string, label: string, base_url: string, api_key: string, headers: array<string, string>, extra_body: array<string, mixed>, supports_catalog: bool, supports_generation_lookup: bool}
     */
    public function forModel(AiModel $model): array
    {
        return $this->forSlug($model->provider ?? config('ai_providers.default', 'openrouter'));
    }

    /**
     * @return array{slug: string, label: string, base_url: string, api_key: string, headers: array<string, string>, extra_body: array<string, mixed>, supports_catalog: bool, supports_generation_lookup: bool}
     */
    public function forSlug(string $slug): array
    {
        $config = config("ai_providers.providers.$slug")
            ?? config('ai_providers.providers.' . config('ai_providers.default', 'openrouter'));

        return [
            'slug' => $slug,
            'label' => $config['label'] ?? $slug,
            'base_url' => rtrim($config['base_url'], '/'),
            'api_key' => $this->apiKey($config),
            'headers' => $this->resolveHeaders($config['extra_headers'] ?? []),
            'extra_body' => $config['extra_body'] ?? [],
            'supports_catalog' => (bool) ($config['supports_catalog'] ?? false),
            'supports_generation_lookup' => (bool) ($config['supports_generation_lookup'] ?? false),
        ];
    }

    /**
     * Providers com catálogo remoto de modelos/pricing (slug => config resolvida).
     *
     * @return array<string, array>
     */
    public function catalogProviders(): array
    {
        return collect(config('ai_providers.providers', []))
            ->filter(fn (array $config) => $config['supports_catalog'] ?? false)
            ->mapWithKeys(fn (array $config, string $slug) => [$slug => $this->forSlug($slug)])
            ->all();
    }

    /**
     * Mesma resolução da openrouter_api_key original: Setting (admin,
     * encriptada) com fallback para config/env.
     */
    private function apiKey(array $config): string
    {
        return Setting::get($config['api_key_setting'])
            ?? config($config['api_key_config'], '');
    }

    /**
     * @param  array<string, string>  $headers
     * @return array<string, string>
     */
    private function resolveHeaders(array $headers): array
    {
        return array_map(
            fn (string $value) => str_replace('{app_url}', (string) config('app.url'), $value),
            $headers,
        );
    }
}
