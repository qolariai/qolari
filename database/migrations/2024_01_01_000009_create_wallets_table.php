<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('ai_model_id')->constrained('ai_models');
            $table->decimal('balance', 14, 4)->default(0)->comment('USD - cache do ledger');
            $table->timestamps();
            $table->unique(['user_id', 'ai_model_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallets');
    }
};
