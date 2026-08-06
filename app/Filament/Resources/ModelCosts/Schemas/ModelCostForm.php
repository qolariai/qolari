<?php

namespace App\Filament\Resources\ModelCosts\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class ModelCostForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('ai_model_id')
                    ->label('Modelo')
                    ->relationship('aiModel', 'slug')
                    ->getOptionLabelFromRecordUsing(fn ($record) => "{$record->slug} ({$record->provider}: {$record->provider_model_id})")
                    ->searchable()
                    ->preload()
                    ->required()
                    ->helperText('Modelo ao qual este custo se aplica. A tabela é um histórico: podem existir vários custos por modelo — o mais recente (synced_at) é o usado no billing.'),
                TextInput::make('input_cost_per_mtok')
                    ->label('Custo input (USD por 1M tokens)')
                    ->required()
                    ->numeric()
                    ->minValue(0),
                TextInput::make('output_cost_per_mtok')
                    ->label('Custo output (USD por 1M tokens)')
                    ->required()
                    ->numeric()
                    ->minValue(0),
            ]);
    }
}
