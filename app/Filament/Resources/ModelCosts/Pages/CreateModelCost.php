<?php

namespace App\Filament\Resources\ModelCosts\Pages;

use App\Filament\Resources\ModelCosts\ModelCostResource;
use Filament\Resources\Pages\CreateRecord;

class CreateModelCost extends CreateRecord
{
    protected static string $resource = ModelCostResource::class;

    /**
     * Custos manuais (providers diretos, que o SyncModelCosts não toca)
     * passam a ser o "mais recente" — latestCost() ordena por synced_at.
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['synced_at'] = now();
        $data['created_at'] = now();

        return $data;
    }
}
