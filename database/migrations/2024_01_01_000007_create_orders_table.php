<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('product_id')->constrained('products');
            $table->char('currency', 3);
            $table->decimal('amount', 10, 2);
            $table->decimal('exchange_rate_used', 12, 6);
            $table->decimal('amount_usd', 10, 2);
            $table->enum('gateway', ['stripe', 'eupago', 'appypay'])->default('stripe');
            $table->enum('status', ['pending', 'paid', 'failed', 'refunded'])->default('pending');
            $table->foreignId('promo_code_id')->nullable()->constrained('promo_codes')->nullOnDelete();
            $table->string('idempotency_key', 100)->unique();
            $table->enum('fulfillment_status', ['na', 'pending', 'delivered'])->default('na');
            $table->timestamps();
            $table->index(['user_id', 'status']);
            $table->index(['status', 'created_at']);
        });

        Schema::create('payment_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->nullable()->constrained('orders');
            $table->string('gateway', 30);
            $table->string('gateway_event_id', 150)->unique();
            $table->string('gateway_payment_id', 150)->nullable();
            $table->string('event_type', 80);
            $table->json('payload')->nullable();
            $table->timestamp('processed_at')->nullable();
            $table->timestamp('created_at')->nullable();
            $table->index('order_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payment_events');
        Schema::dropIfExists('orders');
    }
};
