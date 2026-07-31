<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UsageController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = $request->user()
            ->usageLogs()
            ->with('aiModel')
            ->latest('created_at');

        // Filtro por modelo
        if ($request->filled('ai_model_id')) {
            $query->where('ai_model_id', $request->integer('ai_model_id'));
        }

        // Filtro por periodo
        if ($request->filled('from')) {
            $query->where('created_at', '>=', $request->date('from'));
        }

        if ($request->filled('to')) {
            $query->where('created_at', '<=', $request->date('to')->endOfDay());
        }

        $usage = $query->paginate(20);

        return response()->json($usage);
    }

    /**
     * Resumo de consumo dos ultimos 30 dias (para grafico).
     */
    public function summary(Request $request): JsonResponse
    {
        $daily = $request->user()
            ->usageLogs()
            ->selectRaw('DATE(created_at) as date, SUM(charged_usd) as total_usd, COUNT(*) as requests')
            ->where('created_at', '>=', now()->subDays(30))
            ->groupByRaw('DATE(created_at)')
            ->orderBy('date')
            ->get();

        return response()->json($daily);
    }
}
