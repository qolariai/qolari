<?php

namespace App\Http\Controllers\Api;

use App\Domain\Chat\ChatService;
use App\Domain\Subscription\SubscriptionService;
use App\Http\Controllers\Controller;
use App\Models\ChatConversation;
use App\Models\ChatMessage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Chat por subscrição (Fase 3). Mundo separado da wallet de créditos:
 * o uso conta contra o teto de tokens do período. 402 sem subscrição,
 * 429 teto atingido, 404 conversa de outro utilizador.
 */
class ChatController extends Controller
{
    public function __construct(
        private ChatService $chatService,
        private SubscriptionService $subscriptionService,
    ) {
    }

    /**
     * GET /api/v1/chat/conversations — lista paginada do utilizador.
     */
    public function index(Request $request): JsonResponse
    {
        $conversations = $request->user()->chatConversations()
            ->withCount('messages')
            ->latest('updated_at')
            ->latest('id') // desempate quando o updated_at é do mesmo segundo
            ->paginate(15);

        return response()->json($conversations);
    }

    /**
     * POST /api/v1/chat/conversations — cria conversa.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'nullable|string|max:255',
            'model_slug' => 'nullable|string|max:100',
        ]);

        $conversation = $request->user()->chatConversations()->create([
            'title' => $validated['title'] ?? null,
            'model_slug' => $validated['model_slug'] ?? null,
        ]);

        return response()->json(['conversation' => $conversation], 201);
    }

    /**
     * DELETE /api/v1/chat/conversations/{id} — só o dono.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $conversation = $this->conversationFor($request, $id);

        $conversation->delete(); // mensagens caem em cascata (FK)

        return response()->json(['deleted' => true]);
    }

    /**
     * GET /api/v1/chat/conversations/{id}/messages — histórico (asc).
     */
    public function messages(Request $request, int $id): JsonResponse
    {
        $conversation = $this->conversationFor($request, $id);

        $messages = $conversation->messages()
            ->orderBy('id')
            ->paginate(50);

        return response()->json($messages);
    }

    /**
     * POST /api/v1/chat/conversations/{id}/messages — envia mensagem.
     * stream=true → SSE passthrough; caso contrário JSON com a resposta.
     */
    public function sendMessage(Request $request, int $id)
    {
        $conversation = $this->conversationFor($request, $id);

        $validated = $request->validate([
            'content' => 'required|string|max:32000',
            'stream' => 'nullable|boolean',
        ]);

        // Persiste a mensagem do utilizador antes do acesso (fica no histórico)
        ChatMessage::create([
            'chat_conversation_id' => $conversation->id,
            'role' => 'user',
            'content' => $validated['content'],
            'created_at' => now(),
        ]);

        // 402 sem subscrição / 429 teto atingido (exceções com render)
        $subscription = $this->subscriptionService->ensureChatAccess($request->user());

        // Throttling comercial: acima do throttle_percent, latência artificial
        $throttled = $this->subscriptionService->isThrottled($subscription);
        if ($throttled) {
            $sleepMs = min((int) config('chat.throttle_sleep_ms', 1500), 2000);
            if ($sleepMs > 0) {
                usleep($sleepMs * 1000);
            }
        }

        if (!empty($validated['stream'])) {
            return $this->chatService->stream($request->user(), $conversation, $subscription, $throttled);
        }

        $result = $this->chatService->complete($request->user(), $conversation, $subscription);

        if ($result['status'] !== 200) {
            // WHITE-LABEL: erro upstream genérico, sem detalhes de provider
            return response()->json([
                'error' => [
                    'message' => 'O serviço de IA está temporariamente indisponível. Tente novamente.',
                    'code' => 'upstream_error',
                ],
            ], 502);
        }

        $response = response()->json([
            'message' => $result['message'],
            'usage' => $result['usage'],
        ]);

        if ($throttled) {
            $response->headers->set('X-Qolari-Throttled', '1');
        }

        return $response;
    }

    /**
     * Conversa do utilizador autenticado — 404 para não-donos.
     */
    private function conversationFor(Request $request, int $id): ChatConversation
    {
        return ChatConversation::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();
    }
}
