<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_models', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 50)->unique();
            $table->string('display_name', 100);
            $table->string('description', 255)->nullable();
            $table->string('provider', 50)->default('openrouter');
            $table->string('provider_model_id', 150);
            $table->decimal('margin_multiplier', 5, 2)->default(3.00);
            $table->boolean('is_active')->default(true);
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_models');
    }
};
