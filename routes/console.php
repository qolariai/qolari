<?php

use App\Jobs\AggregateUsageLogs;
use App\Jobs\ExpireCreditLots;
use App\Jobs\SyncModelCosts;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Sync diario de precos OpenRouter (03h00 UTC)
Schedule::job(new SyncModelCosts)->dailyAt('03:00');

// Expiracao mensal de lotes de credito (dia 1, 04h00 UTC)
Schedule::job(new ExpireCreditLots)->monthlyOn(1, '04:00');

// Agregacao mensal de usage_logs > 90 dias (dia 2, 05h00 UTC)
Schedule::job(new AggregateUsageLogs)->monthlyOn(2, '05:00');
