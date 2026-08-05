# MODEL CHANGELOG — Qolari Nexus Tiers

> Registo de **todas** as trocas de motor por trás dos tiers comerciais.
> Regra: nenhuma troca entra em produção sem (1) benchmark na suite de
> regressão (`php artisan qolari:benchmark`), (2) entrada neste ficheiro com
> o estado Feito/Pendente, (3) plano de rollback.
>
> **Cliente nunca é prejudicado:** se uma troca degrada métricas, rollback imediato.

## Estado atual dos tiers

| Tier | Motor (produção) | Motor (sandbox dev) | Desde |
|---|---|---|---|
| Nexus High | `moonshotai/kimi-k2.7-code` | `nvidia/nemotron-3-ultra-550b-a55b:free` | 2026-08-04 |
| Nexus Medium | `deepseek/deepseek-v4-pro` | `nvidia/nemotron-3-super-120b-a12b:free` | 2026-08-04 |
| Nexus Low | `qwen/qwen3-coder` | `nvidia/nemotron-nano-9b-v2:free` | 2026-08-04 |
| Nexus Vision (silencioso) | `google/gemini-2.0-flash-001` | `google/gemma-4-26b-a4b-it:free` | 2026-08-04 |

⚠️ IDs de produção por validar contra o catálogo OpenRouter (`SyncModelCosts`
confirma na 1ª execução com key válida — verifique se cada tier tem custos
sincronizados em `model_costs`).

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
