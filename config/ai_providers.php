<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Providers de IA upstream (todos OpenAI-compatible)
    |--------------------------------------------------------------------------
    |
    | Cada AiModel.provider aponta para uma entrada aqui. O proxy resolve
    | base_url + API key a partir desta config — NUNCA hardcodar keys, só
    | os nomes das settings (admin) / configs (env) onde a key vive.
    |
    | - api_key_setting: chave em settings (Setting::get, encriptada, editável no admin)
    | - api_key_config:  fallback em config/services.php (env)
    | - supports_catalog: tem endpoint /models com pricing (só a OpenRouter) —
    |   o SyncModelCosts só sincroniza estes providers
    | - supports_generation_lookup: tem endpoint /generation para reconciliar
    |   usage pós-stream (só a OpenRouter); os demais caem na estimativa
    | - extra_headers: headers específicos do provider ('{app_url}' = config('app.url'))
    |
    */

    'default' => 'openrouter',

    'providers' => [

        'openrouter' => [
            'label' => 'OpenRouter',
            'base_url' => 'https://openrouter.ai/api/v1',
            'api_key_setting' => 'openrouter_api_key',
            'api_key_config' => 'services.openrouter.api_key',
            'supports_catalog' => true,
            'supports_generation_lookup' => true,
            'extra_headers' => [
                'HTTP-Referer' => '{app_url}',
                'X-Title' => 'Qolari',
            ],
        ],

        'deepseek' => [
            'label' => 'DeepSeek (direto)',
            'base_url' => 'https://api.deepseek.com',
            'api_key_setting' => 'deepseek_api_key',
            'api_key_config' => 'services.deepseek.api_key',
            'supports_catalog' => false,
            'supports_generation_lookup' => false,
            'extra_headers' => [],
        ],

        'nvidia' => [
            'label' => 'NVIDIA NIM',
            'base_url' => 'https://integrate.api.nvidia.com/v1',
            'api_key_setting' => 'nvidia_api_key',
            'api_key_config' => 'services.nvidia.api_key',
            'supports_catalog' => false,
            'supports_generation_lookup' => false,
            'extra_headers' => [],
        ],

    ],

];
