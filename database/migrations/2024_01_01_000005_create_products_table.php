<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->enum('type', ['package', 'bundle'])->default('package');
            $table->foreignId('ai_model_id')->constrained('ai_models');
            $table->string('name', 150);
            $table->text('description')->nullable();
            $table->decimal('credits_usd', 10, 2)->comment('Valor facial dos creditos em USD');
            $table->string('repo_reference', 255)->nullable();
            $table->text('delivery_notes')->nullable();
            $table->boolean('is_active')->default(true);
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('product_prices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained('products')->cascadeOnDelete();
            $table->char('currency', 3);
            $table->decimal('price', 10, 2);
            $table->timestamps();
            $table->unique(['product_id', 'currency']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('product_prices');
        Schema::dropIfExists('products');
    }
};
