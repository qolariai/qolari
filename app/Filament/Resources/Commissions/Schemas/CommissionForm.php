<?php

namespace App\Filament\Resources\Commissions\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class CommissionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('promo_code_id')
                    ->relationship('promoCode', 'id')
                    ->required(),
                Select::make('order_id')
                    ->relationship('order', 'id')
                    ->required(),
                TextInput::make('amount_usd')
                    ->required()
                    ->numeric(),
                Select::make('status')
                    ->options(['pending' => 'Pending', 'paid' => 'Paid', 'cancelled' => 'Cancelled'])
                    ->default('pending')
                    ->required(),
                DateTimePicker::make('paid_at'),
                TextInput::make('notes')
                    ->default(null),
            ]);
    }
}
