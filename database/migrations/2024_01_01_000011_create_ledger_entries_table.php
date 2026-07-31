<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ledger_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_id')->constrained('wallets');
            $table->enum('type', [
                'purchase', 'debit', 'conversion_out', 'conversion_in',
                'expiration', 'admin_adjustment', 'bonus',
            ]);
            $table->decimal('amount', 14, 4)->comment('Signed, USD. Positivo=credito, negativo=debito');
            $table->decimal('balance_after', 14, 4)->comment('USD - auditoria rapida');
            $table->foreignId('credit_lot_id')->nullable()->constrained('credit_lots');
            $table->string('reference_type', 50)->nullable()->comment('order|usage_log|conversion');
            $table->unsignedBigInteger('reference_id')->nullable();
            $table->string('idempotency_key', 100)->nullable()->unique();
            $table->json('meta')->nullable();
            $table->timestamp('created_at')->nullable()->comment('Imutavel - sem updated_at');
            $table->index(['wallet_id', 'created_at']);
            $table->index(['type', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ledger_entries');
    }
};
