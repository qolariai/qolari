<?php

namespace Tests\Feature;

use App\Models\ChatMessage;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/**
 * CRUD de conversas do Chat + isolamento entre utilizadores
 * (o user B não lê nem apaga conversas do user A).
 */
class ChatConversationsTest extends TestCase
{
    use RefreshDatabase;

    private User $userA;
    private User $userB;

    protected function setUp(): void
    {
        parent::setUp();

        $this->userA = User::factory()->create();
        $this->userB = User::factory()->create();
    }

    public function test_user_can_create_and_list_conversations(): void
    {
        Sanctum::actingAs($this->userA);

        $create = $this->postJson('/api/v1/chat/conversations', [
            'title' => 'Brainstorm produto',
            'model_slug' => 'nexus-medium',
        ]);

        $create->assertCreated()
            ->assertJsonPath('conversation.title', 'Brainstorm produto')
            ->assertJsonPath('conversation.model_slug', 'nexus-medium');

        $this->postJson('/api/v1/chat/conversations', ['title' => 'Segunda conversa'])->assertCreated();

        $list = $this->getJson('/api/v1/chat/conversations');
        $list->assertOk()
            ->assertJsonPath('total', 2)
            ->assertJsonPath('data.0.title', 'Segunda conversa'); // mais recente primeiro
    }

    public function test_user_can_create_conversation_without_title(): void
    {
        Sanctum::actingAs($this->userA);

        $this->postJson('/api/v1/chat/conversations', [])->assertCreated();

        $this->assertDatabaseHas('chat_conversations', [
            'user_id' => $this->userA->id,
            'title' => null,
        ]);
    }

    public function test_user_can_list_messages_of_own_conversation(): void
    {
        $conversation = $this->userA->chatConversations()->create(['title' => 'Histórico']);
        ChatMessage::create([
            'chat_conversation_id' => $conversation->id,
            'role' => 'user',
            'content' => 'Primeira',
            'created_at' => now()->subMinute(),
        ]);
        ChatMessage::create([
            'chat_conversation_id' => $conversation->id,
            'role' => 'assistant',
            'content' => 'Resposta',
            'tokens' => 12,
            'created_at' => now(),
        ]);

        Sanctum::actingAs($this->userA);

        $response = $this->getJson("/api/v1/chat/conversations/{$conversation->id}/messages");

        $response->assertOk()
            ->assertJsonPath('total', 2)
            ->assertJsonPath('data.0.role', 'user')
            ->assertJsonPath('data.0.content', 'Primeira')
            ->assertJsonPath('data.1.role', 'assistant')
            ->assertJsonPath('data.1.tokens', 12);
    }

    public function test_user_can_delete_own_conversation_and_messages_cascade(): void
    {
        $conversation = $this->userA->chatConversations()->create(['title' => 'Para apagar']);
        ChatMessage::create([
            'chat_conversation_id' => $conversation->id,
            'role' => 'user',
            'content' => 'mensagem',
            'created_at' => now(),
        ]);

        Sanctum::actingAs($this->userA);

        $this->deleteJson("/api/v1/chat/conversations/{$conversation->id}")
            ->assertOk()
            ->assertJsonPath('deleted', true);

        $this->assertDatabaseMissing('chat_conversations', ['id' => $conversation->id]);
        $this->assertDatabaseMissing('chat_messages', ['chat_conversation_id' => $conversation->id]);
    }

    public function test_other_user_cannot_read_messages(): void
    {
        $conversation = $this->userA->chatConversations()->create(['title' => 'Privada']);
        ChatMessage::create([
            'chat_conversation_id' => $conversation->id,
            'role' => 'user',
            'content' => 'segredo',
            'created_at' => now(),
        ]);

        Sanctum::actingAs($this->userB);

        $this->getJson("/api/v1/chat/conversations/{$conversation->id}/messages")->assertNotFound();
    }

    public function test_other_user_cannot_delete(): void
    {
        $conversation = $this->userA->chatConversations()->create(['title' => 'Privada']);

        Sanctum::actingAs($this->userB);

        $this->deleteJson("/api/v1/chat/conversations/{$conversation->id}")->assertNotFound();

        $this->assertDatabaseHas('chat_conversations', ['id' => $conversation->id]);
    }

    public function test_conversations_are_scoped_to_owner(): void
    {
        $this->userA->chatConversations()->create(['title' => 'Do A']);
        $this->userB->chatConversations()->create(['title' => 'Do B']);

        Sanctum::actingAs($this->userA);

        $response = $this->getJson('/api/v1/chat/conversations');

        $response->assertOk()->assertJsonPath('total', 1);
        $this->assertStringNotContainsString('Do B', $response->getContent());
    }

    public function test_guest_cannot_access_chat_routes(): void
    {
        $this->getJson('/api/v1/chat/conversations')->assertUnauthorized();
        $this->postJson('/api/v1/chat/conversations', [])->assertUnauthorized();
    }
}
