<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('promo_codes', function (Blueprint $table) {
            $table->id();
            $table->string('code', 50)->unique();
            $table->string('owner_name', 150);
            $table->string('owner_contact', 190)->nullable();
            $table->decimal('commission_percent', 5, 2);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // FK adiada: users.promo_code_id -> promo_codes.id
        Schema::table('users', function (Blueprint $table) {
            $table->foreign('promo_code_id')->references('id')->on('promo_codes')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['promo_code_id']);
        });
        Schema::dropIfExists('promo_codes');
    }
};
