<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscription_plans', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 100)->unique()->comment('Ex: chat-basic — identificador interno');
            $table->string('name', 150)->comment('Nome white-label, editavel pelo admin');
            $table->unsignedBigInteger('token_limit')->comment('Teto de tokens por periodo');
            $table->unsignedInteger('period_days')->default(30);
            $table->unsignedTinyInteger('throttle_percent')->default(80)
                ->comment('Acima desta % do teto, as respostas ficam artificialmente mais lentas');
            $table->string('stripe_price_id', 100)->nullable();
            $table->boolean('is_active')->default(true);
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('subscription_plan_prices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('plan_id')->constrained('subscription_plans')->cascadeOnDelete();
            $table->char('currency', 3);
            $table->decimal('amount', 10, 2);
            $table->timestamps();
            $table->unique(['plan_id', 'currency']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscription_plan_prices');
        Schema::dropIfExists('subscription_plans');
    }
};
