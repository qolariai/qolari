"use client";

import { useTranslations } from "next-intl";
import { useQuery } from "@tanstack/react-query";
import { api, type Product } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { Link } from "@/i18n/navigation";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { useState } from "react";
import { Check } from "lucide-react";

const currencies = ["EUR", "USD", "GBP"] as const;

export default function PricingPage() {
  const t = useTranslations();
  const { isAuthenticated } = useAuth();
  const [currency, setCurrency] = useState<string>("EUR");

  const { data: products, isLoading } = useQuery({
    queryKey: ["products"],
    queryFn: () => api.get<Product[]>("/v1/products"),
  });

  const getPrice = (product: Product) => {
    const price = product.prices?.find((p) => p.currency === currency);
    return price ? parseFloat(price.price) : null;
  };

  return (
    <div className="py-16">
      <div className="mx-auto max-w-6xl px-4">
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold mb-4">{t("pricing.title")}</h1>
          <p className="text-muted-foreground text-lg">{t("pricing.subtitle")}</p>
        </div>

        {/* Currency toggle */}
        <div className="flex justify-center mb-10">
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

        {/* Products grid */}
        {isLoading ? (
          <div className="text-center text-muted-foreground">
            {t("common.loading")}
          </div>
        ) : (
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {products?.map((product, i) => {
              const price = getPrice(product);
              return (
                <Card key={product.id} className={cn("relative flex flex-col", i === 1 && "border-primary shadow-md")}>
                  {i === 1 && (
                    <Badge className="absolute -top-3 left-1/2 -translate-x-1/2">
                      {t("pricing.popular")}
                    </Badge>
                  )}
                  <CardHeader className="text-center">
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
                        <BuyButton productId={product.id} currency={currency} label={t("pricing.buy")} />
                      ) : (
                        <Link href="/register" className={cn(buttonVariants(), "w-full")}>
                          {t("pricing.buy")}
                        </Link>
                      )}
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

function BuyButton({ productId, currency, label }: { productId: number; currency: string; label: string }) {
  const [loading, setLoading] = useState(false);

  const handleBuy = async () => {
    setLoading(true);
    try {
      const data = await api.post<{ checkout_url: string }>("/v1/checkout", {
        product_id: productId,
        currency,
      });
      window.location.href = data.checkout_url;
    } catch {
      setLoading(false);
    }
  };

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
