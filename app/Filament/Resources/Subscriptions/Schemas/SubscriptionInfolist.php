<?php

namespace App\Filament\Resources\Subscriptions\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class SubscriptionInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('Utilizador'),
                TextEntry::make('user.email'),
                TextEntry::make('plan.name')
                    ->label('Plano'),
                TextEntry::make('status')
                    ->badge(),
                TextEntry::make('tokens_used')
                    ->label('Tokens usados')
                    ->numeric(),
                TextEntry::make('plan.token_limit')
                    ->label('Teto de tokens')
                    ->numeric(),
                TextEntry::make('current_period_start')
                    ->dateTime(),
                TextEntry::make('current_period_end')
                    ->dateTime(),
                IconEntry::make('cancel_at_period_end')
                    ->boolean()
                    ->label('Cancela no fim do período'),
                TextEntry::make('stripe_subscription_id')
                    ->label('Stripe Subscription ID')
                    ->placeholder('—'),
                TextEntry::make('stripe_customer_id')
                    ->label('Stripe Customer ID')
                    ->placeholder('—'),
                TextEntry::make('created_at')
                    ->dateTime(),
            ]);
    }
}
