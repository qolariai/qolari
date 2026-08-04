<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('ai_models', function (Blueprint $table) {
            $table->boolean('supports_vision')->default(false)->after('provider_model_id')
                ->comment('Sincronizado do OpenRouter (architecture.modality)');
            $table->unsignedInteger('context_limit')->nullable()->after('supports_vision')
                ->comment('Janela de contexto em tokens (OpenRouter context_length)');
        });

        Schema::table('usage_logs', function (Blueprint $table) {
            $table->foreignId('engine_model_id')->nullable()->after('ai_model_id')
                ->constrained('ai_models')
                ->comment('Modelo realmente usado (≠ ai_model_id quando houve routing silencioso, ex: Vision)');
        });
    }

    public function down(): void
    {
        Schema::table('usage_logs', function (Blueprint $table) {
            $table->dropConstrainedForeignId('engine_model_id');
        });
        Schema::table('ai_models', function (Blueprint $table) {
            $table->dropColumn(['supports_vision', 'context_limit']);
        });
    }
};
