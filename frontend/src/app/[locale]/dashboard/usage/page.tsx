"use client";

import { useTranslations } from "next-intl";
import { useQuery } from "@tanstack/react-query";
import { api, type UsageLog, type Paginated } from "@/lib/api";
import { Card, CardContent } from "@/components/ui/card";
import { buttonVariants } from "@/components/ui/button";
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

export default function UsagePage() {
  const t = useTranslations();
  const [page, setPage] = useState(1);

  const { data, isLoading } = useQuery({
    queryKey: ["usage", page],
    queryFn: () => api.get<Paginated<UsageLog>>(`/v1/usage?page=${page}`),
  });

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">{t("usage.title")}</h1>

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
                    <TableHead>{t("usage.date")}</TableHead>
                    <TableHead>{t("usage.model")}</TableHead>
                    <TableHead className="text-right">{t("usage.promptTokens")}</TableHead>
                    <TableHead className="text-right">{t("usage.completionTokens")}</TableHead>
                    <TableHead className="text-right">{t("usage.cost")}</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {data.data.map((log) => (
                    <TableRow key={log.id}>
                      <TableCell className="text-sm">
                        {new Date(log.created_at).toLocaleString()}
                      </TableCell>
                      <TableCell className="text-sm">
                        {log.ai_model?.display_name ?? "—"}
                      </TableCell>
                      <TableCell className="text-right text-sm">
                        {log.prompt_tokens.toLocaleString()}
                      </TableCell>
                      <TableCell className="text-right text-sm">
                        {log.completion_tokens.toLocaleString()}
                      </TableCell>
                      <TableCell className="text-right text-sm font-medium">
                        ${parseFloat(log.charged_usd).toFixed(6)}
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
              {t("usage.empty")}
            </p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
