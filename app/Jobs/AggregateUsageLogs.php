<?php

namespace App\Jobs;

use App\Models\UsageLog;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Agrega usage_logs com mais de 90 dias em usage_daily e apaga os originais.
 * Corre mensalmente.
 */
class AggregateUsageLogs implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(): void
    {
        $cutoff = now()->subDays(90);

        // Agrupa por (user, model, date) e insere em usage_daily
        $rows = UsageLog::where('created_at', '<', $cutoff)
            ->selectRaw('user_id, ai_model_id, DATE(created_at) as date,
                SUM(prompt_tokens) as prompt_tokens,
                SUM(completion_tokens) as completion_tokens,
                SUM(cost_usd) as cost_usd,
                SUM(charged_usd) as charged_usd,
                COUNT(*) as requests_count')
            ->groupBy('user_id', 'ai_model_id', DB::raw('DATE(created_at)'))
            ->get();

        $aggregated = 0;

        foreach ($rows as $row) {
            DB::table('usage_daily')->updateOrInsert(
                [
                    'user_id' => $row->user_id,
                    'ai_model_id' => $row->ai_model_id,
                    'date' => $row->date,
                ],
                [
                    'prompt_tokens' => DB::raw("prompt_tokens + {$row->prompt_tokens}"),
                    'completion_tokens' => DB::raw("completion_tokens + {$row->completion_tokens}"),
                    'cost_usd' => DB::raw("cost_usd + {$row->cost_usd}"),
                    'charged_usd' => DB::raw("charged_usd + {$row->charged_usd}"),
                    'requests_count' => DB::raw("requests_count + {$row->requests_count}"),
                ]
            );
            $aggregated++;
        }

        // Apaga os originais
        $deleted = UsageLog::where('created_at', '<', $cutoff)->delete();

        Log::info("AggregateUsageLogs: {$aggregated} grupos agregados, {$deleted} linhas apagadas.");
    }
}
