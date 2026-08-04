<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UsageLog extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id', 'ai_model_id', 'engine_model_id', 'request_id', 'generation_id', 'prompt_tokens',
        'completion_tokens', 'cost_usd', 'charged_usd', 'ledger_entry_id',
        'status', 'created_at',
    ];

    protected function casts(): array
    {
        return [
            'cost_usd' => 'decimal:8',
            'charged_usd' => 'decimal:8',
            'created_at' => 'datetime',
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

    public function ledgerEntry(): BelongsTo
    {
        return $this->belongsTo(LedgerEntry::class);
    }
}
