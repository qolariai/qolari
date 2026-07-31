<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ModelCost extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'ai_model_id', 'input_cost_per_mtok', 'output_cost_per_mtok', 'synced_at', 'created_at',
    ];

    protected function casts(): array
    {
        return [
            'input_cost_per_mtok' => 'decimal:6',
            'output_cost_per_mtok' => 'decimal:6',
            'synced_at' => 'datetime',
            'created_at' => 'datetime',
        ];
    }

    public function aiModel(): BelongsTo
    {
        return $this->belongsTo(AiModel::class);
    }
}
