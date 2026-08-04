<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('conversations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->string('external_id', 100)->comment('ID da sessão no IDE');
            $table->string('title', 150)->nullable();
            $table->timestamps();
            $table->unique(['user_id', 'external_id']);
        });

        Schema::create('briefings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conversation_id')->unique()->constrained('conversations')->cascadeOnDelete();
            $table->longText('content')->comment('Estado vivo da sessão (feito/decisões/ficheiros/pendente)');
            $table->unsignedInteger('version')->default(1)->comment('Controlo otimista de concorrência');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('briefings');
        Schema::dropIfExists('conversations');
    }
};
