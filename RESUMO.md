# Qolari — Resumo Executivo (v3 — rebranding a 28-07-2026)

> Antes "Nexus AI". Marca registada: **Qolari** — domínio `qolari.com` (comprado, na Hetzner), email profissional `qolari@qolari.com`.

## O que é?
**Qolari** é uma plataforma SaaS que cria um ecossistema fechado de programação com IA. O cliente entra, programa, paga e lança negócios — tudo dentro da mesma plataforma, sem nunca sair.

---

## Os 2 Pilares do Negócio

### 🔷 Pilar 1 — Qolari IDE (Motor Central)
- **IDE Desktop nativo**, NÃO é web app nem PWA:
  - **Decisão (27-07-2026): fork do OpenCode desktop app** ([anomalyco/opencode](https://github.com/anomalyco/opencode), licença MIT, Tauri + TypeScript). Alterações mínimas (estratégia de diff mínimo para absorver o upstream): rebrand "Qolari IDE", provider bloqueado ao proxy Qolari por config, ecrã de login, widget de saldo.
  - **Void eliminado** (projeto deprecado/arquivado em 2025). Backup: AiderDesk.
  - **Plataformas no lançamento:** Windows + Linux. Mac fica para depois (exige Apple Developer $99/ano para assinatura).
  - **Updates:** download manual do instalador no lançamento; auto-update na Fase 4.
- **UM só modelo de IA white-label no lançamento** (decisão v2): um saldo, uma margem, uma mensagem de marketing ("a IA da Qolari"). O cliente vê apenas **"Qolari"** — por trás está o **Kimi K2.7 Code** (Moonshot, via OpenRouter — multimodal, especialista em coding agentic), escolhido a 27-07-2026 e confirmado por **benchmark interno na Fase 1**; é **config no admin** — a arquitetura suporta N modelos (DeepSeek V4 Pro/Flash como futuro tier económico, Moonshot oficial, OpenAI, Anthropic) que se adicionam depois sem código.
- **Sistema de pagamento: SÓ PACOTES PRÉ-PAGOS** — não há cobrança automática por request. O cliente compra um pacote e gasta até esgotar.

**Como funciona o billing (v2):**
> A Qolari compra tokens via **OpenRouter** (acesso a alojadores de modelos open source com preços mais baratos). A **margem é 200% de markup sobre o custo em USD** (preço = 3× custo), configurável por modelo no admin. Exemplo: o cliente paga €10 → credita $11.37 no saldo (à taxa de câmbio do admin) → cada request debita `custo_real_USD × 3` → o custo real para a Qolari é $3.79 e o lucro $7.58. **Os saldos são denominados em USD** porque o custo é em USD; o cliente vê os valores na sua moeda. A arquitetura tem **abstração de provider** — outro provider entra por config no admin, sem código.
>
> **Nota (alavanca de margem futura):** o proxy nasce com routing por request. Se o benchmark da Fase 1 confirmar a qualidade agentic do DeepSeek V4 Pro, pode ativar-se por config um **modo híbrido** (DeepSeek para texto + modelo de visão barato para imagens, ou visão-como-ferramenta) que sobe a margem efetiva de 3× para ~5–6× sem o cliente notar.

---

### 🔷 Pilar 2 — REMOVIDO (decisão v2, 27-07-2026)
A venda de repositórios open source como produto foi eliminada (risco legal de licenças/marcas, entrega manual que não escala). **Os repositórios não morrem — mudam de função:** passam a ser o **ativo interno do Pilar 3** (Partners). É com eles que o fundador entrega "o negócio numa caixa" a cada parceiro.

---

### 🔷 Pilar 3 — Qolari Partners (Vetor Central de Crescimento)
**Elevado a trunfo estratégico (decisão v2).** O fundador aproxima-se ativamente de empreendedores que querem o próprio negócio e entra como **sócio + suporte tecnológico**: entrega o produto adaptado (a partir dos repositórios internos), mantém-no atualizado, e a Qolari recebe a percentagem acordada.

- **Split de receitas:** a definir na constituição (pré-requisito bloqueante — sem isto não há parcerias).
- **Verificação de receita:** os projetos dos parceiros correm **na infraestrutura da Qolari** — a faturação é visível na plataforma e o revenue share não depende de confiança.
- **100% manual até 3+ parceiros ativos:** contratos + folha de cálculo, zero código próprio. O controlo vem da plataforma (Pilar 1), não de software novo.
- O parceiro usa o IDE com os seus próprios créditos — cada parceiro é também um cliente do Pilar 1.

---

## Stack Técnica

| Camada | Tecnologia |
|--------|-----------|
| **Backend API** | Laravel 11+ (PHP 8.3+) — REST API |
| **Painel Admin** | **Filament** — tudo editável sem código: preços, margens, câmbio, modelo(s), nomes white-label, gateways, códigos de influenciador |
| **Base de Dados** | MySQL 8.0+ |
| **Frontend Web** | Next.js 14+ + Tailwind CSS + shadcn/ui |
| **IDE Desktop** | **Fork do OpenCode desktop app** (Tauri + TypeScript, MIT) — app nativa Win/Linux |
| **Servidor** | Hetzner Cloud VPS CPX31 **existente** (partilhado com outros projetos — instalação isolada, zero alterações ao que já lá está). **SEM DOCKER**, tudo nativo |
| **Web Server** | Nginx + SSL Let's Encrypt — `qolari.com` (Next.js) + `api.qolari.com` (Laravel) |
| **Cache/Fila** | Redis + Laravel Horizon + Supervisor |
| **Storage** | Hetzner Object Storage (S3) — inclui **backups diários da MySQL** (retenção 30 dias) |
| **Email** | Resend.com (remetente: `qolari@qolari.com`) |
| **Monitorização** | Laravel Telescope (dev) + Sentry (produção) |
| **Deploy** | Git + script bash via SSH, com **releases datadas + symlink (rollback)** |

---

## Modelo de Receita

| Fonte | Descrição | Estimativa Ano 1 |
|-------|-----------|------------------|
| **IDE — Pacotes de Créditos** | Pacotes pré-pagos, margem 3× sobre custo USD | €10.000 – €30.000 |
| **Partners — Revenue Share** | Percentagem das receitas dos parceiros (manual, verificada na plataforma) | €0 – €10.000+ |
| **Influenciadores** | **Códigos de influenciador: comissão 10–20% configurável por código**, tracking de vendas por código, relatório no admin, **payout manual** por transferência. Canal principal de marketing (YouTube). | €1.000 – €5.000 (custo de aquisição) |

---

## Regras de Ouro (v2)

1. **TUDO é editável no painel admin** — preços, taxas, margens, câmbio, modelo(s), nomes, gateways, códigos. O fundador nunca toca em código.
2. **UM modelo ativo no lançamento** → um saldo por cliente (em USD). Arquitetura multi-modelo/multi-wallet pronta para ativar mais modelos por config.
3. **Sem cobrança automática** — só pacotes pré-pagos.
4. **Créditos expiram em 12 meses** — job mensal regista a expiração no ledger (controlo por lotes, FIFO).
5. **Conversão de saldo entre modelos** existe na arquitetura (taxa configurável) mas fica **dormente** até haver um 2º modelo ativo.
6. **IDE é desktop nativo** — não é PWA, não é web app.
7. **Sem Docker** — instalação nativa no Ubuntu 24.04 LTS.
8. **Moedas:** EUR, USD, GBP no lançamento (via Stripe); **AOA ativa quando o AppyPay entrar** (Fase 3). Preços por pacote por moeda, editáveis no admin.
9. **Gateways:** Stripe (global) no lançamento; EuPago/MBWay e AppyPay por procura.
10. **Mercado universal** desde o dia 1; idiomas **PT + EN** no lançamento (ES/FR/DE pós-lançamento).

---

## Fases de Implementação (v2)

| Fase | Conteúdo | Duração |
|------|----------|---------|
| **Fase 1** | Infra (auditoria + provisionamento isolado, backups, deploy c/ rollback) + Motor Financeiro (Laravel, ledger, Stripe EUR/USD/GBP, proxy OpenRouter c/ metering idempotente, sync de preços de custo, admin Filament, expiração 12m) + **benchmark interno de confirmação do modelo (K2.7 vs DeepSeek V4 Pro)** | 4–5 semanas |
| **Fase 2** | Site + dashboard (Next.js, PT/EN) + IDE MVP (fork OpenCode desktop, Win/Linux) + **códigos de influenciador** | 5–7 semanas |
| **Fase 3** | AppyPay (AOA) + EuPago se houver procura PT | 1–2 semanas |
| **Fase 4** | Auto-update IDE, i18n ES/FR/DE, Mac, otimizações de escala, 2º modelo / modo híbrido se fizer sentido, ferramentas de Partners (quando 3+ parceiros justificarem), provider direto (Moonshot/DeepSeek oficial) se a margem apertar | contínuo |

**Primeira receita possível:** fim da Fase 1 (venda de créditos via dashboard, antes do IDE existir).

---

## Segurança e Credenciais

> ⚠️ **Regra permanente:** nenhuma credencial vive neste repositório — tokens, passwords e chaves ficam em gestor de passwords e variáveis de ambiente no servidor.
>
> **Estado a 28-07-2026:** o token Hetzner antigo foi exposto e revogado. O novo token foi entregue fora do repositório e será usado apenas em memória/ambiente durante a execução — nunca impresso em logs nem gravado em ficheiros do projeto. Antes do provisionamento: auditoria à conta Hetzner (servidores desconhecidos, SSH keys estranhas, faturação anómala).
>
> **Nota:** documentos de conta (ex: emails do registrar) não devem ficar na pasta do projeto — guardar em gestor de passwords/cofre.

---

## Mercado-Alvo
Universal (sem foco único de país no lançamento) — idiomas PT + EN, moedas EUR/USD/GBP (+AOA na Fase 3).

## Pendências operacionais (v3)
- [x] ~~Comprar domínio~~ → **qolari.com** comprado e instalado na Hetzner (28-07-2026)
- [x] ~~Token Hetzner~~ → novo token entregue (verificado: não é o antigo comprometido)
- [x] **Modelo chefe:** Kimi K2.7 Code via OpenRouter (benchmark de confirmação na Fase 1)
- [x] **IDE:** fork do OpenCode desktop app (spike de validação na Fase 2)
- [x] **Email profissional:** qolari@qolari.com
- [ ] Confirmar dados da empresa em Portugal para Stripe e IVA
- [ ] **Definir o split dos Partners na constituição** (bloqueante para o Pilar 3)
- [ ] Criar GitHub privado e dar o primeiro push
- [ ] Mac + Apple Developer ($99/ano) — só quando o Mac entrar no roadmap

---

> **Resumo numa frase:** *A Qolari é uma plataforma de programação com IA que vende créditos pré-pagos (margem 3× sobre custo USD), cresce por códigos de influenciador no YouTube e por parcerias locais em que o fundador entra como sócio e entrega a tecnologia — onde o fundador nunca toca em código e o cliente nunca precisa de sair do ecossistema.*
