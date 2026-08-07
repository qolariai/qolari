<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Chat por subscrição (Fase 3)
    |--------------------------------------------------------------------------
    |
    | O Chat vive num mundo separado da wallet de créditos (Code): o uso
    | conta contra o teto de tokens do período da subscrição, nunca debita
    | saldo. Quando o utilizador ultrapassa o throttle_percent do plano,
    | as respostas ganham latência artificial (soft limit comercial).
    |
    */

    // Latência artificial quando a subscrição está em throttling (ms, cap 2000)
    'throttle_sleep_ms' => (int) env('CHAT_THROTTLE_SLEEP_MS', 1500),

    // Máximo de mensagens de histórico enviadas ao motor por pedido
    'history_limit' => (int) env('CHAT_HISTORY_LIMIT', 50),

];
