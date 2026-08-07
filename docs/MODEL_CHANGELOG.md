# MODEL CHANGELOG — Qolari Nexus Tiers

> Registo de **todas** as trocas de motor por trás dos tiers comerciais.
> Regra: nenhuma troca entra em produção sem (1) benchmark na suite de
> regressão (`php artisan qolari:benchmark`), (2) entrada neste ficheiro com
> o estado Feito/Pendente, (3) plano de rollback.
>
> **Cliente nunca é prejudicado:** se uma troca degrada métricas, rollback imediato.

## Estado atual dos tiers

> **⚠️ v4.3 (2026-08-06) — Pivô para providers diretos:** os motores de produção passam de OpenRouter para **DeepSeek direto** (ver entrada 2026-08-06 abaixo). A tabela seguinte reflete o estado **após o pivô** (seeder `AiModelsSeeder` atualizado).

| Tier | Motor (produção) | Provider | Desde |
|---|---|---|---|
| Nexus High | `deepseek-reasoner` | **deepseek** (direto) | 2026-08-06 |
| Nexus Medium | `deepseek-chat` | **deepseek** (direto) | 2026-08-06 |
| Nexus Low (dev/testes) | `meta/llama-3.1-8b-instruct` | **nvidia** (free tier) | 2026-08-06 |
| Nexus Vision (silencioso) | **DORMENTE** (`is_active=false`) até haver GLM direto | — | 2026-08-06 |
| Legacy `qolari` (Products) | `deepseek-chat` | **deepseek** (direto) | 2026-08-06 |

⚠️ Custos iniciais DeepSeek/NVIDIA semeados pelo seeder (só se não existirem); ajustes finos no admin em **Model Costs** (resource criado em 2026-08-06). OpenRouter fica como provider opcional por config (`supports_catalog=true`, único com sync de custos).

---

## Template de entrada

```markdown
## [AAAA-MM-DD] Nexus <Tier>: <MotorAntigo> → <MotorNovo>
**Motivo:** <deprecated / qualidade / custo / novo modelo melhor>
**Benchmarks (suite regressão):** <scores antigo vs novo por categoria>
**Shadow test:** <n pedidos comparados, veredito do juiz>
**Feito:**
- [x] Config atualizada (admin)
- [x] Suite de regressão correu
**Pendente:**
- [ ] <validações que ficam para a entrada em produção>
**Rollback:** <como voltar atrás e até quando é seguro>
```

---

## Entradas

## [2026-08-06] Pivô v4.3: OpenRouter → providers diretos (DeepSeek)
**Motivo:** decisão estratégica v4.3 (RESUMO.md) — compra direta às lojas oficiais (melhor margem, sem intermediário); OpenRouter fica opcional por config.
**Benchmarks (suite regressão):** pendente — correr `php artisan qolari:benchmark` contra DeepSeek quando houver key (o comando já resolve key/base_url por provider).
**Feito:**
- [x] Abstração de providers (`config/ai_providers.php` + `App\Domain\Proxy\AiProviderResolver`) — openrouter/deepseek/nvidia, key via Setting (admin) com fallback env
- [x] Proxy provider-aware (base_url/key/headers por motor); frame de erro SSE white-label generalizado a todos os providers
- [x] `SyncModelCosts` só toca providers com catálogo (OpenRouter); custos diretos são manuais (admin → Model Costs)
- [x] `ReconcileStreamUsage`: providers diretos saltam lookup `/generation` → estimativa direta
- [x] Seeder idempotente atualizado (motores + custos iniciais) + settings `deepseek_api_key`/`nvidia_api_key`
- [x] Suite de testes: **42/42** (7 novos de providers)
**Pendente:**
- [ ] Obter key DeepSeek oficial; correr benchmark de confirmação do DeepSeek (comparar com o baseline)
- [x] ~~Validar quota/key NVIDIA NIM~~ → **VALIDADO 06-08-2026:** key real testada na API + suite de regressão `nexus-low` (Llama 3.1 8B free) = **15/16 (94%)** — acima do baseline 12/16 do nemotron free (2026-08-05). Único FAIL: logic-puzzle.
- [ ] Definir margens finais por tier (atual: 3.00 uniforme)
- [ ] GLM direto para reativar Nexus Vision
**Rollback:** re-seedar com motores OpenRouter (o provider `openrouter` continua configurado e funcional — basta mudar `provider`/`provider_model_id` no admin, sem código nem deploy).

## [2026-08-04] Configuração inicial dos 4 tiers
**Motivo:** lançamento da arquitetura de tiers Nexus
**Benchmarks:** pendente — suite criada em 2026-08-05 (Fase 4.2)
**Feito:**
- [x] Tiers semeados (nexus-high/medium/low/vision)
- [x] Routing + vision silencioso implementados e testados (32 testes)
- [x] Sandbox com motores `:free` validada end-to-end (smoke test real)
- [x] Suite de regressão baseline (2026-08-05): **nexus-low (free) = 12/16 (75%)**
  - PASS: typescript, regex, refactors, debugs, fifo, simple, logic, json-strict, long-ctx
  - FAIL (conhecidos do motor free): php-function, sql-query, pt-response (CoT leak no content), explain-jwt
  - Serve de baseline comparativo para futuros motores — NÃO é sinal de produto
**Pendente:**
- [ ] Validar IDs de produção contra catálogo OpenRouter
- [ ] Correr suite de regressão baseline (motores free em dev)
- [ ] Definir margens finais por tier (atual: 3.00 uniforme)
**Rollback:** n/a (configuração inicial)
