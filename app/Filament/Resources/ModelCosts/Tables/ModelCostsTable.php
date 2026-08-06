<?php

namespace App\Filament\Resources\ModelCosts\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ModelCostsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('aiModel.slug')
                    ->label('Modelo')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('aiModel.provider')
                    ->label('Provider')
                    ->badge()
                    ->searchable(),
                TextColumn::make('input_cost_per_mtok')
                    ->label('Input $/MTok')
                    ->numeric(decimalPlaces: 6)
                    ->sortable(),
                TextColumn::make('output_cost_per_mtok')
                    ->label('Output $/MTok')
                    ->numeric(decimalPlaces: 6)
                    ->sortable(),
                TextColumn::make('synced_at')
                    ->label('Sincronizado em')
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label('Criado em')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('synced_at', 'desc')
            ->filters([
                //
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
