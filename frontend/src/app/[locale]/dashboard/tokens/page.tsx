"use client";

import { useTranslations } from "next-intl";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api, type ApiToken } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { buttonVariants } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
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
import { toast } from "sonner";
import { Copy, Check, Plus, Trash2 } from "lucide-react";

export default function TokensPage() {
  const t = useTranslations();
  const queryClient = useQueryClient();
  const [newTokenName, setNewTokenName] = useState("");
  const [createdToken, setCreatedToken] = useState<string | null>(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  const { data: tokens, isLoading } = useQuery({
    queryKey: ["tokens"],
    queryFn: () => api.get<ApiToken[]>("/v1/tokens"),
  });

  const createMutation = useMutation({
    mutationFn: (name: string) =>
      api.post<{ id: number; name: string; token: string }>("/v1/tokens", { name }),
    onSuccess: (data) => {
      setCreatedToken(data.token);
      setNewTokenName("");
      queryClient.invalidateQueries({ queryKey: ["tokens"] });
    },
  });

  const revokeMutation = useMutation({
    mutationFn: (id: number) => api.delete(`/v1/tokens/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tokens"] });
      toast.success(t("tokens.revoke") + " ✓");
    },
  });

  const handleCreate = (e: React.FormEvent) => {
    e.preventDefault();
    if (newTokenName.trim()) {
      createMutation.mutate(newTokenName.trim());
    }
  };

  const copyToken = () => {
    if (createdToken) {
      navigator.clipboard.writeText(createdToken);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">{t("tokens.title")}</h1>
          <p className="text-muted-foreground text-sm mt-1">{t("tokens.subtitle")}</p>
        </div>
        <Dialog open={dialogOpen} onOpenChange={(open) => { setDialogOpen(open); if (!open) setCreatedToken(null); }}>
          <DialogTrigger className={cn(buttonVariants())}>
            <Plus className="h-4 w-4 mr-1" />
            {t("tokens.create")}
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>
                {createdToken ? t("tokens.newTokenTitle") : t("tokens.create")}
              </DialogTitle>
            </DialogHeader>
            {createdToken ? (
              <div className="space-y-4">
                <p className="text-sm text-muted-foreground">{t("tokens.newTokenWarning")}</p>
                <div className="flex items-center gap-2">
                  <code className="flex-1 rounded-md bg-muted p-3 text-sm break-all">
                    {createdToken}
                  </code>
                  <button
                    onClick={copyToken}
                    className={cn(buttonVariants({ variant: "outline", size: "icon" }))}
                  >
                    {copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
                  </button>
                </div>
              </div>
            ) : (
              <form onSubmit={handleCreate} className="space-y-4">
                <div>
                  <Input
                    placeholder={t("tokens.namePlaceholder")}
                    value={newTokenName}
                    onChange={(e) => setNewTokenName(e.target.value)}
                    required
                  />
                </div>
                <button
                  type="submit"
                  disabled={createMutation.isPending}
                  className={cn(buttonVariants(), "w-full")}
                >
                  {createMutation.isPending ? "..." : t("tokens.create")}
                </button>
              </form>
            )}
          </DialogContent>
        </Dialog>
      </div>

      <Card>
        <CardContent className="pt-6">
          {isLoading ? (
            <p className="text-center text-muted-foreground py-8">{t("common.loading")}</p>
          ) : tokens && tokens.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>{t("tokens.name")}</TableHead>
                  <TableHead>{t("tokens.created")}</TableHead>
                  <TableHead>{t("tokens.lastUsed")}</TableHead>
                  <TableHead className="text-right"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {tokens.map((token) => (
                  <TableRow key={token.id}>
                    <TableCell className="font-medium text-sm">{token.name}</TableCell>
                    <TableCell className="text-sm">
                      {new Date(token.created_at).toLocaleDateString()}
                    </TableCell>
                    <TableCell className="text-sm">
                      {token.last_used_at
                        ? new Date(token.last_used_at).toLocaleDateString()
                        : t("tokens.never")}
                    </TableCell>
                    <TableCell className="text-right">
                      <AlertDialog>
                        <AlertDialogTrigger className={cn(buttonVariants({ variant: "destructive", size: "icon-xs" }))}>
                          <Trash2 className="h-3 w-3" />
                        </AlertDialogTrigger>
                        <AlertDialogContent>
                          <AlertDialogHeader>
                            <AlertDialogTitle>{t("tokens.revoke")}</AlertDialogTitle>
                            <AlertDialogDescription>
                              {t("tokens.revokeConfirm")}
                            </AlertDialogDescription>
                          </AlertDialogHeader>
                          <AlertDialogFooter>
                            <AlertDialogCancel>{t("common.cancel")}</AlertDialogCancel>
                            <AlertDialogAction
                              onClick={() => revokeMutation.mutate(token.id)}
                            >
                              {t("common.confirm")}
                            </AlertDialogAction>
                          </AlertDialogFooter>
                        </AlertDialogContent>
                      </AlertDialog>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <p className="text-center text-muted-foreground py-8">{t("tokens.empty")}</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
