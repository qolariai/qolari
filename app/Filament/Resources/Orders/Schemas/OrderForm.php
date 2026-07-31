<?php

namespace App\Filament\Resources\Orders\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class OrderForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('user_id')
                    ->relationship('user', 'name')
                    ->required(),
                Select::make('product_id')
                    ->relationship('product', 'name')
                    ->required(),
                TextInput::make('currency')
                    ->required(),
                TextInput::make('amount')
                    ->required()
                    ->numeric(),
                TextInput::make('exchange_rate_used')
                    ->required()
                    ->numeric(),
                TextInput::make('amount_usd')
                    ->required()
                    ->numeric(),
                Select::make('gateway')
                    ->options(['stripe' => 'Stripe', 'eupago' => 'Eupago', 'appypay' => 'Appypay'])
                    ->default('stripe')
                    ->required(),
                Select::make('status')
                    ->options(['pending' => 'Pending', 'paid' => 'Paid', 'failed' => 'Failed', 'refunded' => 'Refunded'])
                    ->default('pending')
                    ->required(),
                Select::make('promo_code_id')
                    ->relationship('promoCode', 'id')
                    ->default(null),
                TextInput::make('idempotency_key')
                    ->required(),
                Select::make('fulfillment_status')
                    ->options(['na' => 'Na', 'pending' => 'Pending', 'delivered' => 'Delivered'])
                    ->default('na')
                    ->required(),
            ]);
    }
}
