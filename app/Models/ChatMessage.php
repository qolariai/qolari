<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Mensagem do Chat — append-only (estilo ledger): só created_at.
 */
class ChatMessage extends Model
{
    public $timestamps = false;

    protected $fillable = ['chat_conversation_id', 'role', 'content', 'tokens', 'meta', 'created_at'];

    protected function casts(): array
    {
        return [
            'tokens' => 'integer',
            'meta' => 'array',
            'created_at' => 'datetime',
        ];
    }

    public function conversation(): BelongsTo
    {
        return $this->belongsTo(ChatConversation::class, 'chat_conversation_id');
    }
}
