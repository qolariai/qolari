<?php

namespace App\Filament\Resources\ModelCosts\Pages;

use App\Filament\Resources\ModelCosts\ModelCostResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditModelCost extends EditRecord
{
    protected static string $resource = ModelCostResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }

    /**
     * Ao editar manualmente, marca o custo como o mais recente (synced_at),
     * para o billing passar a usar estes valores imediatamente.
     */
    protected function mutateFormDataBeforeSave(array $data): array
    {
        $data['synced_at'] = now();

        return $data;
    }
}
