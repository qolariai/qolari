<?php

namespace App\Filament\Resources\Subscriptions\Pages;

use App\Domain\Subscription\SubscriptionService;
use App\Filament\Resources\Subscriptions\SubscriptionResource;
use Filament\Actions\Action;
use Filament\Resources\Pages\ViewRecord;

class ViewSubscription extends ViewRecord
{
    protected static string $resource = SubscriptionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('cancel')
                ->label('Cancelar subscrição')
                ->color('danger')
                ->requiresConfirmation()
                ->modalDescription('Marca a subscrição como cancelada e cancela também na Stripe (se configurada).')
                ->visible(fn (): bool => in_array($this->record->status, ['active', 'trialing', 'past_due'], true))
                ->action(function (): void {
                    app(SubscriptionService::class)->cancelByAdmin($this->record);
                }),
        ];
    }
}
