<?php

namespace App\Domain\Briefing;

use App\Models\Briefing;
use App\Models\Conversation;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

/**
 * Session Briefing (3.2-3.4): documento de estado vivo por conversa.
 * Garante que a troca de tiers a meio da sessão nunca perde o fio:
 * o que foi feito, decisões, ficheiros tocados e o que falta.
 */
class BriefingService
{
    public function get(int $userId, string $externalId): ?Briefing
    {
        return Conversation::where('user_id', $userId)
            ->where('external_id', $externalId)
            ->first()?->briefing;
    }

    /**
     * Upsert com controlo otimista de concorrência:
     * se o cliente enviar uma versão desatualizada, 409 com o estado atual.
     */
    public function put(int $userId, string $externalId, string $content, ?int $version, ?string $title = null): Briefing
    {
        return DB::transaction(function () use ($userId, $externalId, $content, $version, $title) {
            $conversation = Conversation::firstOrCreate(
                ['user_id' => $userId, 'external_id' => $externalId],
                ['title' => $title]
            );

            $briefing = Briefing::lockForUpdate()->firstOrNew(['conversation_id' => $conversation->id]);

            if ($briefing->exists && $version !== null && $version < $briefing->version) {
                throw ValidationException::withMessages([
                    'version' => ["Versão desatualizada. Atual: {$briefing->version}."],
                ]);
            }

            $briefing->content = $content;
            $briefing->version = ($briefing->version ?? 0) + 1;
            $briefing->save();

            return $briefing;
        });
    }
}
