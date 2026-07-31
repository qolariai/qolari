<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('credit_lots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_id')->constrained('wallets');
            $table->foreignId('order_id')->nullable()->constrained('orders');
            $table->decimal('amount', 14, 4)->comment('USD creditado');
            $table->decimal('remaining', 14, 4)->comment('Ainda por consumir');
            $table->timestamp('expires_at')->comment('created + 12 meses');
            $table->timestamp('created_at')->nullable();
            $table->index(['wallet_id', 'expires_at'], 'idx_lots_fifo');
            $table->index(['expires_at', 'remaining'], 'idx_lots_expiry');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('credit_lots');
    }
};
