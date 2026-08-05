# QOLARI — Roadmap de Incorporação (Tiers Nexus + Blindagem + Continuidade)

> **Versão:** 1.1 · **Data:** 2026-08-04
> **Origem:** Sessão de análise estratégica + auditoria técnica ao backend Laravel, frontend Next.js e fork do IDE OpenCode.
> **Estado:** Fase 0 em execução — 0.1 a 0.4 CONCLUÍDOS.

## ⏩ PROGRESSO (atualizado 2026-08-04)

| Item | Estado | Notas |
|---|---|---|
| **0.1** Metering streaming | ✅ FEITO | `UsageMeter` centralizado; stream captura `usage` via `stream_options.include_usage`; fallback job `ReconcileStreamUsage` (endpoint `/generation`, 5 retries) → estimativa final (status `estimated`); migração `2026_08_04_000000_update_usage_logs_for_stream_reconciliation` (status `pending`/`estimated` + `generation_id`); 4 testes novos (`StreamMeteringTest`). **Bug bónus corrigido:** `Setting::set()` não encriptava secrets novos (ordem dos atributos) — quebraria `openrouter_api_key` em produção. |
| **0.2** Lockdown A+B | ✅ FEITO | `provider.ts`: whitelist qolari-only no registry + config-extend ignora `qolari` (anti-exfiltração) + `defaultModel` ignora modelos externos. |
| **0.3** Lockdown C | ✅ FEITO | `server.ts`: allowlist estrita de env para o sidecar; `QOLARI_PROXY_URL` pinned; credential store ganha sempre à shell. |
| **0.4** Lockdown D+E+F+G | ✅ FEITO | Catálogo models.dev desativado; `Auth.all()` filtra não-qolari e ignora `OPENCODE_AUTH_CONTENT`; plugins externos desativados (`pure: true` hardcoded); `OPENCODE_CONFIG`/`OPENCODE_CONFIG_CONTENT` ignorados; GUI Connect Provider sem form custom. **Verificado em runtime:** `test/provider/qolari-lockdown.test.ts` (4 testes, todos passam). Typecheck OK em opencode/core/desktop/app. ~106 testes upstream falham **por design** (documentado em `ide/AGENTS.md`). |
| **0.5** Estratégia de fork | ✅ FEITO | 3 commits no backend (`c5037a2`, `332b7ee`, `d7b4ed0`) + 3 no IDE (`0f17b69` rebrand/auth-gate, `1de9738` lockdown, `764052c` docs) sobre upstream `ceb4890`. Sync mensal com rebase documentado em `ide/AGENTS.md`. |
| **0.6** Validação hands-on desktop | ⏸️ PENDENTE | Requer sessão interativa com o build. |

### Fase 1 — Tiers Nexus (2026-08-04)

| Item | Estado | Notas |
|---|---|---|
| **1.1** 4 tiers na BD | ✅ FEITO | Seeder idempotente: `nexus-high` (Kimi K2.7 Code), `nexus-medium` (DeepSeek V4 Pro), `nexus-low` (Qwen3 Coder), `nexus-vision` (Gemini 2.0 Flash) + aliases legacy. ⚠️ IDs dos motores a validar contra o catálogo OpenRouter quando houver API key (sem key em dev). |
| **1.2** Tier→modelo editável no admin | ✅ FEITO | Filament AiModelForm: `provider_model_id`, `supports_vision`, `context_limit`, margem — troca de motor sem deploy. |
| **1.3** Routing por tier | ✅ FEITO | `App\Domain\Routing\TierResolver` — `AiModel::active()->first()` eliminado do proxy. |
| **1.4** Vision silencioso | ✅ FEITO | Pedido com imagem/ficheiro em tier sem visão → motor `nexus-vision`; **cobrança à margem do tier escolhido, custo real do Vision**; auditável via `usage_logs.engine_model_id`. Teste prova a jogada de margem ($0.30 cobrado vs $3.00 se fosse o Medium real). |
| **1.5** Validação multimodal | ✅ FEITO | `content` string **ou** array de parts; campos agênticos (tools, tool_choice...) preservados no passthrough. |
| **1.6** Picker de tiers no IDE | ✅ FEITO | `provider.ts`: 3 tiers Nexus visíveis (Vision invisível); todos aceitam anexos client-side para o routing silencioso ser transparente. |
| **1.7** Modalidade dinâmica | ✅ FEITO | `SyncModelCosts` sincroniza `supports_vision` + `context_limit` do catálogo OpenRouter. |
| ⚠️ Pendente | — | **Products** ainda referenciam o modelo legacy `qolari` — decidir estrutura de pacotes por tier (Fase 2 ou antes do lançamento). |

### Fase 2 — Recomendador de tiers (2026-08-04)

| Item | Estado | Notas |
|---|---|---|
| **2.0** White-label leak | ✅ FEITO | **Crítico:** o ID real do motor fugia nas respostas — `model` sanitizado (sync + chunks SSE) para o tier slug. Prova e2e em teste. |
| **2.1** TierRecommender rule-based | ✅ FEITO | `App\Domain\Routing\TierRecommender`: contexto grande→High, frases complexas→High, tarefa simples→Low. Visão→nunca sugere. |
| **2.2/2.3** Gatilhos up/down | ✅ FEITO | Header `X-Nexus-Suggestion` nos 2 endpoints + endpoint de preview `POST /v1/recommendations/suggest`. |
| **2.4** Regras de comportamento | ✅ FEITO | `SuggestionGate`: máx. 1 sugestão/5 pedidos; 2 recusas silenciam o tier 7 dias (`POST /v1/recommendations/dismiss`). |
| **2.5** UI no IDE | ✅ FEITO | `nexus-suggestion.tsx`: banner acima do composer, debounce 600ms, 1-click troca tier, dismiss com aviso ao backend. Desktop-only (bridge Electron). |
| **2.6** Nexus Auto | ✅ FEITO | `users.nexus_auto` (PUT `/v1/profile`); resolver escolhe o tier em silêncio e cobra ao tier usado. |
| ⏳ Adiado | — | S5 (falhanço repetido) precisa de telemetria da sessão → Fase 4.5. Teste hands-on do banner no build desktop. |

### Fase 3 — Continuidade de contexto (2026-08-04)

**Gate 3.1 — VEREDITO: compactação nativa é SUFICIENTE para v1** ✅ (análise do runtime: histórico persiste na troca; compactação re-corre para a janela do tier NOVO antes do 1º pedido — `prompt.ts:1161`, `overflow.ts:10-34`; template de resumo já estruturado: Objective/Completed/Active/Blocked/Next Move/Files).

| Item | Estado | Notas |
|---|---|---|
| **3.1** Validar compactação nativa | ✅ FEITO | Veredito acima; v2 passa de blocker a enhancement (alvo: `SystemContextRegistry` V2) |
| **3.5** Pre-flight handoff | ✅ FEITO | Agente de compactação pinado a `nexus-high` (`agent.ts`) — o resumo de handoff é SEMPRE escrito pelo modelo forte |
| **3.2/3.4** Briefing + persistência | ✅ FEITO | Tabelas `conversations`/`briefings`, `BriefingService` (lock otimista), GET/PUT `/v1/conversations/{id}/briefing`. 4 testes. |
| **3.6** Injeção no IDE | ✅ FEITO (v1) | Plugin interno `QolariBriefingPlugin` via hook `experimental.chat.system.transform` (cache 30s, fail silencioso). Migração futura: Context Source V2. |
| **3.3** Captura automática | ⏳ PRÓXIMA ITERAÇÃO | PUT do resumo de compactação para o backend (eventos `message.updated` com `summary=true`) — anotado no código. |

### Fase 4 — Governança de modelos (2026-08-05)

| Item | Estado | Notas |
|---|---|---|
| **7.1** MODEL_CHANGELOG | ✅ FEITO | `docs/MODEL_CHANGELOG.md` com template (motivo/benchmarks/feito/pendente/rollback) + entrada inicial com baseline |
| **7.2** Suite de regressão | ✅ FEITO | `benchmark/tier-suite.php` (17 prompts, 9 categorias, expetativas keyword) + `php artisan qolari:benchmark {tier?}` (direto ao OpenRouter, sem billing). Baseline Low: 12/16 |
| **7.5** Telemetria | ✅ FEITO (backend) | Tabela `quality_signals` + `POST /v1/telemetry` (batch: accept/retry/abort/edit_after/regenerate). Falta: instrumentação no IDE → Fase 5 |
| **7.3/7.4** Shadow + canary | ⏳ FASE 5 | Requer tráfego de produção; scaffolding quando houver clientes reais |
| ⚠️ Issue IDE | 📋 REGISTADO | Crash `<Show>` stale ao selecionar projeto (dialog-select-directory) — investigar na Fase 5 |

---

## 1. Contexto e decisões estratégicas tomadas

Este roadmap consolida todas as decisões debatidas:

1. **Modelo de negócio:** revenda de acesso a modelos de IA via OpenRouter com margem (~3x), vendida como **créditos** (nunca "preço do modelo") dentro de um ecossistema fechado (IDE próprio + backend + frontend).
2. **Tiers white-label:** o cliente nunca vê nomes reais de modelos. Tiers comerciais: **Nexus High**, **Nexus Medium**, **Nexus Low** e **Nexus Vision** (invisível).
3. **Nexus Vision é silencioso:** entra automaticamente quando o cliente insere imagem/ficheiro e o tier atual não é multimodal. **Cobra-se à tarifa do tier escolhido pelo cliente** — o custo real mais baixo do Vision aumenta a margem.
4. **Troca de tiers a meio da conversa tem de ser 100% transparente:** o modelo novo sabe o que foi feito e o que falta (Session Briefing / context handoff).
5. **Recomendador de tiers:** sugere (nunca impõe) o tier ideal por tarefa — tanto upgrade (qualidade) como downgrade (poupança, gera confiança). Modo **Nexus Auto** opcional = routing 100% silencioso.
6. **Governança de modelos:** trocas de motor por trás dos tiers seguem MODEL_CHANGELOG + suite de regressão + shadow testing + canary rollout. O cliente nunca é prejudicado.
7. **Blindagem:** todo o tráfego LLM do IDE passa obrigatoriamente pelo backend Qolari. Todas as vias de bypass conhecidas serão fechadas.

---

## 2. Estado atual (findings da análise)

### Backend Laravel (raiz do repo) — ~85% pronto
- Proxy OpenRouter funcional: `app/Domain/Proxy/OpenRouterProxyService.php` (SSE streaming + completions).
- Billing completo: wallets por modelo, lotes FIFO (12 meses), ledger append-only com idempotência, Stripe com webhooks verificados (`app/Domain/Wallet/WalletService.php`, `app/Domain/Billing/StripeService.php`).
- Tabela `ai_models` já tem `margin_multiplier` por modelo; seeder já reserva tiers (`qolari` ativo, `max`/`medium` inativos).
- Admin Filament com CRUD de AiModels, Products, Orders, Settings, etc.
- Sync diário de custos OpenRouter (`app/Jobs/SyncModelCosts.php`).

### Frontend Next.js (`frontend/`) — pronto
- Pricing → checkout Stripe → dashboard (wallets, usage, orders, tokens). i18n pt/en.

### IDE (`ide/`) — fork do OpenCode (anomalyco/opencode, branch `dev`) — ~70% pronto
- Electron + SolidJS + Bun/Effect-TS. Núcleo agêntico production-grade (sessões, tools, MCP, compactação de contexto nativa).
- Já customizado (NÃO commitado ⚠️): provider `qolari` injetado em `packages/opencode/src/provider/provider.ts` (~l.1361), rebrand desktop, login gate com saldo de créditos (`packages/desktop/src/renderer/qolari-login.tsx`), i18n pt iniciado.

### Problemas críticos encontrados
| # | Problema | Impacto |
|---|---|---|
| P1 | `meterPostStream` é stub → **streaming debita $0** | Vende de graça no fluxo principal |
| P2 | Validação do proxy exige `messages.*.content` string | Bloqueia multimodal/Vision |
| P3 | Routing single-model (`AiModel::active()->first()`) | Bloqueia tiers |
| P4 | IDE completamente aberto a bypass de providers (8 vetores) | Margem contornável |
| P5 | Customizações do IDE não commitadas | Risco de perda/conflito com upstream |
| P6 | Zero persistência de conversas no backend | Bloqueia briefing v2 |

---

## 3. FASE 0 — Fundação e proteção do negócio 🔴

**Objetivo:** parar de vender de graça, fechar bypasses, proteger o trabalho feito.
**Estimativa:** 1-2 semanas · **Bloqueia:** todo o lançamento.

### 0.1 Corrigir metering do streaming
- **Ficheiros:** `app/Domain/Proxy/OpenRouterProxyService.php` (`stream()`, `meterPostStream()`).
- **Tarefas:**
  - Implementar reconciliação pós-stream via endpoint `GET /api/v1/generation?id={generation_id}` do OpenRouter (obter tokens reais após o stream terminar).
  - Pedir `usage` no payload do stream (`stream_options: {include_usage: true}`) como primeira fonte; `/generation` como fallback (job com retry, ex: 3 tentativas com backoff).
  - Débito assíncrono via queue (Horizon) com o mesmo `request_id` idempotency key já existente.
  - Atualizar `UsageLog` com tokens reais; política para falha de reconciliação (ex: estimativa conservadora + flag `estimated`).
- **Critério de aceitação:** 100% dos streams debitam valor > 0 (ou flag estimada); nenhum débito duplicado sob retries.

### 0.2 Lockdown A+B — registry + proteção do provider qolari
- **Ficheiros:** `ide/packages/opencode/src/provider/provider.ts` (state builder ~l.1701; config-extend loops ~l.1516 e ~l.1679).
- **Tarefas:**
  - Após todo o loading de providers: `for (const id of Object.keys(providers)) if (id !== "qolari") delete providers[id]`.
  - Excluir `qolari` dos loops de config-extend (ou sanitizar `cfg.provider.qolari.options` para uma allowlist vazia).
  - Forçar `baseURL`/`apiKey` do qolari a partir de constantes do build, não de config/env editável.
  - Remover overrides de `fetch`/`headers`/`npm`/`api.url` para modelos qolari.
- **Critério de aceitação:** com `opencode.json` malicioso + `auth.json` com outras keys + env vars de providers, `Provider.list()` devolve apenas `qolari`; `getModel` de qualquer outro provider falha.

### 0.3 Lockdown C — scrub do ambiente do sidecar
- **Ficheiros:** `ide/packages/desktop/src/main/server.ts` (`createSidecarEnv()` ~l.223-229; `preferAppEnv()` ~l.44-61).
- **Tarefas:**
  - Substituir pass-through do shell env por allowlist: `PATH`, `HOME`/`USERPROFILE`, `QOLARI_API_KEY`, locale vars.
  - Filtrar/remover o `Object.assign(process.env, shellEnv)` ou aplicar a mesma allowlist.
  - Defesa em profundidade: no serviço `Env` (`packages/opencode/src/env/index.ts`), remover vars de providers do catálogo.
- **Critério de aceitação:** `OPENAI_API_KEY`/`OPENROUTER_API_KEY` no shell do utilizador não ativa nada.

### 0.4 Lockdown D+E+F+G — superfícies secundárias
- **D. Catálogo:** `ide/packages/core/src/models-dev.ts` — devolver apenas o registo qolari (ou `{}`); build sem cache de modelos.
- **E. Auth store + UX:** `ide/packages/opencode/src/auth/index.ts` — `Auth.all()` ignora entradas não-qolari e `OPENCODE_AUTH_CONTENT`; remover/guardar `cli/cmd/providers.ts`; remover `dialog-connect-provider.tsx` / `dialog-custom-provider.tsx` da app.
- **F. Plugins:** `ide/packages/opencode/src/config/config.ts` (l.424-465) + `config/plugin.ts` — não carregar plugins de utilizador no fork (ou allowlist assinada).
- **G. Hardening:** hardcodar `QOLARI_PROXY_URL` no build (remover env override em `provider.ts` l.1362); ignorar `OPENCODE_CONFIG`, `OPENCODE_CONFIG_CONTENT`, `OPENCODE_CONFIG_DIR`, `OPENCODE_MODELS_URL/PATH`; `Flag.OPENCODE_DISABLE_PROJECT_CONFIG`; `defaultModel()`/`small_model` a apontar para modelo qolari.
- **Critério de aceitação:** GUI não mostra "Connect Provider"; config de providers em qualquer localização conhecida é ignorada; `OPENCODE_CONFIG_CONTENT` com provider custom não tem efeito.

### 0.5 Estratégia de fork
- **Tarefas:**
  - Commit de todas as customizações atuais em branch `qolari/main` (ou similar).
  - Convenção: upstream `dev` → rebase periódico (ex: mensal) para `qolari/main`; cada customização em commits isolados e bem descritos para facilitar rebase.
  - Documentar em `ide/AGENTS.md` o processo de sync com upstream.
- **Critério de aceitação:** working tree limpa; `git log` mostra customizações Qolari separadas do upstream.

### 0.6 Validação hands-on do desktop
- **Tarefas:** build do desktop; testar edição de ficheiros, file explorer, diffs, execução do agente com tools, troca de modelo a meio da sessão, comportamento com saldo zero.
- **Output:** decisão documentada — o desktop serve como "IDE" ou posiciona-se como "agente com editor".

---

## 4. FASE 1 — Tiers Nexus 🟡

**Objetivo:** arquitetura comercial de tiers operacional end-to-end.
**Estimativa:** 2-3 semanas · **Depende de:** 0.1 (cobrança correta).

### 1.1 Semear os 4 tiers
- **Ficheiros:** `database/seeders/AiModelsSeeder.php`, admin Filament.
- **Tarefas:**
  - Registos: `nexus-high`, `nexus-medium`, `nexus-low`, `nexus-vision` com `provider_model_id`, `margin_multiplier` individual e `sort_order`.
  - Escolha inicial dos motores (a definir com benchmarks — ver Fase 4.2):
    - High: modelo frontier de código (multimodal)
    - Medium: modelo equilibrado custo/qualidade
    - Low: modelo mais barato competente
    - Vision: modelo multimodal super barato
- **Nota:** nomes reais dos motores NUNCA aparecem na API/UI pública — só `display_name` ("Nexus High" etc.).

### 1.2 Config tier→modelo editável no admin
- **Tarefas:** recurso Filament de AiModels revisto para editar `provider_model_id` + `margin_multiplier` + custos sem deploy; cache invalidado na escrita.
- **Critério de aceitação:** trocar o motor de um tier = edição no admin, sem deploy nem restart.

### 1.3 Routing por tier no proxy
- **Ficheiros:** `app/Domain/Proxy/OpenRouterProxyService.php`, `app/Http/Controllers/Api/ProxyController.php`.
- **Tarefas:**
  - Aceitar parâmetro `tier` (ou `model: "nexus-*"`) no request; resolver para `AiModel` respetivo.
  - Substituir `AiModel::active()->first()` por resolução consciente (tier pedido → validar ativo → fallback definido).
  - Wallets: débito na wallet do tier (já existe por modelo); decidir política de saldo insuficiente noutro tier (bloquear vs. converter — tabela `conversions` já existe).
- **Critério de aceitação:** pedidos com tiers diferentes usam motores diferentes e debitam wallets corretas.

### 1.4 Nexus Vision silencioso (jogada de margem)
- **Ficheiros:** `OpenRouterProxyService.php` (nova camada de decisão, ex: `App\Domain\Routing\TierResolver`).
- **Tarefas:**
  - Detetar imagem/anexo no payload (content parts `image_url`/ficheiro).
  - Se tier escolhido não for multimodal → resolver internamente para `nexus-vision`.
  - **Cobrança:** `charged_usd` calculado com o `margin_multiplier` do **tier escolhido pelo cliente**; `cost_usd` = custo real do Vision. Registar ambos + flag `routed_to` no `UsageLog` (transparência interna, invisível ao cliente).
  - Se tier for multimodal (ex: High) → manter o tier.
- **Critério de aceitação:** cliente no Medium + imagem recebe resposta com visão, é cobrado à tarifa Medium, `UsageLog` mostra routing silencioso.

### 1.5 Validação multimodal (pré-requisito do 1.4)
- **Ficheiros:** `ProxyController.php` (validação), testes.
- **Tarefas:** aceitar `messages.*.content` como string **ou** array de content parts (text/image); validar tamanho/formato; limites de payload.
- **Critério de aceitação:** requests multimodais passam validação e chegam intactos ao OpenRouter.

### 1.6 Picker de tiers no IDE
- **Ficheiros:** `ide/packages/app/src/components/dialog-select-model.tsx`, `model-tooltip.tsx`, `context/local.tsx`; modelos no provider qolari em `provider.ts`.
- **Tarefas:**
  - Substituir os 3 modelos hardcoded atuais pelos 4 tiers (ou 3 visíveis — Vision nunca aparece).
  - Labels comerciais + descrição + custo em créditos por tier (via API `/v1/products` ou novo endpoint `/v1/tiers`).
  - Badge/indicador do tier ativo no composer.
- **Critério de aceitação:** cliente vê apenas "Nexus High/Medium/Low" com preços em créditos; troca persiste por sessão.

### 1.7 Filtragem dinâmica por modalidade
- **Tarefas:** no sync de custos (`SyncModelCosts.php`), guardar também `modality` e limites de contexto do `/api/v1/models`; `TierResolver` usa esses metadados (não lógica hardcoded) para decidir multimodalidade e cabimento de contexto.
- **Critério de aceitação:** trocar o motor de um tier no admin atualiza automaticamente as capacidades consideradas no routing.

---

## 5. FASE 2 — Recomendador de tiers 🟡

**Objetivo:** inteligência comercial — sugerir o tier certo por tarefa.
**Estimativa:** 2 semanas · **Depende de:** 1.3.

### 2.1 TierRecommender rule-based (v1)
- **Ficheiros:** novo `app/Domain/Routing/TierRecommender.php`.
- **Sinais de entrada:**
  - S1 tipo de pedido (regras/keywords)
  - S2 tamanho do contexto (tokens estimados do pedido)
  - S3 presença de imagem/ficheiro
  - S4 dependências do briefing/histórico (nº de decisões referenciadas)
  - S5 falhanços repetidos na sessão
- **Matriz de decisão v1:**
  | Pedido | Sugestão |
  |---|---|
  | typo / renomear / explicar erro simples | Low |
  | implementar endpoint / testes / validação | Medium |
  | refatorar arquitetura / debug produção / desenhar sistema | High |
  | qualquer + imagem | tier sugerido (+ Vision silencioso se aplicável) |
  | contexto > 60% da janela do Medium | High |
- **Output:** sugestão devolvida ao IDE (header ou campo na resposta/metadata), nunca troca forçada.

### 2.2 Gatilhos de upgrade
- Falhanço 2x na mesma tarefa → "O High resolve isto melhor — trocar por X créditos?"
- Pedido referencia 5+ ficheiros/decisões → sugerir High antes de executar.
- Frases-gatilho: "arquitetura", "migrar", "otimizar tudo", "desenha do zero", "porque não funciona".

### 2.3 Gatilhos de downgrade (poupança = confiança)
- Tarefa simples em tier alto → "O Low faz isto perfeitamente e custa 5x menos — trocar?"

### 2.4 Regras de comportamento
- Máx. 1 sugestão por N pedidos (N configurável em Settings).
- "Lembrar escolha por sessão": recusou 2x → parar de sugerir.
- Custo em créditos sempre visível na sugestão.

### 2.5 UI de sugestão no composer do IDE
- **Ficheiros:** `ide/packages/app/src/pages/session/composer/*`.
- **Tarefas:** chip/banner de sugestão com ação 1-click ("Trocar para Medium · ~X créditos") + dismiss + "não voltar a sugerir nesta sessão".

### 2.6 Nexus Auto (routing silencioso)
- Toggle por utilizador (perfil): o sistema escolhe o tier por pedido sem perguntar.
- Cobrança sempre à tarifa do tier efetivamente usado; indicação discreta do tier usado em cada resposta.
- **Critério de aceitação:** com Nexus Auto ON, o cliente nunca vê o picker e cada pedido usa o tier ótimo da matriz.

---

## 6. FASE 3 — Continuidade de contexto (Briefing) 🟢

**Objetivo:** troca High↔Medium↔Low 100% transparente; o modelo novo sabe o que foi feito e o que falta.
**Estimativa:** 1 semana (v1) + 3-4 semanas (v2) · **Depende de:** 1.3.

### 3.1 v1 — Validar compactação nativa do OpenCode
- **Racional:** o IDE mantém a sessão e envia o histórico completo a cada pedido; a compactação nativa (Context Epochs) resume sessões longas. A troca de tiers já herda isto de graça.
- **Tarefas:** testes de handoff: sessão longa no High → trocar para Low → verificar continuidade; medir qualidade com os prompts da suite (4.2).
- **Decisão:** se suficiente → v2 desce de prioridade; se insuficiente → v2 conforme abaixo.

### 3.2 v2 — Session Briefing próprio (documento de estado vivo)
- **Formato (~600-800 tokens máx.):**
  ```markdown
  ## Estado do Projeto
  **Objetivo atual:** ...
  **Concluído:** 1. ... 2. ...
  **Decisões e constraints:** ... (ex: "cliente recusou biblioteca X", "preços em cêntimos")
  **Ficheiros tocados:** path (criado/modificado — o quê)
  **Pendente (ordenado):** 1. ... 2. ...
  **Última ação:** ...
  ```
- **ENTRA:** decisões do cliente, constraints técnicas, ficheiros+o que mudou, pendente ordenado, assinaturas de funções críticas.
- **SAI:** conversa social, erros já corrigidos, código reescrito depois, explicações longas, tentativas falhadas.

### 3.3 Atualização incremental
- Trigger: ação concluída (código escrito, ficheiro modificado, decisão explícita) — NÃO por mensagem.
- O modelo que agiu recebe briefing atual + sua última ação → devolve briefing atualizado (poucos tokens).

### 3.4 Persistência no backend
- **Novas tabelas:** `conversations` (user_id, tier atual, timestamps), `briefings` (conversation_id, content, version, updated_at), opcional `messages` (se quisermos histórico server-side).
- **Novo serviço:** `app/Domain/Briefing/BriefingService.php` (seguir padrão thin controllers + Domain services).
- **Endpoints:** `GET/PUT /v1/conversations/{id}/briefing`.

### 3.5 Pre-flight handoff
- Na troca de tier: o modelo do tier anterior finaliza/atualiza o briefing ("carta de passagem de turno") antes de o novo tier receber o pedido.
- Briefing injetado como mensagem de sistema + últimas N mensagens relevantes (histórico cru só enquanto couber na janela do tier).

### 3.6 Injeção no IDE via Context Source
- **Ficheiros:** seam nativa "System Context Registry / Context Sources" (`ide/CONTEXT.md`, `ide/packages/opencode/src/session/`).
- **Tarefas:** registar o briefing como Context Source (ou hook `experimental.chat.system.transform`); painel opcional na sessão para o cliente ver/editar o briefing.

---

## 7. FASE 4 — Qualidade e governança de modelos 🟢

**Objetivo:** nenhuma troca de motor (por trás de um tier) prejudica o cliente — nunca.
**Estimativa:** processo contínuo (setup: 1-2 semanas).

### 7.1 MODEL_CHANGELOG
- **Ficheiro:** `docs/MODEL_CHANGELOG.md` (ou tabela BD + página admin).
- **Template por entrada:**
  ```markdown
  ## [data] Nexus Medium: Modelo-X → Modelo-Y
  **Motivo:** ...
  **Benchmarks internos:** código ✅ | refatoração ⚠️ -8%
  **Feito:** [x] config [x] regressão
  **Pendente:** [ ] revalidar tool calling [ ] ajustar system prompt [ ] recalcular créditos
  **Rollback:** possível até <data> (como)
  ```

### 7.2 Suite de regressão (~20 prompts por tier)
- Cobrir: geração de código, refatoração, debugging, explicação, tool calling, multimodal (para tiers com visão), contexto longo, português/inglês.
- Guardada junto do changelog; corre em CI/manual antes de qualquer troca de motor.

### 7.3 Shadow testing
- Modelo candidato corre em paralelo (escondido) numa amostra de pedidos reais; respostas comparadas (juiz = modelo forte; custo de cêntimos por comparação).
- Só avança se empatar/ganhar ao modelo atual.

### 7.4 Canary rollout
- 5% → 25% → 100% do tráfego do tier; métricas monitorizadas; **rollback automático** se qualidade cair (threshold configurável).

### 7.5 Telemetria de qualidade do IDE
- **Sinais:** taxa de aceitação de código sugerido, pedidos refeitos ("tenta outra vez"), edições imediatas pós-resposta, abortos a meio da geração.
- **Implementação:** eventos do IDE → novo endpoint `/v1/telemetry` → tabela `quality_signals`; dashboard admin (Filament) por tier/modelo.
- Alimenta 7.3/7.4 e o changelog.

---

## 8. FASE 5 — Hardening final e polimento 🔵

**Estimativa:** 1 semana.

| # | Item | Notas |
|---|---|---|
| 5.1 | Code-signing do desktop + certificate pinning no fetch qolari | Residual do bypass (cliente avançado/MITM) |
| 5.2 | Onboarding no IDE (primeira sessão: o que são tiers, créditos, Nexus Auto) | Retenção |
| 5.3 | i18n PT completo no IDE | Continuar `pt.ts` |
| 5.4 | Fluxos de paywall no IDE (saldo insuficiente → compra sem sair do IDE) | UX comercial |
| 5.5 | Recursos Filament para Wallets/Ledger/Usage | Visibilidade operacional |

---

## 9. Grafo de dependências

```
0.1 streaming $0 ──────────► todas as fases que cobram por uso
0.2-0.4 lockdown ──────────► lançamento a qualquer cliente
0.5 fork ──────────────────► todo o trabalho futuro no IDE
1.5 multimodal ────────────► 1.4 Vision silencioso
1.3 routing por tier ──────► Fase 2 (recomendador) ──► Fase 3 (briefing)
1.1-1.2 tiers na BD ───────► 1.3, 1.4, 1.6
3.1 compactação nativa ────► decisão go/no-go de 3.2-3.6
7.5 telemetria ────────────► 7.3 shadow / 7.4 canary
7.2 suite regressão ───────► 1.1 (escolha dos motores iniciais)
```

## 10. Estimativas e sequência

| Fase | Esforço | Natureza | Quando |
|---|---|---|---|
| 0 — Fundação/blindagem | 1-2 semanas | Urgente, cirúrgico | Imediato |
| 1 — Tiers Nexus | 2-3 semanas | Core comercial | Logo após 0 |
| 2 — Recomendador | 2 semanas | Diferenciador | Após 1.3 |
| 3 — Briefing | 1 sem (v1) + 3-4 sem (v2) | Experiência premium | v1 com Fase 1; v2 após 2 |
| 4 — Governança | contínuo (setup 1-2 sem) | Processo | Antes da 1ª troca de motor |
| 5 — Polimento | 1 semana | Retenção/segurança | Pré-lançamento público |

**Sequência resumida:** tapar os buracos que custam dinheiro (0) → produto comercial (1-2) → experiência premium (3) → governança permanente (4) → polimento pré-lançamento (5).

---

## 11. Riscos e notas

| Risco | Mitigação |
|---|---|
| Cliente avançado patcha o binário/JS do IDE | Code-signing + pinning (5.1); aceitar risco residual — objetivo é elevar o custo do bypass, não torná-lo impossível |
| Modelos deprecados no OpenRouter | Tier→modelo em config (1.2) + changelog (7.1) + sync diário de catálogo |
| Recomendador chato | Regras 2.4 (rate limit de sugestões, lembrar recusa) |
| Vision canibalizar Medium (é barato e razoável em texto) | Vision nunca é vendido/visível; só entra com imagem (1.4) |
| Sync com upstream do OpenCode | Estratégia de fork (0.5) + rebase mensal |
| Clientes deduzirem os modelos reais pelo output | Posicionar como "curadoria otimizada"; nunca afirmar "modelos proprietários" no marketing |
| Compactação nativa insuficiente para handoff | Gate 3.1 antes de investir no briefing v2 |

---

*Documento gerado a partir da sessão de planeamento de 2026-08-04. Atualizar à medida que as fases avançam.*
