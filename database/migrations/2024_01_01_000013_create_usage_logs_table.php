<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('usage_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('ai_model_id')->constrained('ai_models');
            $table->string('request_id', 100)->unique()->comment('Idempotencia do debito');
            $table->unsignedInteger('prompt_tokens')->default(0);
            $table->unsignedInteger('completion_tokens')->default(0);
            $table->decimal('cost_usd', 16, 8)->comment('Custo real OpenRouter');
            $table->decimal('charged_usd', 16, 8)->comment('Debito ao cliente (custo x margem)');
            $table->foreignId('ledger_entry_id')->nullable()->constrained('ledger_entries');
            $table->enum('status', ['ok', 'error'])->default('ok');
            $table->timestamp('created_at')->nullable();
            $table->index(['user_id', 'created_at']);
            $table->index('created_at', 'idx_usage_purge');
        });

        Schema::create('usage_daily', function (Blueprint $table) {
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('ai_model_id')->constrained('ai_models');
            $table->date('date');
            $table->unsignedBigInteger('prompt_tokens')->default(0);
            $table->unsignedBigInteger('completion_tokens')->default(0);
            $table->decimal('cost_usd', 14, 6)->default(0);
            $table->decimal('charged_usd', 14, 6)->default(0);
            $table->unsignedInteger('requests_count')->default(0);
            $table->primary(['user_id', 'ai_model_id', 'date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('usage_daily');
        Schema::dropIfExists('usage_logs');
    }
};
