<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('usage_logs', function (Blueprint $table) {
            $table->string('generation_id', 100)->nullable()->after('request_id')
                ->comment('ID da geracao OpenRouter (reconciliacao pos-stream)');
            $table->enum('status', ['ok', 'error', 'pending', 'estimated'])->default('ok')->change();
        });
    }

    public function down(): void
    {
        Schema::table('usage_logs', function (Blueprint $table) {
            $table->dropColumn('generation_id');
            $table->enum('status', ['ok', 'error'])->default('ok')->change();
        });
    }
};
