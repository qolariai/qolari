-- ============================================================================
-- QOLARI — Schema v1 (MySQL 8.0+, InnoDB, utf8mb4)
-- Marca: Qolari (qolari.com) — antes "Nexus AI" (rebrand a 28-07-2026)
-- Fase 1: Motor Financeiro + Billing + Metering
--
-- CONVENÇÕES (decisões v1/v2):
--  * Saldos das wallets são denominados em USD (o custo OpenRouter é em USD).
--    O cliente paga em EUR/USD/GBP/AOA; a conversão usa exchange_rates.
--  * Margem = markup sobre custo USD (default 3.00 = 200% de markup, preço = 3× custo).
--  * O saldo na tabela `wallets` é CACHE — a verdade é o `ledger_entries`
--    (tabela imutável, append-only, sem UPDATE/DELETE).
--  * Créditos expiram 12 meses após a compra — controlo por lotes (FIFO)
--    em `credit_lots`.
--  * Tudo o que é regra de negócio editável vive em `settings` ou em
--    colunas de configuração — nunca hardcoded.
--  * Tabelas do framework (sessions, cache, jobs, personal_access_tokens,
--    telescope) são criadas pelas migrations do Laravel — não constam aqui.
-- ============================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';  -- tudo em UTC; apresentação converte

-- ----------------------------------------------------------------------------
-- Utilizadores
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(190) NOT NULL UNIQUE,
    email_verified_at TIMESTAMP NULL,
    password        VARCHAR(255) NOT NULL,
    is_admin        TINYINT(1) NOT NULL DEFAULT 0,
    country         CHAR(2) NULL,                 -- ISO 3166-1 (PT, AO, BR...)
    preferred_currency CHAR(3) NOT NULL DEFAULT 'EUR',  -- EUR|USD|GBP|AOA
    language        CHAR(2) NOT NULL DEFAULT 'pt',      -- pt|en (es|fr|de depois)
    promo_code_id   BIGINT UNSIGNED NULL,         -- código usado no registo (FK adicionada depois de promo_codes)
    remember_token  VARCHAR(100) NULL,
    created_at      TIMESTAMP NULL,
    updated_at      TIMESTAMP NULL,
    INDEX idx_users_promo (promo_code_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Definições globais editáveis no admin (chave-valor)
-- Exemplos de chaves: conversion_fee_percent, default_margin_multiplier,
-- stripe_secret_key (encriptada), eupago_*, appypay_*, openrouter_api_key
-- (encriptada), site_name, support_email, influencer_default_percent...
-- ----------------------------------------------------------------------------
CREATE TABLE settings (
    `key`       VARCHAR(100) PRIMARY KEY,
    value       TEXT NULL,
    is_secret   TINYINT(1) NOT NULL DEFAULT 0,    -- se 1, valor encriptado (Laravel Crypt)
    updated_at  TIMESTAMP NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Taxas de câmbio — base USD (editável no admin; atualização manual pelo fundador)
-- rate_to_usd: quanto vale 1 unidade da moeda em USD (ex: EUR = 1.1372)
-- ----------------------------------------------------------------------------
CREATE TABLE exchange_rates (
    currency    CHAR(3) PRIMARY KEY,              -- EUR|USD|GBP|AOA
    rate_to_usd DECIMAL(12,6) NOT NULL,           -- USD é sempre 1.000000
    updated_at  TIMESTAMP NULL
) ENGINE=InnoDB;

INSERT INTO exchange_rates (currency, rate_to_usd) VALUES
    ('USD', 1.000000), ('EUR', 1.137200), ('GBP', 1.270000), ('AOA', 0.001100);

-- ----------------------------------------------------------------------------
-- Modelos de IA white-label — nomes editáveis no admin
-- ----------------------------------------------------------------------------
CREATE TABLE ai_models (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug                VARCHAR(50) NOT NULL UNIQUE,      -- qolari|max|medium
    display_name        VARCHAR(100) NOT NULL,            -- "Qolari" (editável)
    description         VARCHAR(255) NULL,
    provider            VARCHAR(50) NOT NULL DEFAULT 'openrouter',  -- abstração de provider
    provider_model_id   VARCHAR(150) NOT NULL,            -- ex: "moonshotai/kimi-k2.7-code"
    margin_multiplier   DECIMAL(5,2) NOT NULL DEFAULT 3.00,         -- 3.00 = 200% markup (preço = 3× custo)
    is_active           TINYINT(1) NOT NULL DEFAULT 1,
    sort_order          SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    created_at          TIMESTAMP NULL,
    updated_at          TIMESTAMP NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Custos reais por modelo (sincronizados da OpenRouter por job diário)
-- Preços por 1 MILHÃO de tokens, em USD
-- ----------------------------------------------------------------------------
CREATE TABLE model_costs (
    id                      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ai_model_id             BIGINT UNSIGNED NOT NULL,
    input_cost_per_mtok     DECIMAL(12,6) NOT NULL,
    output_cost_per_mtok    DECIMAL(12,6) NOT NULL,
    synced_at               TIMESTAMP NULL,
    created_at              TIMESTAMP NULL,
    FOREIGN KEY (ai_model_id) REFERENCES ai_models(id),
    INDEX idx_model_costs_model (ai_model_id, synced_at)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Produtos: 'package' = pacote de créditos por modelo
--           'bundle'  = (reservado; Pilar 2 removido a 27-07-2026 — manter
--                       o tipo para futuros bundles internos de Partners)
-- Preços por moeda em product_prices — tudo editável no admin
-- ----------------------------------------------------------------------------
CREATE TABLE products (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type            ENUM('package','bundle') NOT NULL DEFAULT 'package',
    ai_model_id     BIGINT UNSIGNED NOT NULL,       -- modelo a que os créditos dizem respeito
    name            VARCHAR(150) NOT NULL,
    description     TEXT NULL,
    credits_usd     DECIMAL(10,2) NOT NULL,         -- VALOR FACIAL dos créditos (USD)
    repo_reference  VARCHAR(255) NULL,              -- bundle: referência interna (não usado)
    delivery_notes  TEXT NULL,                      -- bundle: notas internas (não usado)
    is_active       TINYINT(1) NOT NULL DEFAULT 1,
    sort_order      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NULL,
    updated_at      TIMESTAMP NULL,
    FOREIGN KEY (ai_model_id) REFERENCES ai_models(id)
) ENGINE=InnoDB;

CREATE TABLE product_prices (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id  BIGINT UNSIGNED NOT NULL,
    currency    CHAR(3) NOT NULL,                   -- EUR|USD|GBP|AOA
    price       DECIMAL(10,2) NOT NULL,
    created_at  TIMESTAMP NULL,
    updated_at  TIMESTAMP NULL,
    UNIQUE KEY uq_product_currency (product_id, currency),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Códigos de influenciador (marketing) — comissão 10–20% configurável por código
-- ----------------------------------------------------------------------------
CREATE TABLE promo_codes (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code                VARCHAR(50) NOT NULL UNIQUE,
    owner_name          VARCHAR(150) NOT NULL,
    owner_contact       VARCHAR(190) NULL,          -- email/telegram para payout manual
    commission_percent  DECIMAL(5,2) NOT NULL,      -- ex: 15.00
    is_active           TINYINT(1) NOT NULL DEFAULT 1,
    created_at          TIMESTAMP NULL,
    updated_at          TIMESTAMP NULL
) ENGINE=InnoDB;

ALTER TABLE users
    ADD CONSTRAINT fk_users_promo FOREIGN KEY (promo_code_id) REFERENCES promo_codes(id);

-- ----------------------------------------------------------------------------
-- Encomendas e pagamentos
-- amount      = valor na moeda do cliente
-- amount_usd  = valor convertido (amount × exchange_rate_used) — base da comissão
-- ----------------------------------------------------------------------------
CREATE TABLE orders (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id             BIGINT UNSIGNED NOT NULL,
    product_id          BIGINT UNSIGNED NOT NULL,
    currency            CHAR(3) NOT NULL,
    amount              DECIMAL(10,2) NOT NULL,
    exchange_rate_used  DECIMAL(12,6) NOT NULL,
    amount_usd          DECIMAL(10,2) NOT NULL,
    gateway             ENUM('stripe','eupago','appypay') NOT NULL DEFAULT 'stripe',
    status              ENUM('pending','paid','failed','refunded') NOT NULL DEFAULT 'pending',
    promo_code_id       BIGINT UNSIGNED NULL,
    idempotency_key     VARCHAR(100) NOT NULL UNIQUE,   -- gerado no cliente/checkout
    fulfillment_status  ENUM('na','pending','delivered') NOT NULL DEFAULT 'na',
    created_at          TIMESTAMP NULL,
    updated_at          TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (promo_code_id) REFERENCES promo_codes(id),
    INDEX idx_orders_user (user_id, status),
    INDEX idx_orders_status (status, created_at)
) ENGINE=InnoDB;

-- Eventos de webhook dos gateways — idempotência por gateway_event_id
CREATE TABLE payment_events (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id            BIGINT UNSIGNED NULL,
    gateway             VARCHAR(30) NOT NULL,
    gateway_event_id    VARCHAR(150) NOT NULL UNIQUE,   -- nunca processar 2× o mesmo evento
    gateway_payment_id  VARCHAR(150) NULL,
    event_type          VARCHAR(80) NOT NULL,
    payload             JSON NULL,
    processed_at        TIMESTAMP NULL,
    created_at          TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_payment_events_order (order_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Comissões de influenciador — payout MANUAL (admin marca como pago)
-- ----------------------------------------------------------------------------
CREATE TABLE commissions (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    promo_code_id   BIGINT UNSIGNED NOT NULL,
    order_id        BIGINT UNSIGNED NOT NULL,
    amount_usd      DECIMAL(10,2) NOT NULL,         -- order.amount_usd × commission_percent
    status          ENUM('pending','paid','cancelled') NOT NULL DEFAULT 'pending',
    paid_at         TIMESTAMP NULL,
    notes           VARCHAR(255) NULL,
    created_at      TIMESTAMP NULL,
    updated_at      TIMESTAMP NULL,
    UNIQUE KEY uq_commission_order (order_id),      -- 1 comissão por encomenda
    FOREIGN KEY (promo_code_id) REFERENCES promo_codes(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_commissions_status (status, promo_code_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Wallets — 1 por (user, modelo). balance em USD, é CACHE do ledger.
-- ----------------------------------------------------------------------------
CREATE TABLE wallets (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT UNSIGNED NOT NULL,
    ai_model_id     BIGINT UNSIGNED NOT NULL,
    balance         DECIMAL(14,4) NOT NULL DEFAULT 0,   -- USD
    created_at      TIMESTAMP NULL,
    updated_at      TIMESTAMP NULL,
    UNIQUE KEY uq_wallet_user_model (user_id, ai_model_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (ai_model_id) REFERENCES ai_models(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Lotes de crédito (expiração 12 meses, consumo FIFO)
-- order_id NULL = crédito manual/bónus do admin
-- ----------------------------------------------------------------------------
CREATE TABLE credit_lots (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    wallet_id       BIGINT UNSIGNED NOT NULL,
    order_id        BIGINT UNSIGNED NULL,
    amount          DECIMAL(14,4) NOT NULL,         -- USD creditado
    remaining       DECIMAL(14,4) NOT NULL,         -- ainda por consumir
    expires_at      TIMESTAMP NOT NULL,             -- created + 12 meses
    created_at      TIMESTAMP NULL,
    FOREIGN KEY (wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_lots_fifo (wallet_id, expires_at),
    INDEX idx_lots_expiry (expires_at, remaining)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- LEDGER — IMUTÁVEL (append-only). Nunca UPDATE, nunca DELETE.
-- amount: positivo = crédito, negativo = débito. Sempre em USD.
-- type:
--   purchase         compra de pacote
--   debit            consumo de IA (referencia usage_logs)
--   conversion_out   saída para conversão entre modelos
--   conversion_in    entrada de conversão (já com taxa deduzida)
--   expiration       expiração de lote (12 meses)
--   admin_adjustment ajuste manual do fundador
--   bonus            crédito oferecido (campanhas, partners)
-- ----------------------------------------------------------------------------
CREATE TABLE ledger_entries (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    wallet_id           BIGINT UNSIGNED NOT NULL,
    type                ENUM('purchase','debit','conversion_out','conversion_in',
                             'expiration','admin_adjustment','bonus') NOT NULL,
    amount              DECIMAL(14,4) NOT NULL,         -- signed, USD
    balance_after       DECIMAL(14,4) NOT NULL,         -- USD; auditoria rápida
    credit_lot_id       BIGINT UNSIGNED NULL,           -- lote afetado (quando aplicável)
    reference_type      VARCHAR(50) NULL,               -- 'order' | 'usage_log' | 'conversion' | null
    reference_id        BIGINT UNSIGNED NULL,
    idempotency_key     VARCHAR(100) NULL UNIQUE,       -- débitos/requests: nunca duplicar
    meta                JSON NULL,
    created_at          TIMESTAMP NULL,                 -- SEM updated_at: imutável
    FOREIGN KEY (wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (credit_lot_id) REFERENCES credit_lots(id),
    INDEX idx_ledger_wallet (wallet_id, created_at),
    INDEX idx_ledger_type (type, created_at)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Conversões entre modelos (dormente até haver 2º modelo ativo)
-- ----------------------------------------------------------------------------
CREATE TABLE conversions (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT UNSIGNED NOT NULL,
    from_wallet_id  BIGINT UNSIGNED NOT NULL,
    to_wallet_id    BIGINT UNSIGNED NOT NULL,
    amount          DECIMAL(14,4) NOT NULL,         -- USD retirado da origem
    fee_percent     DECIMAL(5,2) NOT NULL,
    fee_amount      DECIMAL(14,4) NOT NULL,         -- USD retido
    credited_amount DECIMAL(14,4) NOT NULL,         -- USD creditado no destino
    created_at      TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (from_wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (to_wallet_id) REFERENCES wallets(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Usage logs — 1 linha por request de IA (custo real vs. cobrado)
-- charged_usd = cost_usd × margin_multiplier do modelo no momento do request
-- PURGE: linhas > 90 dias agregam em usage_daily e são apagadas (job mensal)
-- ----------------------------------------------------------------------------
CREATE TABLE usage_logs (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id             BIGINT UNSIGNED NOT NULL,
    ai_model_id         BIGINT UNSIGNED NOT NULL,
    request_id          VARCHAR(100) NOT NULL UNIQUE,   -- idempotência do débito
    prompt_tokens       INT UNSIGNED NOT NULL DEFAULT 0,
    completion_tokens   INT UNSIGNED NOT NULL DEFAULT 0,
    cost_usd            DECIMAL(16,8) NOT NULL,         -- custo real OpenRouter
    charged_usd         DECIMAL(16,8) NOT NULL,         -- débito ao cliente (custo × margem)
    ledger_entry_id     BIGINT UNSIGNED NULL,
    status              ENUM('ok','error') NOT NULL DEFAULT 'ok',
    created_at          TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (ai_model_id) REFERENCES ai_models(id),
    FOREIGN KEY (ledger_entry_id) REFERENCES ledger_entries(id),
    INDEX idx_usage_user_date (user_id, created_at),
    INDEX idx_usage_purge (created_at)
) ENGINE=InnoDB;

CREATE TABLE usage_daily (
    user_id             BIGINT UNSIGNED NOT NULL,
    ai_model_id         BIGINT UNSIGNED NOT NULL,
    date                DATE NOT NULL,
    prompt_tokens       BIGINT UNSIGNED NOT NULL DEFAULT 0,
    completion_tokens   BIGINT UNSIGNED NOT NULL DEFAULT 0,
    cost_usd            DECIMAL(14,6) NOT NULL DEFAULT 0,
    charged_usd         DECIMAL(14,6) NOT NULL DEFAULT 0,
    requests_count      INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, ai_model_id, date),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (ai_model_id) REFERENCES ai_models(id)
) ENGINE=InnoDB;

-- ============================================================================
-- DADOS INICIAIS (seed mínimo — nomes e mapeamentos editáveis no admin)
-- v3 (28-07-2026): marca Qolari. UM modelo ativo no lançamento.
-- Modelo chefe: **Kimi K2.7 Code** (Moonshot, via OpenRouter) — multimodal,
-- especialista em coding agentic. O benchmark interno da Fase 1 serve de
-- CONFIRMAÇÃO; trocar de modelo é config no admin.
-- Alavanca futura: modo híbrido (DeepSeek V4 Pro texto + visão barata) por config.
-- ATENÇÃO: confirmar o provider_model_id exato na OpenRouter antes de
-- ir para produção (muda com o tempo; é config, não código).
-- ============================================================================
INSERT INTO ai_models (slug, display_name, description, provider, provider_model_id, margin_multiplier, is_active, sort_order) VALUES
    ('qolari', 'Qolari',          'Modelo chefe: Kimi K2.7 Code (multimodal) — escolhido 27-07-2026', 'openrouter', 'moonshotai/kimi-k2.7-code', 3.00, 1, 1),
    ('max',    'Qolari Max',      '(reserva) multimodal',            'openrouter', 'moonshotai/kimi-k2-0905-preview', 3.00, 0, 2),
    ('medium', 'Qolari Medium',   '(reserva) económico — DeepSeek V4 Pro', 'openrouter', 'deepseek/deepseek-v4-pro',  3.00, 0, 3);

INSERT INTO settings (`key`, value, is_secret) VALUES
    ('conversion_fee_percent', '10', 0),
    ('credit_expiry_months', '12', 0),
    ('default_margin_multiplier', '3.00', 0),
    ('influencer_default_percent', '15', 0),
    ('site_name', 'Qolari', 0),
    ('support_email', 'qolari@qolari.com', 0),
    ('openrouter_api_key', NULL, 1),
    ('stripe_secret_key', NULL, 1),
    ('stripe_webhook_secret', NULL, 1);
