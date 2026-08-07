<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('plan_id')->constrained('subscription_plans');
            $table->string('stripe_subscription_id', 100)->nullable()->unique();
            $table->string('stripe_customer_id', 100)->nullable();
            $table->string('status', 30)->default('incomplete')
                ->comment('trialing|active|past_due|canceled|incomplete_expired|paused');
            $table->timestamp('current_period_start')->nullable();
            $table->timestamp('current_period_end')->nullable();
            $table->unsignedBigInteger('tokens_used')->default(0);
            $table->boolean('cancel_at_period_end')->default(false);
            $table->timestamps();
            $table->index(['user_id', 'status']);
        });

        Schema::create('chat_conversations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('title', 255)->nullable();
            $table->string('model_slug', 100)->nullable()->comment('Tier comercial (ex: nexus-medium)');
            $table->timestamps();
            $table->index('user_id');
        });

        // Append-only (estilo ledger): so created_at, sem updated_at
        Schema::create('chat_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('chat_conversation_id')->constrained('chat_conversations')->cascadeOnDelete();
            $table->string('role', 20)->comment('system|user|assistant');
            $table->longText('content');
            $table->unsignedInteger('tokens')->nullable();
            $table->json('meta')->nullable();
            $table->timestamp('created_at')->nullable();
            $table->index('chat_conversation_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('chat_messages');
        Schema::dropIfExists('chat_conversations');
        Schema::dropIfExists('subscriptions');
    }
};
