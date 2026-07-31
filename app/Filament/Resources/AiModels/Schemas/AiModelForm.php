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
                    ->required(),
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
