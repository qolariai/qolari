<?php

namespace App\Filament\Resources\ModelCosts\Pages;

use App\Filament\Resources\ModelCosts\ModelCostResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListModelCosts extends ListRecords
{
    protected static string $resource = ModelCostResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
