<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Conversa do Chat (subscrição). Separada da tabela `conversations`
 * do IDE (continuidade de sessão) — são funcionalidades distintas.
 */
class ChatConversation extends Model
{
    protected $fillable = ['user_id', 'title', 'model_slug'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function messages(): HasMany
    {
        return $this->hasMany(ChatMessage::class);
    }
}
