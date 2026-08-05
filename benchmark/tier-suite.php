<?php

/**
 * Suite de regressão dos tiers Nexus (Fase 4.2).
 *
 * Cada item: name, category, messages, e expectativas:
 *  - expect_any:     pelo menos UMA destas strings (minúsculas) na resposta
 *  - expect_absent:  nenhuma destas strings na resposta
 *  - max_tokens:     teto de output
 *  - requires_vision: só corre em motores multimodais
 *
 * Corre com: php artisan qolari:benchmark {tier?}
 * Usar SEMPRE antes de trocar o motor de um tier (ver docs/MODEL_CHANGELOG.md).
 */
return [
    // ── Geração de código ─────────────────────────────────────────────
    ['name' => 'php-function', 'category' => 'code_gen', 'max_tokens' => 300,
     'messages' => [['role' => 'user', 'content' => 'Escreve uma função PHP chamada slugify que converte "Olá Mundo!" em "ola-mundo". Só código.']],
     'expect_any' => ['function slugify', 'slugify(']],

    ['name' => 'typescript-type', 'category' => 'code_gen', 'max_tokens' => 300,
     'messages' => [['role' => 'user', 'content' => 'Write a TypeScript interface User with id:number, email:string, tags:string[]. Interface only.']],
     'expect_any' => ['interface User', 'email']],

    ['name' => 'sql-query', 'category' => 'code_gen', 'max_tokens' => 200,
     'messages' => [['role' => 'user', 'content' => 'SQL: tabela orders(id,total,created_at). Query dos 5 maiores totais do último mês. Só a query.']],
     'expect_any' => ['select', 'order by']],

    ['name' => 'regex', 'category' => 'code_gen', 'max_tokens' => 150,
     'messages' => [['role' => 'user', 'content' => 'Regex para validar email simples. Responde só com a regex.']],
     'expect_any' => ['@']],

    // ── Refatoração ───────────────────────────────────────────────────
    ['name' => 'refactor-early-return', 'category' => 'refactor', 'max_tokens' => 400,
     'messages' => [['role' => 'user', 'content' => "Refatora com early returns:\nfunction f(\$x){ if(\$x>0){ if(\$x<10){ return 'ok'; } } return 'no'; }"]],
     'expect_any' => ['return', 'if']],

    ['name' => 'refactor-naming', 'category' => 'refactor', 'max_tokens' => 300,
     'messages' => [['role' => 'user', 'content' => "Melhora os nomes neste código e explica em 1 frase:\n\$a = get(\$b); \$c = \$a->d;"]],
     'expect_any' => ['$']],

    // ── Debug ─────────────────────────────────────────────────────────
    ['name' => 'debug-php', 'category' => 'debug', 'max_tokens' => 300,
     'messages' => [['role' => 'user', 'content' => "Porque é que isto dá erro?\n\$arr = [1,2,3]; echo \$arr[3];"]],
     'expect_any' => ['índice', 'index', 'offset', 'existe', 'undefined', '3']],

    ['name' => 'debug-js-async', 'category' => 'debug', 'max_tokens' => 300,
     'messages' => [['role' => 'user', 'content' => "Porque imprime undefined?\nlet x; setTimeout(()=>{ x = 5; }, 100); console.log(x);"]],
     'expect_any' => ['settimeout', 'assínc', 'async', 'ainda', 'not yet', 'antes']],

    // ── Explicação ────────────────────────────────────────────────────
    ['name' => 'explain-jwt', 'category' => 'explain', 'max_tokens' => 250,
     'messages' => [['role' => 'user', 'content' => 'Explica JWT em 2 frases para um júnior.']],
     'expect_any' => ['token', 'assin']],

    ['name' => 'explain-fifo', 'category' => 'explain', 'max_tokens' => 200,
     'messages' => [['role' => 'user', 'content' => 'O que é FIFO? Resposta de 1 frase.']],
     'expect_any' => ['first', 'primeiro']],

    // ── Português ─────────────────────────────────────────────────────
    ['name' => 'pt-response', 'category' => 'pt', 'max_tokens' => 150,
     'messages' => [['role' => 'user', 'content' => 'Responde em português de Portugal: o que faz um foreach?']],
     'expect_any' => ['é']],

    // ── Tarefas simples (Low deve passar) ─────────────────────────────
    ['name' => 'simple-rename', 'category' => 'simple', 'max_tokens' => 150,
     'messages' => [['role' => 'user', 'content' => 'Renomeia a variável $data para $userData nesta linha: $data = fetchUser();']],
     'expect_any' => ['$userdata']],

    ['name' => 'simple-format', 'category' => 'simple', 'max_tokens' => 100,
     'messages' => [['role' => 'user', 'content' => 'Formata como lista numerada: maçã banana cereja']],
     'expect_any' => ['1', '2']],

    // ── Raciocínio médio (Medium deve passar) ─────────────────────────
    ['name' => 'logic-puzzle', 'category' => 'logic', 'max_tokens' => 300,
     'messages' => [['role' => 'user', 'content' => 'Tenho 3 caixas. Uma tem ouro. A: "não está aqui". B: "está na A". C: "não está aqui". Só uma diz a verdade. Onde está o ouro? Responde só a letra.']],
     'expect_any' => ['c', 'b']],

    // ── Instrução estrita ─────────────────────────────────────────────
    ['name' => 'json-strict', 'category' => 'instruction', 'max_tokens' => 150,
     'messages' => [['role' => 'user', 'content' => 'Responde APENAS com JSON válido: {"cor": "azul", "codigo": <hex>}']],
     'expect_any' => ['{', '"cor"'],
     'expect_absent' => ['```', 'aqui está', 'here is']],

    // ── Contexto longo (instrução no fim) ─────────────────────────────
    ['name' => 'long-context-key', 'category' => 'long_ctx', 'max_tokens' => 100,
     'messages' => [['role' => 'user', 'content' => str_repeat("Texto de enchimento sobre programação. ", 400) . "\n\nNo fim deste texto, responde apenas: ANANÁS"]],
     'expect_any' => ['ananás', 'ananas']],

    // ── Visão (só motores multimodais) ────────────────────────────────
    ['name' => 'vision-color', 'category' => 'vision', 'max_tokens' => 50, 'requires_vision' => true,
     'messages' => [[
         'role' => 'user',
         'content' => [
             ['type' => 'text', 'text' => 'What color is this image? One word.'],
             ['type' => 'image_url', 'image_url' => ['url' => 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==']],
         ],
     ]],
     'expect_any' => ['red', 'vermelh']],
];
