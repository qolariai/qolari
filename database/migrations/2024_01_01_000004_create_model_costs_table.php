<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('model_costs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ai_model_id')->constrained('ai_models');
            $table->decimal('input_cost_per_mtok', 12, 6);
            $table->decimal('output_cost_per_mtok', 12, 6);
            $table->timestamp('synced_at')->nullable();
            $table->timestamp('created_at')->nullable();
            $table->index(['ai_model_id', 'synced_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('model_costs');
    }
};
