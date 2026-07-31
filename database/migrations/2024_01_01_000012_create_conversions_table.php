<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('conversions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('from_wallet_id')->constrained('wallets');
            $table->foreignId('to_wallet_id')->constrained('wallets');
            $table->decimal('amount', 14, 4)->comment('USD retirado da origem');
            $table->decimal('fee_percent', 5, 2);
            $table->decimal('fee_amount', 14, 4)->comment('USD retido');
            $table->decimal('credited_amount', 14, 4)->comment('USD creditado no destino');
            $table->timestamp('created_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('conversions');
    }
};
