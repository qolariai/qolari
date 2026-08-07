<?php

namespace App\Filament\Resources\Subscriptions\Tables;

use App\Domain\Subscription\SubscriptionService;
use Filament\Actions\Action;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class SubscriptionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('Utilizador')
                    ->searchable(),
                TextColumn::make('user.email')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('plan.name')
                    ->label('Plano')
                    ->sortable(),
                TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active', 'trialing' => 'success',
                        'past_due' => 'warning',
                        'canceled', 'incomplete_expired' => 'danger',
                        default => 'gray',
                    }),
                TextColumn::make('tokens_used')
                    ->label('Tokens usados')
                    ->numeric()
                    ->sortable(),
                TextColumn::make('plan.token_limit')
                    ->label('Teto')
                    ->numeric()
                    ->toggleable(),
                TextColumn::make('current_period_end')
                    ->label('Fim do período')
                    ->dateTime()
                    ->sortable(),
                IconColumn::make('cancel_at_period_end')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->options([
                        'incomplete' => 'incomplete',
                        'trialing' => 'trialing',
                        'active' => 'active',
                        'past_due' => 'past_due',
                        'canceled' => 'canceled',
                        'incomplete_expired' => 'incomplete_expired',
                        'paused' => 'paused',
                    ]),
            ])
            ->recordActions([
                ViewAction::make(),
                Action::make('cancel')
                    ->label('Cancelar')
                    ->color('danger')
                    ->icon('heroicon-o-x-circle')
                    ->requiresConfirmation()
                    ->modalDescription('Marca a subscrição como cancelada e cancela também na Stripe (se configurada).')
                    ->visible(fn ($record): bool => in_array($record->status, ['active', 'trialing', 'past_due'], true))
                    ->action(function ($record): void {
                        app(SubscriptionService::class)->cancelByAdmin($record);
                    }),
            ])
            ->toolbarActions([
                //
            ])
            ->defaultSort('created_at', 'desc');
    }
}
