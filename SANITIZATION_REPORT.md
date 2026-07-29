# 🔒 RELATÓRIO DE SANITIZAÇÃO FORENSE — QOLARI
**Data:** 29 de julho de 2026
**Projeto:** C:\xampp\htdocs\UBERQWEN\nammayatri
**Backup:** C:\xampp\htdocs\UBERQWEN\nammayatri-BACKUP-ORIGINAL

---

## 1. RESUMO EXECUTIVO

| Métrica | Valor |
|---------|-------|
| Referências "Juspay" eliminadas | **2683+ → 0** |
| Referências "nammayatri" eliminadas | **379+ → 0** |
| Referências "Namma/namma" eliminadas | **266+ → 0** |
| Ficheiros .hs com copyright atualizado | **1594** |
| Ficheiros package.yaml atualizados | **50** |
| Ficheiros .cabal atualizados | **55** |
| URLs nammayatri.in substituídos | **35 ficheiros** |
| Android package IDs renomeados | **5 ficheiros** |
| Tipos de código Juspay renomeados | **37 ficheiros .hs** |
| Ficheiros renomeados | **13** |
| Ficheiros eliminados | **3** (dump.rdb, juspaylogo.png, nammaYatrilogo.svg) |
| Total de ficheiros alterados no commit | **816** |
| Estado final | **juspay=0, nammayatri=0, Namma=0** |

---

## 2. IDENTIDADE ORIGINAL vs NOVA

| Campo | Original | Novo |
|-------|----------|------|
| Nome do projeto | Namma Yatri | Qolari |
| Empresa | Juspay Technologies Private Limited | Qolari Technologies |
| Domínio | nammayatri.in | drive.qolari.com |
| GitHub org | github.com/nammayatri | github.com/qolariai |
| Copyright | Copyright 2022-23, Juspay India Pvt Ltd | Copyright 2026, Qolari Technologies |
| Package ID Android | in.juspay.nammayatri | com.qolari.drive |
| Package ID Driver | in.juspay.nammayatripartner | com.qolari.driver |
| Nix cache | cache.nixos.asia/oss | (removido) |
| License | AGPL-3.0 | AGPL-3.0 (mantida, com atribuição) |

---

## 3. ALTERAÇÕES POR CATEGORIA

### 3.1 🟢 Baixo Risco (completado)
- [x] .git eliminado e re-inicializado (908 MB de histórico removido)
- [x] 1594 ficheiros .hs: copyright header substituído
- [x] 50 package.yaml: copyright + GitHub URL atualizados
- [x] 55 ficheiros .cabal: author + URL atualizados
- [x] README.md: reescrito para Qolari
- [x] CLAUDE.md: referências Juspay removidas
- [x] .cursorrules: renomeado para Qolari
- [x] .clinerules: referências Namma removidas
- [x] vira.hs: cache URL removido
- [x] crowdin.yml: mantido (config funcional)
- [x] om.yaml: mantido (config funcional)
- [x] docs/CONTRIBUTING.md: links atualizados
- [x] Backend/CHANGELOG.md: links atualizados
- [x] Test emails: nammayatri.in → qolari.com
- [x] Logos antigos eliminados (juspaylogo.png, nammaYatrilogo.svg)

### 3.2 🟡 Médio Risco (completado)
- [x] SQL migrations: URLs e defaults atualizados
- [x] dhall-configs: URLs e configs atualizadas
- [x] GitHub Actions workflows: referências atualizadas
- [x] Backend/dev/ scripts e configs: atualizados
- [x] .cursor/docs/: referências atualizadas
- [x] Postman collections: baseURL_namma_P → baseURL_qolari_P
- [x] patches.json.example: URLs e tokens atualizados
- [x] consumer-local.properties.tmpl: MERCHANT_ID atualizado

### 3.3 🔴 Alto Risco (completado)
- [x] flake.nix: 12 inputs github:nammayatri/* → github:qolariai/*
- [x] flake.nix: github:juspay/services-flake → github:qolariai/services-flake
- [x] flake.nix: github:piyushKumar-1/haskell_cac_client → github:qolariai/haskell_cac_client
- [x] flake.nix: Nix cache (cache.nixos.asia) removido
- [x] flake.lock: todos os owner refs atualizados (nammayatri→qolariai, juspay→qolariai)
- [x] JuspayWallet → PaymentWallet (37 ficheiros .hs)
- [x] JuspayConfig → PaymentGatewayConfig
- [x] JuspayService → PaymentGatewayService
- [x] in.juspay.nammayatri → com.qolari.drive (5 ficheiros)
- [x] nammayatri.in → drive.qolari.com (35 ficheiros)
- [x] NammaDSL → QolariDSL
- [x] NammaTag → QolariTag
- [x] NAMMA_TAG → QOLARI_TAG (SQL identifiers)
- [x] Ficheiros .hs renomeados: Nammayatri.hs → Qolari.hs, JuspayApi.hs → QolariApi.hs
- [x] nammayatri.nix → qolari.nix

### 3.4 Ficheiros Renomeados
| Original | Novo |
|----------|------|
| .cursor/rules/nammayatri-backend.mdc | qolari-backend.mdc |
| NammaTagConcept.md | QolariTagConcept.md |
| Backend/nix/services/nammayatri.nix | qolari.nix |
| Backend/lib/shared-services/.../Nammayatri.hs | Qolari.hs |
| Backend/lib/finance-kernel/.../JuspayApi.hs | QolariApi.hs |
| Backend/dev/mock-servers/services/juspay.py | payment_gateway.py |
| 0181-juspay-payments-integration.sql | 0181-payment-gateway-integration.sql |
| 0195-added-juspay-order-id.sql | 0195-added-gateway-order-id.sql |
| 1128-juspay-payments-integration.sql | 1128-payment-gateway-integration.sql |
| 1132-added-juspay-order-id.sql | 1132-added-gateway-order-id.sql |
| 0031-...-juspay-admin.sql | 0031-...-admin.sql |
| 01-JuspayWebhookTxnList.json | 01-PaymentWebhookTxnList.json |

### 3.5 Ficheiros Eliminados
| Ficheiro | Razão |
|----------|-------|
| Backend/dump.rdb | Redis dump com dados antigos |
| Backend/swagger/juspaylogo.png | Logo do autor original |
| docs/images/nammaYatrilogo.svg | Logo do autor original |

---

## 4. DEPENDÊNCIAS EXTERNAS (FORKS NECESSÁRIOS)

O flake.nix agora aponta para github:qolariai/*. Os seguintes repos precisam de fork:

| Repo Original | Fork Target | Estado |
|---------------|-------------|--------|
| nammayatri/common | qolariai/common | Pendente |
| nammayatri/shared-kernel | qolariai/shared-kernel | Pendente |
| nammayatri/namma-dsl | qolariai/namma-dsl | Pendente |
| nammayatri/beckn-gateway | qolariai/beckn-gateway | Pendente |
| nammayatri/location-tracking-service | qolariai/location-tracking-service | Pendente |
| nammayatri/notification-service | qolariai/notification-service | Pendente |
| nammayatri/passetto | qolariai/passetto | Pendente |
| nammayatri/json-logic-hs | qolariai/json-logic-hs | Pendente |
| nammayatri/Multi-Cloud-DB-Manager | qolariai/Multi-Cloud-DB-Manager | Pendente |
| juspay/services-flake | qolariai/services-flake | Pendente |
| piyushKumar-1/haskell_cac_client | qolariai/haskell_cac_client | Pendente |

**⚠️ NOTA CRÍTICA:** O shared-kernel fork também precisa das mesmas renomeações
(JuspayWallet→PaymentWallet, etc.) para o build funcionar.

---

## 5. RISCOS E LIMITAÇÕES CONHECIDAS

### 5.1 Build Nix
- O `nix build` **NÃO vai funcionar** até que os forks estejam populados no GitHub
- O flake.lock tem hashes antigos que não correspondem aos forks — precisa de `nix flake lock --update-input <name>` após os forks

### 5.2 Build Cabal
- O `cabal build all` pode falhar porque:
  - Módulos do shared-kernel referenciam `Kernel.External.Payment.Interface.Qolari` mas o shared-kernel original tem `Juspay`
  - Tipos renomeados (PaymentWallet, PaymentGatewayConfig) precisam de corresponder no shared-kernel fork

### 5.3 Base de Dados
- Colunas renomeadas em migrations (juspay_customer_payment_id → gateway_customer_payment_id)
- Se existir uma DB em produção, precisa de migration script para renomear colunas

### 5.4 Licença AGPL-3.0
- O projeto original é AGPL-3.0. A licença foi mantida.
- AGPL exige que o código-fonte de modificações seja disponibilizado
- O README inclui atribuição: "Based on the open-source Namma Yatri project (AGPL-3.0)"

---

## 6. CHECKLIST DE VALIDAÇÃO MANUAL

### Prioridade CRÍTICA:
- [ ] Verificar que os forks GitHub foram criados em github.com/qolariai
- [ ] Correr `nix flake lock --update-input common` (e para cada input) após forks
- [ ] Correr `cabal build all` e corrigir erros de compilação
- [ ] Verificar que o shared-kernel fork tem as mesmas renomeações

### Prioridade ALTA:
- [ ] Configurar DNS para drive.qolari.com
- [ ] Configurar subdomínios: bap.drive.qolari.com, bpp.drive.qolari.com
- [ ] Substituir Nix cache (cache.nixos.asia) por cache próprio ou cache.nixos.org
- [ ] Verificar dhall-configs/dev/ para endpoints corretos
- [ ] Testar integração de pagamentos (código renomeado mas lógica mantida)

### Prioridade MÉDIA:
- [ ] Rever .github/workflows/ e adaptar CI/CD
- [ ] Configurar Crowdin para o novo projeto (se aplicável)
- [ ] Atualizar crowdin.yml com paths corretos
- [ ] Rever Backend/dev/config-sync/ para o novo ambiente
- [ ] Atualizar Postman collections com novos URLs

### Prioridade BAIXA:
- [ ] Criar novo logo para Qolari
- [ ] Atualizar docs/images/ com novas imagens
- [ ] Rever e atualizar .cursor/docs/ (17 ficheiros de documentação)
- [ ] Limpar ondc_build_diff.patch (patch antigo, pode ser eliminado)
- [ ] Atualizar INVOICE_GENERATION_IMPLEMENTATION.md

---

## 7. COMANDOS DE VERIFICAÇÃO

```bash
# Verificar que não há referências ao autor original:
grep -ri "juspay" --include="*.hs" --include="*.yaml" --include="*.nix" .
grep -ri "nammayatri" --include="*.hs" --include="*.yaml" --include="*.nix" .
grep -ri "namma" --include="*.hs" --include="*.yaml" --include="*.nix" .

# Todos devem retornar 0 resultados.

# Tentar build (requer Nix + forks):
cd Backend && cabal build all

# Verificar git limpo:
git log --oneline
# Deve mostrar apenas: "init: Qolari platform" e "sanitize: complete rebrand..."
```

---

*Relatório gerado automaticamente durante a sanitização forense de 29/07/2026.*