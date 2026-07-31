"use client";

import { useTranslations } from "next-intl";
import { useQuery } from "@tanstack/react-query";
import { api, type Wallet, type UsageSummary, type UsageLog } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { Link } from "@/i18n/navigation";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { cn } from "@/lib/utils";
import { DollarSign, TrendingUp } from "lucide-react";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip as RechartsTooltip,
  ResponsiveContainer,
} from "recharts";

export default function DashboardPage() {
  const t = useTranslations();
  const { user } = useAuth();

  const { data: wallets } = useQuery({
    queryKey: ["wallets"],
    queryFn: () => api.get<Wallet[]>("/v1/wallets"),
  });

  const { data: usageSummary } = useQuery({
    queryKey: ["usage-summary"],
    queryFn: () => api.get<UsageSummary[]>("/v1/usage/summary"),
  });

  const { data: recentUsage } = useQuery({
    queryKey: ["usage-recent"],
    queryFn: () => api.get<{ data: UsageLog[] }>("/v1/usage"),
  });

  const totalBalance = wallets?.reduce(
    (sum, w) => sum + parseFloat(w.balance),
    0
  ) ?? 0;

  const chartData = usageSummary?.map((d) => ({
    date: new Date(d.date).toLocaleDateString(),
    total: parseFloat(d.total_usd),
    requests: d.requests,
  })) ?? [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">
          {t("dashboard.welcome", { name: user?.name ?? "" })}
        </h1>
        <Link href="/pricing" className={cn(buttonVariants())}>
          {t("dashboard.newPurchase")}
        </Link>
      </div>

      {/* Balance cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              {t("dashboard.totalBalance")}
            </CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">${totalBalance.toFixed(4)}</div>
          </CardContent>
        </Card>

        {wallets?.map((wallet) => (
          <Card key={wallet.id}>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                {wallet.ai_model?.display_name ?? "Model"}
              </CardTitle>
              <TrendingUp className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                ${parseFloat(wallet.balance).toFixed(4)}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Usage chart */}
      <Card>
        <CardHeader>
          <CardTitle>{t("dashboard.usageLast30")}</CardTitle>
        </CardHeader>
        <CardContent>
          {chartData.length > 0 ? (
            <ResponsiveContainer width="100%" height={250}>
              <AreaChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="date" className="text-xs" tick={{ fontSize: 12 }} />
                <YAxis className="text-xs" tick={{ fontSize: 12 }} />
                <RechartsTooltip />
                <Area
                  type="monotone"
                  dataKey="total"
                  stroke="var(--primary)"
                  fill="var(--primary)"
                  fillOpacity={0.1}
                />
              </AreaChart>
            </ResponsiveContainer>
          ) : (
            <p className="text-center text-muted-foreground py-8">
              {t("dashboard.noUsage")}
            </p>
          )}
        </CardContent>
      </Card>

      {/* Recent requests */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>{t("dashboard.recentRequests")}</CardTitle>
          <Link
            href="/dashboard/usage"
            className="text-sm text-primary hover:underline"
          >
            {t("dashboard.viewAll")}
          </Link>
        </CardHeader>
        <CardContent>
          {recentUsage?.data && recentUsage.data.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>{t("usage.date")}</TableHead>
                  <TableHead>{t("usage.model")}</TableHead>
                  <TableHead className="text-right">{t("usage.cost")}</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {recentUsage.data.slice(0, 5).map((log) => (
                  <TableRow key={log.id}>
                    <TableCell className="text-sm">
                      {new Date(log.created_at).toLocaleString()}
                    </TableCell>
                    <TableCell className="text-sm">
                      {log.ai_model?.display_name ?? "—"}
                    </TableCell>
                    <TableCell className="text-right text-sm">
                      ${parseFloat(log.charged_usd).toFixed(6)}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <p className="text-center text-muted-foreground py-4">
              {t("dashboard.noUsage")}
            </p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
