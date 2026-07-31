<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('commissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('promo_code_id')->constrained('promo_codes');
            $table->foreignId('order_id')->constrained('orders');
            $table->decimal('amount_usd', 10, 2);
            $table->enum('status', ['pending', 'paid', 'cancelled'])->default('pending');
            $table->timestamp('paid_at')->nullable();
            $table->string('notes', 255)->nullable();
            $table->timestamps();
            $table->unique('order_id');
            $table->index(['status', 'promo_code_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('commissions');
    }
};
