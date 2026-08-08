"use client";

import { useTranslations } from "next-intl";
import { useState } from "react";
import { api } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { buttonVariants } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";
import { cn } from "@/lib/utils";
import { toast } from "sonner";

export default function SettingsPage() {
  const t = useTranslations();
  const { user, refreshUser } = useAuth();

  const [currency, setCurrency] = useState(user?.preferred_currency ?? "EUR");
  const [language, setLanguage] = useState(user?.language ?? "pt");
  const [saving, setSaving] = useState(false);

  const [newPassword, setNewPassword] = useState("");
  const [confirmNewPassword, setConfirmNewPassword] = useState("");
  const [savingPassword, setSavingPassword] = useState(false);

  const handleSaveProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await api.put("/v1/profile", {
        preferred_currency: currency,
        language,
      });
      await refreshUser();
      toast.success(t("settings.saved"));
    } catch {
      toast.error("Error");
    } finally {
      setSaving(false);
    }
  };

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    if (newPassword !== confirmNewPassword) {
      toast.error(t("auth.passwordMismatch"));
      return;
    }
    setSavingPassword(true);
    try {
      await api.put("/v1/profile", {
        password: newPassword,
        password_confirmation: confirmNewPassword,
      });
      setNewPassword("");
      setConfirmNewPassword("");
      toast.success(t("settings.passwordChanged"));
    } catch {
      toast.error("Error");
    } finally {
      setSavingPassword(false);
    }
  };

  return (
    <div className="space-y-6 max-w-2xl">
      <h1 className="text-2xl font-bold">{t("settings.title")}</h1>

      {/* Profile settings */}
      <Card>
        <CardHeader>
          <CardTitle>{t("settings.profile")}</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSaveProfile} className="space-y-4">
            <div className="space-y-2">
              <Label>{t("auth.email")}</Label>
              <Input value={user?.email ?? ""} disabled />
            </div>
            <div className="space-y-2">
              <Label>{t("auth.name")}</Label>
              <Input value={user?.name ?? ""} disabled />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="currency">{t("settings.preferredCurrency")}</Label>
                <select
                  id="currency"
                  value={currency}
                  onChange={(e) => setCurrency(e.target.value)}
                  className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                >
                  <option value="EUR">EUR</option>
                  <option value="USD">USD</option>
                  <option value="GBP">GBP</option>
                  <option value="AOA">AOA</option>
                </select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="language">{t("settings.language")}</Label>
                <select
                  id="language"
                  value={language}
                  onChange={(e) => setLanguage(e.target.value)}
                  className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                >
                  <option value="pt">Portugues</option>
                  <option value="en">English</option>
                </select>
              </div>
            </div>
            <button
              type="submit"
              disabled={saving}
              className={cn(buttonVariants())}
            >
              {saving ? "..." : t("common.save")}
            </button>
          </form>
        </CardContent>
      </Card>

      {/* Change password */}
      <Card>
        <CardHeader>
          <CardTitle>{t("settings.changePassword")}</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleChangePassword} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="newPassword">{t("settings.newPassword")}</Label>
              <Input
                id="newPassword"
                type="password"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                required
                minLength={8}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="confirmNewPassword">{t("settings.confirmNewPassword")}</Label>
              <Input
                id="confirmNewPassword"
                type="password"
                value={confirmNewPassword}
                onChange={(e) => setConfirmNewPassword(e.target.value)}
                required
                minLength={8}
              />
            </div>
            <button
              type="submit"
              disabled={savingPassword}
              className={cn(buttonVariants())}
            >
              {savingPassword ? "..." : t("common.save")}
            </button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
