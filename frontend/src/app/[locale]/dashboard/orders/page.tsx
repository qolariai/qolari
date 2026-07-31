"use client";

import { useTranslations } from "next-intl";
import { useQuery } from "@tanstack/react-query";
import { api, type Order, type Paginated } from "@/lib/api";
import { Link } from "@/i18n/navigation";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { cn } from "@/lib/utils";
import { useState } from "react";

export default function OrdersPage() {
  const t = useTranslations();
  const [page, setPage] = useState(1);

  const { data, isLoading } = useQuery({
    queryKey: ["orders", page],
    queryFn: () => api.get<Paginated<Order>>(`/v1/orders?page=${page}`),
  });

  const statusVariant = (status: string) => {
    switch (status) {
      case "paid":
        return "default";
      case "pending":
        return "secondary";
      default:
        return "destructive";
    }
  };

  const statusLabel = (status: string) => {
    switch (status) {
      case "paid":
        return t("orders.statusPaid");
      case "pending":
        return t("orders.statusPending");
      case "failed":
        return t("orders.statusFailed");
      case "refunded":
        return t("orders.statusRefunded");
      default:
        return status;
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">{t("orders.title")}</h1>
        <Link href="/pricing" className={cn(buttonVariants())}>
          {t("dashboard.newPurchase")}
        </Link>
      </div>

      <Card>
        <CardContent className="pt-6">
          {isLoading ? (
            <p className="text-center text-muted-foreground py-8">
              {t("common.loading")}
            </p>
          ) : data && data.data.length > 0 ? (
            <>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>{t("orders.date")}</TableHead>
                    <TableHead>{t("orders.product")}</TableHead>
                    <TableHead className="text-right">{t("orders.amount")}</TableHead>
                    <TableHead>{t("orders.currency")}</TableHead>
                    <TableHead>{t("orders.status")}</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {data.data.map((order) => (
                    <TableRow key={order.id}>
                      <TableCell className="text-sm">
                        {new Date(order.created_at).toLocaleDateString()}
                      </TableCell>
                      <TableCell className="text-sm">
                        {order.product?.name ?? "—"}
                      </TableCell>
                      <TableCell className="text-right text-sm">
                        {parseFloat(order.amount).toFixed(2)}
                      </TableCell>
                      <TableCell className="text-sm">{order.currency}</TableCell>
                      <TableCell>
                        <Badge variant={statusVariant(order.status)}>
                          {statusLabel(order.status)}
                        </Badge>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>

              {/* Pagination */}
              {data.last_page > 1 && (
                <div className="flex items-center justify-center gap-2 mt-4">
                  <button
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    disabled={page === 1}
                    className={cn(buttonVariants({ variant: "outline", size: "sm" }))}
                  >
                    {t("common.previous")}
                  </button>
                  <span className="text-sm text-muted-foreground">
                    {data.current_page} / {data.last_page}
                  </span>
                  <button
                    onClick={() => setPage((p) => Math.min(data.last_page, p + 1))}
                    disabled={page === data.last_page}
                    className={cn(buttonVariants({ variant: "outline", size: "sm" }))}
                  >
                    {t("common.next")}
                  </button>
                </div>
              )}
            </>
          ) : (
            <p className="text-center text-muted-foreground py-8">
              {t("orders.empty")}
            </p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
