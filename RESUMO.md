# Qolari — Resumo Executivo (v4.2 — Ecossistema Híbrido, 06-08-2026)

> Antes "Nexus AI". Marca registada: **Qolari** — domínio `qolari.com` (comprado, na Hetzner), email profissional `qolari@qolari.com`.
>
> **v4 (06-08-2026):** integração das ideias de `ecossistema_ia_estrategia_v3.pdf`, debatidas e decididas secção a secção — nascem o **Pilar 2 (Qolari Chat)** e o **Pilar 4 (Co-Criação)**; estratégia **IDE desktop + extensão VS Code/Cursor**; providers **diretos** (sem OpenRouter); modelo de ecossistema **híbrido** (Pilar 1 fechado, Pilar 4 com Modo Qolari ou Modo Livre).
> **v4.1:** Code = só DeepSeek direto; Chat = só browser, subscrição; Angola com geo-pricing + Multicaixa Express; co-criação manual por defeito, IA opt-in.
> **v4.2:** ecossistema híbrido confirmado; API de modelo 100% grátis para testes/desenvolvimento.

---

## O que é?
**Qolari** é um ecossistema de 4 pilares: **programar com IA** (Code), **conversar com IA** (Chat), **co-criar produtos em equipa** (Co-Criação) e **transformar projetos em negócios com investidores** (Partners) — tudo dentro da mesma plataforma, com uma só marca ("Qolari").

---

## 💰 Os Dois Mundos de Billing (saldos SEPARADOS, sem conversão)

| | 💻 **Qolari Code** | 💬 **Qolari Chat** |
|---|---|---|
| **Cobrança** | Pacotes **pré-pagos** de créditos | **Subscrição** mensal (nomes dos tiers a decidir) |
| **Saldo** | Créditos USD (expiram em 12 meses) | Plafond de tokens por período |
| **Providers** | **Só DeepSeek, compra direta** (sem OpenRouter) — white-label, o cliente vê só "Qolari" | **APIs oficiais dos melhores modelos** (OpenAI, Anthropic, Google, DeepSeek...), compra direta, atrás do proxy |
| **Anti-abuso** | Saldo esgota → cliente compra mais | **Teto de tokens por tier + rate-limiting + throttling** (resposta abranda após X% do plafond) |
| **Margem** | **3× sobre custo USD** — mundial **e** Angola (geo-pricing AOA) | **3× em Angola** (AOA, geo-pricing); **preço fora de Angola: a definir** |

> ⚠️ **Exceção formal à antiga Regra de Ouro 3:** o Chat **é subscrição** (cobrança recorrente). O pré-pago mantém-se só no Code.
>
> **Desenvolvimento/testes:** usa-se uma **API de modelo 100% grátis** (qual, a definir) — não se gastam tokens pagos em dev.
>
> **Arquitetura:** o proxy mantém a **camada de abstração de provider** — cada loja oficial é plugável por config no admin; OpenRouter pode voltar como opção futura sem código.

---

## 🔷 Pilar 1 — Qolari Code
Programação com IA white-label, paga por pacotes pré-pagos de créditos.

- **Duas portas de entrada, um só motor** (proxy, ledger, pacotes):
  1. **Qolari IDE** — desktop nativo (fork do OpenCode, Tauri, Win/Linux), lança **primeiro** (Fase 2).
  2. **Extensão Qolari para VS Code/Cursor** — fork de open source (tipo Roo Code/Cline), provider bloqueado ao proxy; uma extensão cobre os dois editores. Lança logo a seguir (**Fase 2.5**) como **topo de funil** ("usa a Qolari dentro do VS Code").
- **Ecossistema fechado aqui:** cliente individual usa IDE/extensão Qolari com o modelo Qolari (DeepSeek) — é onde vive a margem 3× dos tokens.
- **Angola (geo-pricing):** tal como no Chat, clientes detetados em Angola (IP + país da conta) veem preços em **AOA** e pagam por **Multicaixa Express** (Fase 3), com a mesma margem 3×.
- **Um modelo ativo** (DeepSeek direto); arquitetura multi-modelo pronta para ativar mais por config.
- **Updates:** download manual no lançamento; auto-update na Fase 4. Mac fica para depois (Apple Developer $99/ano).

---

## 🔷 Pilar 2 — Qolari Chat (NOVO — v4)
Chatbot **só em browser** (responsivo para desktop e mobile — **nenhuma app nativa**), com histórico de conversas centralizado e sincronizado entre dispositivos.

- **Subscrição** com tiers (nomes a decidir); a Qolari adquire API tokens **diretamente às empresas oficiais** para ter os melhores modelos disponíveis atrás do proxy.
- **Controlo anti-abuso:** teto de tokens por tier + rate-limiting + throttling — nenhum cliente consome os créditos todos.
- Streaming (SSE) e **fallback automático** entre providers.
- **Angola:** mesma plataforma, mas **preços e métodos de pagamento diferentes** — **geo-detecção (IP) + país declarado na conta**; pagamento por **Multicaixa Express** (integração via gateway EMIS — caminho exato a verificar na Fase 3). Subscrição a 3× também em Angola.
- **Saldo separado do Code**, sem conversão (arquitetura multi-wallet fica dormente).

---

## 🔷 Pilar 3 — Qolari Partners + Marketplace (inalterado)
O fundador aproxima-se de empreendedores e entra como **sócio + suporte tecnológico**: entrega o produto adaptado (a partir dos repositórios internos), mantém-no atualizado, e a Qolari recebe a percentagem acordada.

- **100% manual até 3+ parceiros ativos:** contratos + folha de cálculo, zero código próprio.
- **Verificação de receita:** projetos dos parceiros correm na infraestrutura da Qolari — faturação visível na plataforma.
- **Split de receitas:** a definir na constituição (**bloqueante** — sem isto não há parcerias).
- **Marketplace** (`qolari.com/pt/marketplace` — QolariDriver, QolariFood, Noah Olive): **mantém-se como está** — negócio à parte entre a Qolari e futuros investidores, e **montra viva** do que a plataforma consegue construir.

---

## 🔷 Pilar 4 — Co-Criação (NOVO — v4; prioridade alta, "construir no melhor momento")
Plataforma onde criadores, devs e investidores co-fundam produtos em equipa.

**Fluxo principal — MANUAL por defeito, IA opt-in:**
1. O criador **descreve a sua ideia**.
2. Os devs **juntam-se e debatem entre si** — por defeito é 100% manual, eles decidem entre si.
3. **Opt-in do projeto:** se os membros quiserem, ativam a ajuda da IA — incluindo o modo em que **a IA delega o que cada membro faz** (ideia → épicos → tarefas → atribuição).

**Funcionalidades:**
- **Matchmaking por visão** — competências complementares.
- **Quotas por marcos** — participação atribuída conforme entregas (matriz cap table: decisão adiada).
- **Cockpit de equipa** — dashboard com estado de cada membro/módulo + alertas de conflito de contexto (vive no Qolari IDE); telemetria completa aceite.
- **Botão SOS** — pedido de ajuda **à equipa**: captura o contexto imediato (terminal, erro exato) e envia aos colegas.
- **Gestão de crise e desistência** — deteção de inatividade, reatribuição de tarefas/código.
- **Stack de IA por projeto (flexível):** o criador **pode** definir o modelo oficial da equipa, **ou** deixar a decisão aos devs, **ou** fornecer a **sua própria API key** para devs que não tenham — tudo dentro do sistema. **Tetos de consumo por dev.**
- **KYC obrigatório para todos os participantes** (criador/idealista/dev/investidor). Clientes do Code e do Chat **não** fazem KYC. **Angolanos: podem ser criadores/idealistas/devs — NUNCA investidores** (forçado no KYC pelo país do documento).
- **Escrow via Stripe Connect** — fundos de investidores retidos e libertados por milestone, reembolso se o projeto estagnar. ⚠️ **Validação jurídica prévia obrigatória** (reter fundos de terceiros pode ser atividade regulada em PT/UE — CMVM/pagamentos).
- **Jurídico: contratos primeiro, automação depois** — contratos-quadro + vesting redigidos por advogado e assinados na plataforma; **kill switch por votação** (maioria da equipa substitui criador ausente) e **PI intermédia** (código licenciado ao projeto) desde o início; **RSA/code-is-law** (distribuição automática de receitas, revogação de acessos, audit trail) na iteração seguinte.

### ⚖️ Ecossistema Híbrido (decisão v4.2)
No Pilar 4, **o criador escolhe o modo do projeto:**
- 🔒 **Modo Qolari** — todos no IDE Qolari, stack oficial, tetos por dev → a Qolari ganha a **margem 3× dos tokens**.
- 🌐 **Modo Livre** — cada membro usa o seu IDE e o seu modelo, **telemetria obrigatória** e todos os suportes da plataforma (cockpit, SOS, governança) → a Qolari cobra **subscrição por assento** da plataforma (não há margem de tokens).

---

## Stack Técnica

| Camada | Tecnologia |
|--------|-----------|
| **Backend API** | Laravel 11+ (PHP 8.3+) — REST API |
| **Painel Admin** | **Filament** — tudo editável sem código: preços, margens (por modelo/produto/mercado), câmbio, modelo(s), tiers, nomes white-label, gateways, geo-pricing, códigos de influenciador |
| **Base de Dados** | MySQL 8.0+ |
| **Frontend Web** | Next.js 14+ + Tailwind CSS + shadcn/ui |
| **IDE Desktop** | **Fork do OpenCode desktop app** (Tauri + TypeScript, MIT) — app nativa Win/Linux |
| **Extensão** | Fork de extensão open source agentic (tipo Roo Code/Cline) — VS Code + Cursor, provider bloqueado ao proxy |
| **Chat** | Só browser (responsive), parte do frontend Next.js |
| **Providers IA** | **Diretos:** DeepSeek (Code), APIs oficiais dos melhores modelos (Chat) — abstração por config |
| **Servidor** | Hetzner Cloud VPS CPX31 **existente** (partilhado — instalação isolada, zero alterações ao que já lá está). **SEM DOCKER**, tudo nativo |
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
| **Code — Pacotes de Créditos** | Pré-pagos, margem 3× sobre custo USD (DeepSeek direto) | €10.000 – €30.000 |
| **Chat — Subscrições** | Tiers mensais com plafond de tokens; 3× em Angola; preço mundial a definir | a estimar |
| **Partners — Revenue Share** | Percentagem das receitas dos parceiros (manual, verificada na plataforma) | €0 – €10.000+ |
| **Influenciadores** | **Códigos de influenciador: comissão 10–20% configurável por código**, tracking por código, relatório no admin, **payout manual**. Canal principal de marketing (YouTube). | €1.000 – €5.000 (custo de aquisição) |
| **Co-Criação (futuro)** | Modo Livre: subscrição por assento; escrow e RSA quando automatizados | — |

---

## Regras de Ouro (v4.2)

1. **TUDO é editável no painel admin** — preços, taxas, margens (por modelo/produto/mercado), câmbio, modelo(s), tiers, nomes, gateways, geo-pricing, códigos. O fundador nunca toca em código.
2. **UM modelo ativo por produto no lançamento** — Code: DeepSeek direto. Arquitetura multi-modelo/multi-wallet pronta para ativar mais por config.
3. **Code = pré-pago; Chat = subscrição** — são os dois mundos de billing, com saldos separados e sem conversão.
4. **Créditos do Code expiram em 12 meses** — job mensal regista a expiração no ledger (lotes, FIFO).
5. **Conversão de saldo entre modelos/carteiras** existe na arquitetura mas fica **dormente**.
6. **IDE é desktop nativo; Chat é só browser** — nenhum deles é PWA/app nativa extra.
7. **Sem Docker** — instalação nativa no Ubuntu 24.04 LTS.
8. **Moedas:** EUR, USD, GBP no lançamento (Stripe); **AOA via Multicaixa Express na Fase 3**, com **geo-pricing no Code e no Chat** (deteção por IP + país da conta). Preços por pacote/tier por moeda, editáveis no admin.
9. **Gateways:** Stripe (global) no lançamento; Multicaixa Express/EMIS para Angola; EuPago/MBWay por procura.
10. **Mercado universal** desde o dia 1; idiomas **PT + EN** no lançamento (ES/FR/DE pós-lançamento).
11. **Providers diretos** (sem intermediário) — cada um plugável por config no proxy.
12. **KYC só para participantes da Co-Criação** — clientes do Code/Chat registam-se sem fricção; angolanos nunca investidores.
13. **Testes/dev com API de modelo 100% grátis** — nunca se gastam tokens pagos em desenvolvimento.

---

## Fases de Implementação (v4.3 — remodeladas a 06-08-2026 com o inventário do código)

> **Nota de reconciliação:** a arquitetura de **tiers Nexus** já implementada (slugs white-label, margens, routing, recomendador) **mantém-se** — mas os motores passam de OpenRouter para **providers diretos** (DeepSeek no lançamento; GLM futuro p/ visão). **1 tier ativo no lançamento**, restantes dormentes por config. Detalhe de execução em `docs/ROADMAP-NEXUS.md`.

| Fase | Conteúdo | Estado |
|------|----------|--------|
| **Fase 1 — Fundação e Motor** | Infra (provisionamento isolado, backups, deploy c/ rollback) + Motor Financeiro (ledger, wallets, lotes FIFO 12m, Stripe, admin Filament, auth) + proxy OpenAI-compatible (SSE, metering idempotente, tiers) **✅ ~85% FEITO e testado**. **Fecho:** ✅ abstração de provider por config + engine **DeepSeek direto** (seeder atualizado, 42/42 testes) + provider **NVIDIA NIM (free)** p/ testes + admin Model Costs. **Falta:** keys oficiais (DeepSeek/NVIDIA) no admin + benchmark de confirmação + Stripe live (dados da empresa) | 🟡 Em fecho |
| **Fase 2 — IDE Desktop + Lançamento Code** | Fork OpenCode: rebrand, login gate, lockdown, picker de tiers, briefing, recomendador **✅ maior parte FEITA** (em curso no `ide/`). Web: ✅ endpoint de validação de código + **checkout com código de influenciador** (campo c/ validação live, `?ref=` → cookie) + **pricing agrupada por tier** + badge Popular editável (`is_featured`). Falta: validação hands-on do build, telemetria no IDE, pacotes por tier (criar no admin), instaladores Win/Linux, landing final. **→ Primeira receita** | 🟡 Quase |
| **Fase 2.5 — Extensão VS Code/Cursor** | **Fork do Cline** (decisão 06-08): **✅ spike técnico concluído (07-08)** — 13 ficheiros, diff mínimo (marcado `// Qolari fork:`): rebrand (`qolari-code`), provider único "Qolari" bloqueado ao proxy (`api.qolari.com/v1`, modelo default `nexus-high`, livre-texto), telemetria PostHog desligada, **build verde → `extensao/apps/vscode/dist/qolari-code.vsix` (11.9 MB)**. Falta: revisão legal (ToS/Apache), contas publisher (VS Code Marketplace + Open VSX), limpar branding residual (walkthrough, strings webview), publicar | 🟡 Spike ✅ |
| **Fase 3 — Qolari Chat + Angola** | **✅ Backend (07-08):** motor de subscrições completo — `subscription_plans`/`subscriptions` (Stripe `mode: subscription`, webhooks sync idempotentes), plafond de tokens por período c/ roll-forward lazy, throttling (`X-Qolari-Throttled`), Chat API (conversas + mensagens persistidas, streaming SSE, billing na subscrição **sem tocar nas wallets**), admin Filament (Plans + Subscriptions). **71/71 testes.** Falta: Chat UI browser (frontend), geo-pricing (IP + país), AOA/Multicaixa Express (EMIS), EuPago se procura PT | 🟡 Backend ✅ |
| **Fase 4 — Escala e Polimento** | Auto-update IDE, Mac, i18n ES/FR/DE, 2º modelo/tier ativo (GLM p/ visão), shadow/canary de modelos, ferramentas Partners (3+ parceiros), otimizações | ⬜ contínuo |
| **Pilar 4 — Co-Criação** (fase própria, "no melhor momento") | **Pré-requisitos:** validação jurídica do escrow + contratos-quadro com advogado. **Build:** matchmaking, projetos/equipas, quotas por marcos, cockpit + telemetria, SOS à equipa, gestão de crise, stack de IA flexível + tetos por dev, KYC (angolanos nunca investidores), escrow Stripe Connect, Modo Qolari/Modo Livre (subscrição por assento), kill switch, PI intermédia. **Iteração 2:** RSA/code-is-law | ⬜ |

**Primeira receita possível:** fim da Fase 1 (venda de créditos via dashboard, antes do IDE existir).

---

## 🗑️ Descartado do PDF de estratégia (decisões v4)
- ❌ Agregador multi-fornecedor **visível** ao cliente no Code (mantém-se white-label fechado; no Chat os modelos são oficiais mas atrás do proxy).
- ❌ OpenRouter como intermediário (providers diretos; fica como opção futura por config).
- ❌ Apps nativas para o Chat (só browser).
- ❌ KYC universal (só Co-Criação; angolanos nunca investidores).
- ❌ Cockpit em IDEs externos (vive no Qolari IDE; Modo Livre tem apenas telemetria).
- ❌ Execução guiada por IA como padrão (é **opt-in**; o padrão da co-criação é manual).
- ❌ Automação jurídica total desde o dia 1 (contratos primeiro; RSA/code-is-law depois).

---

## Segurança e Credenciais

> ⚠️ **Regra permanente:** nenhuma credencial vive neste repositório — tokens, passwords e chaves ficam em gestor de passwords e variáveis de ambiente no servidor. Isto inclui as **API keys dos providers oficiais** (DeepSeek, OpenAI, Anthropic, Google...) e a futura API grátis de testes.
>
> **Estado a 28-07-2026:** o token Hetzner antigo foi exposto e revogado. O novo token foi entregue fora do repositório e será usado apenas em memória/ambiente durante a execução — nunca impresso em logs nem gravado em ficheiros do projeto. Antes do provisionamento: auditoria à conta Hetzner (servidores desconhecidos, SSH keys estranhas, faturação anómala).
>
> **Nota:** documentos de conta (ex: emails do registrar) não devem ficar na pasta do projeto — guardar em gestor de passwords/cofre.

---

## Mercado-Alvo
Universal (sem foco único de país no lançamento) — idiomas PT + EN, moedas EUR/USD/GBP. **Angola (AOA, Multicaixa Express) entra na Fase 3** com preços e pagamentos próprios; angolanos podem ser criadores/idealistas/devs na Co-Criação, nunca investidores.

## Pendências operacionais (v4.2)
- [x] ~~Comprar domínio~~ → **qolari.com** comprado e instalado na Hetzner (28-07-2026)
- [x] ~~Token Hetzner~~ → novo token entregue (verificado: não é o antigo comprometido)
- [x] **Modelo chefe do Code:** DeepSeek (compra direta) — benchmark já não é K2.7 vs DeepSeek via OpenRouter
- [x] **IDE:** fork do OpenCode desktop app (Fase 2) + extensão VS Code/Cursor (Fase 2.5)
- [x] **Email profissional:** qolari@qolari.com
- [ ] Confirmar dados da empresa em Portugal para Stripe e IVA (chaves **test** já existem; faltam as **live**)
- [ ] **Definir o split dos Partners na constituição** (bloqueante para o Pilar 3)
- [ ] Criar GitHub privado e dar o primeiro push (token GitHub existe; remote `origin` já configurado para `qolariai/qolari`)
- [ ] Mac + Apple Developer ($99/ano) — só quando o Mac entrar no roadmap
- [x] **API grátis para testes/dev:** provider **NVIDIA NIM configurado e validado** (key real testada 06-08; benchmark `nexus-low` free = 15/16). Qwen fica como alternativa
- [ ] **Definir preço do Chat fora de Angola** e **nomes dos tiers** do Chat
- [ ] Verificar integração **Multicaixa Express** (gateway EMIS: AppyPay vs GPO direto)
- [ ] **Validação jurídica do escrow** (Stripe Connect + retenção de fundos em PT/UE) — pré-requisito do Pilar 4
- [ ] **Contratos-quadro + vesting redigidos por advogado** — pré-requisito do Pilar 4
- [ ] 🚨 **Mover `aceder.txt` para gestor de passwords e apagar do projeto** (credenciais em texto claro — viola a regra de segurança; já adicionado ao `.gitignore` como rede de segurança); considerar **rotação dos tokens** que estiveram expostos
- [ ] **Obter API key oficial DeepSeek** e configurar no admin (`deepseek_api_key`); correr `AiModelsSeeder` + benchmark de confirmação (`php artisan qolari:benchmark`)
- [ ] **Push + deploy do backend** para `api.qolari.com` (inclui `c417caf` SSE error frame + pivô de providers 06-08) — fazer quando a Fase 1 fechar

---

> **Resumo numa frase:** *A Qolari é um ecossistema de quatro pilares — Code (IDE/extensão com modelo próprio, créditos pré-pagos a 3× sobre DeepSeek direto), Chat (subscrição browser com os melhores modelos oficiais), Partners (parcerias manuais com montra no marketplace) e Co-Criação (equipas que co-fundam produtos, manual por defeito com IA opt-in, em Modo Qolari ou Modo Livre) — onde o fundador nunca toca em código e o cliente nunca precisa de sair do ecossistema.*
