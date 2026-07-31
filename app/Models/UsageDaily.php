<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UsageDaily extends Model
{
    public $timestamps = false;
    public $incrementing = false;

    protected $primaryKey = null;

    protected $fillable = [
        'user_id', 'ai_model_id', 'date', 'prompt_tokens',
        'completion_tokens', 'cost_usd', 'charged_usd', 'requests_count',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'cost_usd' => 'decimal:6',
            'charged_usd' => 'decimal:6',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function aiModel(): BelongsTo
    {
        return $this->belongsTo(AiModel::class);
    }
}
