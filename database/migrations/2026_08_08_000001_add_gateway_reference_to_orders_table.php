<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            // Referência externa do gateway (ex.: charge id da AppyPay)
            $table->string('gateway_reference', 100)->nullable()->after('gateway');
            $table->index('gateway_reference');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropIndex(['gateway_reference']);
            $table->dropColumn('gateway_reference');
        });
    }
};
