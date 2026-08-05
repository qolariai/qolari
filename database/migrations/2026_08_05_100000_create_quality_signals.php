<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('quality_signals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->string('tier', 50)->comment('Tier comercial em uso (nexus-high, ...)');
            $table->string('engine', 150)->nullable()->comment('Motor real (uso interno)');
            $table->string('event', 30)->comment('accept | retry | abort | edit_after | regenerate');
            $table->string('conversation_id', 100)->nullable();
            $table->json('meta')->nullable();
            $table->timestamp('created_at')->nullable();
            $table->index(['tier', 'event', 'created_at']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('quality_signals');
    }
};
