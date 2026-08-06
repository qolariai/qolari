<?php

namespace App\Filament\Resources\Products\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class ProductForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('type')
                    ->options(['package' => 'Package', 'bundle' => 'Bundle'])
                    ->default('package')
                    ->required(),
                Select::make('ai_model_id')
                    ->relationship('aiModel', 'id')
                    ->required(),
                TextInput::make('name')
                    ->required(),
                Textarea::make('description')
                    ->default(null)
                    ->columnSpanFull(),
                TextInput::make('credits_usd')
                    ->required()
                    ->numeric(),
                TextInput::make('repo_reference')
                    ->default(null),
                Textarea::make('delivery_notes')
                    ->default(null)
                    ->columnSpanFull(),
                Toggle::make('is_active')
                    ->required(),
                Toggle::make('is_featured')
                    ->label('Destacado ("Popular")')
                    ->helperText('Mostra o badge "Popular" no card deste produto na página de preços.'),
                TextInput::make('sort_order')
                    ->required()
                    ->numeric()
                    ->default(0),
            ]);
    }
}
