"use client";

import { useTranslations } from "next-intl";
import { useQuery } from "@tanstack/react-query";
import {
  api,
  type AiModel,
  type Product,
  type SubscriptionPlan,
} from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { Link } from "@/i18n/navigation";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";
import { useEffect, useMemo, useState } from "react";
import { Check } from "lucide-react";
import Cookies from "js-cookie";

const currencies = ["EUR", "USD", "GBP", "AOA"] as const;

interface TierGroup {
  model: AiModel;
  items: Product[];
}

export default function PricingPage() {
  const t = useTranslations();
  const { isAuthenticated, user } = useAuth();
  const [currency, setCurrencyState] = useState<string>("EUR");
  // Marca escolha manual — a sugestão geo/conta não sobrepõe a escolha do utilizador
  const [currencyTouched, setCurrencyTouched] = useState(false);
  const setCurrency = (c: string) => {
    setCurrencyState(c);
    setCurrencyTouched(true);
  };

  // Geo-pricing: visitantes anónimos recebem sugestão por IP (AO → AOA)
  const { data: geo } = useQuery({
    queryKey: ["geo"],
    queryFn: () =>
      api.get<{ country: string | null; suggested_currency: string | null }>(
        "/v1/geo"
      ),
    enabled: !isAuthenticated,
    staleTime: Infinity,
    retry: false,
  });

  // Moeda inicial: país da conta (AO → AOA) → moeda preferida → IP
  useEffect(() => {
    if (currencyTouched) return;
    if (user?.country === "AO") {
      setCurrencyState("AOA");
    } else if (user?.preferred_currency) {
      setCurrencyState(user.preferred_currency);
    } else if (geo?.suggested_currency) {
      setCurrencyState(geo.suggested_currency);
    }
  }, [user, geo, currencyTouched]);

  // Código de influenciador: pré-preenchido do cookie qolari_ref (?ref=)
  // (lazy init — evita setState síncrono num effect; js-cookie devolve
  // undefined fora do browser)
  const [promoInput, setPromoInput] = useState(
    () => (typeof window !== "undefined" ? Cookies.get("qolari_ref") ?? "" : "")
  );
  const [promoCode, setPromoCode] = useState(""); // valor com debounce

  // Debounce de 500ms antes de validar contra a API
  useEffect(() => {
    const timer = setTimeout(() => setPromoCode(promoInput.trim()), 500);
    return () => clearTimeout(timer);
  }, [promoInput]);

  const { data: products, isLoading } = useQuery({
    queryKey: ["products"],
    queryFn: () => api.get<Product[]>("/v1/products"),
  });

  // Planos de subscrição do Qolari Chat (endpoint público, sem IDs Stripe)
  const { data: chatPlans } = useQuery({
    queryKey: ["subscription-plans"],
    queryFn: () => api.get<SubscriptionPlan[]>("/v1/subscription-plans"),
  });

  const promoValidation = useQuery({
    queryKey: ["promo-code-validation", promoCode],
    queryFn: () =>
      api.get<{ valid: boolean }>(`/v1/promo-codes/${encodeURIComponent(promoCode)}`),
    enabled: promoCode.length > 0,
    staleTime: 60_000,
  });

  const promoValid = promoCode.length > 0 && promoValidation.data?.valid === true;
  const promoInvalid =
    promoCode.length > 0 && promoValidation.data && !promoValidation.data.valid;

  // Agrupar produtos por tier (ai_model), ordenado pelo sort_order do modelo
  const tierGroups = useMemo<TierGroup[]>(() => {
    if (!products) return [];
    const map = new Map<number, TierGroup>();
    for (const product of products) {
      if (!product.ai_model) continue;
      const group = map.get(product.ai_model.id) ?? { model: product.ai_model, items: [] };
      group.items.push(product);
      map.set(product.ai_model.id, group);
    }
    return [...map.values()].sort(
      (a, b) => (a.model.sort_order ?? 0) - (b.model.sort_order ?? 0)
    );
  }, [products]);

  const getPrice = (product: Product) => {
    const price = product.prices?.find((p) => p.currency === currency);
    return price ? parseFloat(price.price) : null;
  };

  const renderCard = (product: Product) => {
    const price = getPrice(product);
    return (
      <Card
        key={product.id}
        className={cn("relative flex flex-col", product.is_featured && "border-primary shadow-md")}
      >
        {product.is_featured && (
          <Badge className="absolute -top-3 left-1/2 -translate-x-1/2">
            {t("pricing.popular")}
          </Badge>
        )}
        <CardHeader className="text-center">
          {product.ai_model && (
            <div className="flex justify-center mb-1">
              <Badge variant="secondary">{product.ai_model.display_name}</Badge>
            </div>
          )}
          <CardTitle>{product.name}</CardTitle>
          <div className="mt-2">
            <span className="text-3xl font-bold">
              {price !== null ? `${price.toFixed(2)}` : "—"}
            </span>
            <span className="text-muted-foreground ml-1">{currency}</span>
          </div>
          <p className="text-sm text-muted-foreground mt-1">
            {product.credits_usd} {t("pricing.credits")} (USD)
          </p>
        </CardHeader>
        <CardContent className="flex-1 flex flex-col">
          {product.description && (
            <p className="text-sm text-muted-foreground mb-4">
              {product.description}
            </p>
          )}
          <ul className="space-y-2 text-sm mb-6">
            <li className="flex items-center gap-2">
              <Check className="h-4 w-4 text-primary" />
              {product.credits_usd} USD {t("pricing.credits")}
            </li>
            <li className="flex items-center gap-2">
              <Check className="h-4 w-4 text-primary" />
              {t("pricing.oneTime")}
            </li>
          </ul>
          <div className="mt-auto">
            {isAuthenticated ? (
              <BuyButton
                productId={product.id}
                currency={currency}
                promoCode={promoValid ? promoCode : undefined}
                label={t("pricing.buy")}
              />
            ) : (
              <Link href="/register" className={cn(buttonVariants(), "w-full")}>
                {t("pricing.buy")}
              </Link>
            )}
          </div>
        </CardContent>
      </Card>
    );
  };

  const getPlanPrice = (plan: SubscriptionPlan) => {
    const price = plan.prices?.find((p) => p.currency === currency);
    return price ? parseFloat(price.amount) : null;
  };

  const renderChatCard = (plan: SubscriptionPlan) => {
    const price = getPlanPrice(plan);
    return (
      <Card key={plan.id} className="relative flex flex-col">
        <CardHeader className="text-center">
          <div className="flex justify-center mb-1">
            <Badge variant="secondary">{t("common.appName")} Chat</Badge>
          </div>
          <CardTitle>{plan.name}</CardTitle>
          <div className="mt-2">
            <span className="text-3xl font-bold">
              {price !== null ? `${price.toFixed(2)}` : "—"}
            </span>
            <span className="text-muted-foreground ml-1">
              {currency}
              {plan.period_days === 30
                ? t("pricing.perMonth")
                : t("pricing.perDays", { days: plan.period_days })}
            </span>
          </div>
          <p className="text-sm text-muted-foreground mt-1">
            {plan.token_limit_human} {t("pricing.tokens")}
          </p>
        </CardHeader>
        <CardContent className="flex-1 flex flex-col">
          <ul className="space-y-2 text-sm mb-6">
            <li className="flex items-center gap-2">
              <Check className="h-4 w-4 text-primary" />
              {t("pricing.chatTokens", { tokens: plan.token_limit_human })}
            </li>
            <li className="flex items-center gap-2">
              <Check className="h-4 w-4 text-primary" />
              {t("pricing.chatStreaming")}
            </li>
          </ul>
          <div className="mt-auto">
            {isAuthenticated ? (
              <SubscribeButton
                planId={plan.id}
                currency={currency}
                disabled={price === null}
                label={t("pricing.subscribe")}
              />
            ) : (
              <Link href="/register" className={cn(buttonVariants(), "w-full")}>
                {t("pricing.subscribe")}
              </Link>
            )}
          </div>
        </CardContent>
      </Card>
    );
  };

  return (
    <div className="py-16">
      <div className="mx-auto max-w-6xl px-4">
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold mb-4">{t("pricing.title")}</h1>
          <p className="text-muted-foreground text-lg">{t("pricing.subtitle")}</p>
        </div>

        {/* Currency toggle */}
        <div className="flex justify-center mb-6">
          <div className="inline-flex items-center rounded-lg border p-1">
            {currencies.map((c) => (
              <button
                key={c}
                onClick={() => setCurrency(c)}
                className={cn(
                  "px-4 py-1.5 text-sm rounded-md transition-colors",
                  currency === c
                    ? "bg-primary text-primary-foreground"
                    : "text-muted-foreground hover:text-foreground"
                )}
              >
                {c}
              </button>
            ))}
          </div>
        </div>

        {/* Código de influenciador (opcional) */}
        <div className="mx-auto max-w-xs mb-12 space-y-1.5">
          <Label htmlFor="promoCode" className="text-xs text-muted-foreground">
            {t("pricing.influencerCode")}
          </Label>
          <Input
            id="promoCode"
            value={promoInput}
            onChange={(e) => setPromoInput(e.target.value)}
            placeholder={t("pricing.influencerCodePlaceholder")}
            className={cn(
              promoValid && "border-green-500 focus-visible:ring-green-500/30",
              promoInvalid && "border-destructive focus-visible:ring-destructive/30"
            )}
          />
          {promoCode.length > 0 && promoValidation.isFetching && (
            <p className="text-xs text-muted-foreground">{t("pricing.influencerCodeChecking")}</p>
          )}
          {promoValid && (
            <p className="text-xs text-green-600">{t("pricing.influencerCodeValid")}</p>
          )}
          {promoInvalid && (
            <p className="text-xs text-destructive">{t("pricing.influencerCodeInvalid")}</p>
          )}
        </div>

        {/* Products grid (agrupado por tier quando há mais que um) */}
        {isLoading ? (
          <div className="text-center text-muted-foreground">
            {t("common.loading")}
          </div>
        ) : tierGroups.length > 1 ? (
          <div className="space-y-12">
            {tierGroups.map((group) => (
              <section key={group.model.id}>
                <h2 className="text-2xl font-semibold text-center mb-6">
                  {group.model.display_name}
                </h2>
                <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
                  {group.items.map(renderCard)}
                </div>
              </section>
            ))}
          </div>
        ) : (
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {tierGroups.flatMap((group) => group.items).map(renderCard)}
          </div>
        )}

        {/* Qolari Chat — planos de subscrição (secção pública) */}
        {chatPlans && chatPlans.length > 0 && (
          <section id="chat-plans" className="mt-20 scroll-mt-20">
            <div className="text-center mb-8">
              <h2 className="text-3xl font-bold mb-2">
                {t("pricing.chatPlansTitle")}
              </h2>
              <p className="text-muted-foreground">
                {t("pricing.chatPlansSubtitle")}
              </p>
            </div>
            <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              {chatPlans.map(renderChatCard)}
            </div>
          </section>
        )}
      </div>
    </div>
  );
}

function BuyButton({
  productId,
  currency,
  promoCode,
  label,
}: {
  productId: number;
  currency: string;
  promoCode?: string;
  label: string;
}) {
  const t = useTranslations();
  const [loading, setLoading] = useState(false);

  const handleBuy = async () => {
    setLoading(true);
    try {
      const data = await api.post<{ checkout_url: string }>("/v1/checkout", {
        product_id: productId,
        currency,
        promo_code: promoCode,
      });
      window.location.href = data.checkout_url;
    } catch {
      setLoading(false);
    }
  };

  if (currency === "AOA") {
    return (
      <MulticaixaButton
        productId={productId}
        promoCode={promoCode}
        label={t("pricing.mcxPay")}
      />
    );
  }

  return (
    <button
      onClick={handleBuy}
      disabled={loading}
      className={cn(buttonVariants(), "w-full")}
    >
      {loading ? "..." : label}
    </button>
  );
}

/**
 * Fluxo AOA / Multicaixa Express (AppyPay): o cliente introduz o
 * telemóvel angolano, recebe o pedido na app Multicaixa Express e
 * confirmamos via polling ao estado da order (o webhook credita).
 */
function MulticaixaButton({
  productId,
  promoCode,
  label,
}: {
  productId: number;
  promoCode?: string;
  label: string;
}) {
  const t = useTranslations();
  const [phone, setPhone] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [pendingOrderId, setPendingOrderId] = useState<number | null>(null);

  // Polling ao estado da order enquanto o cliente confirma na app MCX
  useEffect(() => {
    if (pendingOrderId === null) return;

    const startedAt = Date.now();
    const interval = setInterval(async () => {
      try {
        const orders = await api.get<{ data: { id: number; status: string }[] }>(
          "/v1/orders"
        );
        const order = orders.data.find((o) => o.id === pendingOrderId);
        if (order?.status === "paid") {
          clearInterval(interval);
          window.location.href = "/dashboard?checkout=success";
        } else if (order?.status === "failed") {
          clearInterval(interval);
          setPendingOrderId(null);
          setLoading(false);
          setError(t("pricing.mcxFailed"));
        } else if (Date.now() - startedAt > 150_000) {
          clearInterval(interval);
          setPendingOrderId(null);
          setLoading(false);
          setError(t("pricing.mcxFailed"));
        }
      } catch {
        // Falha transitória de rede — continua a tentar
      }
    }, 5000);

    return () => clearInterval(interval);
  }, [pendingOrderId, t]);

  const handlePay = async () => {
    setError(null);
    const digits = phone.replace(/\D/g, "").replace(/^244/, "");
    if (!/^9\d{8}$/.test(digits)) {
      setError(t("pricing.mcxInvalidPhone"));
      return;
    }

    setLoading(true);
    try {
      const data = await api.post<{ order_id: number; status: string }>(
        "/v1/checkout",
        {
          product_id: productId,
          currency: "AOA",
          phone: digits,
          promo_code: promoCode,
        }
      );
      if (data.status === "Failed") {
        setLoading(false);
        setError(t("pricing.mcxFailed"));
        return;
      }
      setPendingOrderId(data.order_id);
    } catch {
      setLoading(false);
      setError(t("pricing.mcxFailed"));
    }
  };

  if (pendingOrderId !== null) {
    return (
      <div className="rounded-md border border-primary/40 bg-primary/5 p-3 text-center space-y-1">
        <p className="text-sm font-medium">{t("pricing.mcxPendingTitle")}</p>
        <p className="text-xs text-muted-foreground">
          {t("pricing.mcxPendingBody")}
        </p>
        <p className="text-xs text-muted-foreground animate-pulse">
          {t("pricing.mcxWaiting")}
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      <Input
        type="tel"
        inputMode="numeric"
        value={phone}
        onChange={(e) => setPhone(e.target.value)}
        placeholder={t("pricing.mcxPhonePlaceholder")}
        aria-label={t("pricing.mcxPhoneLabel")}
      />
      <button
        onClick={handlePay}
        disabled={loading}
        className={cn(buttonVariants(), "w-full")}
      >
        {loading ? "..." : label}
      </button>
      {error && (
        <p className="text-xs text-destructive text-center">{error}</p>
      )}
    </div>
  );
}

function SubscribeButton({
  planId,
  currency,
  disabled,
  label,
}: {
  planId: number;
  currency: string;
  disabled?: boolean;
  label: string;
}) {
  const t = useTranslations();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(false);

  const handleSubscribe = async () => {
    setLoading(true);
    setError(false);
    try {
      const data = await api.post<{ checkout_url: string }>(
        "/v1/checkout/subscription",
        { plan_id: planId, currency }
      );
      window.location.href = data.checkout_url;
    } catch {
      setError(true);
      setLoading(false);
    }
  };

  return (
    <div className="space-y-1.5">
      <button
        onClick={handleSubscribe}
        disabled={loading || disabled}
        className={cn(buttonVariants(), "w-full")}
      >
        {loading ? "..." : label}
      </button>
      {error && (
        <p className="text-xs text-destructive text-center">
          {t("pricing.subscribeError")}
        </p>
      )}
    </div>
  );
}
