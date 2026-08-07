<?php

namespace App\Filament\Resources\SubscriptionPlans\Schemas;

use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class SubscriptionPlanForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('slug')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->helperText('Identificador interno (ex: chat-basic). Não é mostrado ao cliente.'),
                TextInput::make('name')
                    ->required()
                    ->helperText('Nome white-label mostrado ao cliente.'),
                TextInput::make('token_limit')
                    ->label('Teto de tokens por período')
                    ->required()
                    ->numeric()
                    ->minValue(0),
                TextInput::make('period_days')
                    ->required()
                    ->numeric()
                    ->default(30)
                    ->minValue(1),
                TextInput::make('throttle_percent')
                    ->label('Throttle (%)')
                    ->required()
                    ->numeric()
                    ->default(80)
                    ->minValue(0)
                    ->maxValue(100)
                    ->helperText('Acima desta % do teto, as respostas ficam mais lentas.'),
                TextInput::make('stripe_price_id')
                    ->helperText('Price ID da Stripe (mode subscription). Opcional em testes.'),
                Toggle::make('is_active')
                    ->required(),
                TextInput::make('sort_order')
                    ->required()
                    ->numeric()
                    ->default(0),
                Repeater::make('prices')
                    ->relationship('prices')
                    ->schema([
                        Select::make('currency')
                            ->options(['EUR' => 'EUR', 'USD' => 'USD', 'GBP' => 'GBP'])
                            ->required(),
                        TextInput::make('amount')
                            ->required()
                            ->numeric()
                            ->minValue(0),
                    ])
                    ->columns(2)
                    ->reorderable(false)
                    ->label('Preços por moeda'),
            ]);
    }
}
