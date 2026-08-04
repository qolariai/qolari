<?php

namespace App\Filament\Resources\AiModels\Schemas;

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
                TextInput::make('provider')
                    ->required()
                    ->default('openrouter'),
                TextInput::make('provider_model_id')
                    ->required()
                    ->helperText('ID real no OpenRouter (ex: moonshotai/kimi-k2.7-code). Nunca visível ao cliente.'),
                Toggle::make('supports_vision')
                    ->helperText('Sincronizado automaticamente pelo SyncModelCosts; ajuste manual se necessário.'),
                TextInput::make('context_limit')
                    ->numeric()
                    ->default(null)
                    ->helperText('Janela de contexto (tokens). Sincronizado do OpenRouter.'),
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
