<?php

namespace App\Filament\Resources\AiModels\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class AiModelForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('slug')
                    ->required(),
                TextInput::make('display_name')
                    ->required(),
                TextInput::make('description')
                    ->default(null),
                Select::make('provider')
                    ->required()
                    ->default(config('ai_providers.default', 'openrouter'))
                    ->options(collect(config('ai_providers.providers', []))
                        ->mapWithKeys(fn (array $config, string $slug) => [$slug => $config['label'] ?? $slug]))
                    ->helperText('Provider upstream (config/ai_providers.php). Só providers com catálogo são sincronizados pelo SyncModelCosts.'),
                TextInput::make('provider_model_id')
                    ->required()
                    ->helperText('ID real no provider (ex: deepseek-chat, moonshotai/kimi-k2.7-code). Nunca visível ao cliente.'),
                Toggle::make('supports_vision')
                    ->helperText('Sincronizado automaticamente pelo SyncModelCosts (só providers com catálogo); ajuste manual se necessário.'),
                TextInput::make('context_limit')
                    ->numeric()
                    ->default(null)
                    ->helperText('Janela de contexto (tokens). Sincronizado do catálogo do provider, se existir.'),
                TextInput::make('margin_multiplier')
                    ->required()
                    ->numeric()
                    ->default(3.0),
                Toggle::make('is_active')
                    ->required(),
                TextInput::make('sort_order')
                    ->required()
                    ->numeric()
                    ->default(0),
            ]);
    }
}
