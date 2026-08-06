<?php

namespace App\Filament\Resources\ModelCosts;

use App\Filament\Resources\ModelCosts\Pages\CreateModelCost;
use App\Filament\Resources\ModelCosts\Pages\EditModelCost;
use App\Filament\Resources\ModelCosts\Pages\ListModelCosts;
use App\Filament\Resources\ModelCosts\Schemas\ModelCostForm;
use App\Filament\Resources\ModelCosts\Tables\ModelCostsTable;
use App\Models\ModelCost;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class ModelCostResource extends Resource
{
    protected static ?string $model = ModelCost::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    public static function form(Schema $schema): Schema
    {
        return ModelCostForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return ModelCostsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListModelCosts::route('/'),
            'create' => CreateModelCost::route('/create'),
            'edit' => EditModelCost::route('/{record}/edit'),
        ];
    }
}
