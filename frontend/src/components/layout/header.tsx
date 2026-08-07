"use client";

import { useTranslations } from "next-intl";
import { Link, usePathname } from "@/i18n/navigation";
import { useAuth } from "@/lib/auth";
import { buttonVariants } from "@/components/ui/button";
import { Zap, Menu, X } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";

export function Header() {
  const t = useTranslations();
  const pathname = usePathname();
  const { isAuthenticated } = useAuth();
  const [mobileOpen, setMobileOpen] = useState(false);

  const navLinks = [
    { href: "/#features", label: t("nav.features") },
    { href: "/pricing", label: t("nav.pricing") },
    { href: "/pricing#chat-plans", label: t("nav.chat") },
    { href: "/marketplace", label: t("nav.marketplace") },
    { href: "/#faq", label: t("nav.faq") },
  ];

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4">
        <Link href="/" className="flex items-center gap-2 font-bold text-xl">
          <Zap className="h-6 w-6 text-primary" />
          {t("common.appName")}
        </Link>

        {/* Desktop nav */}
        <nav className="hidden md:flex items-center gap-6">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="hidden md:flex items-center gap-3">
          {isAuthenticated ? (
            <Link href="/dashboard" className={cn(buttonVariants())}>
              {t("common.dashboard")}
            </Link>
          ) : (
            <>
              <Link href="/login" className={cn(buttonVariants({ variant: "ghost" }))}>
                {t("common.login")}
              </Link>
              <Link href="/register" className={cn(buttonVariants())}>
                {t("common.register")}
              </Link>
            </>
          )}
        </div>

        {/* Mobile menu button */}
        <button
          className="md:hidden p-2"
          onClick={() => setMobileOpen(!mobileOpen)}
        >
          {mobileOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </button>
      </div>

      {/* Mobile nav */}
      {mobileOpen && (
        <div className="md:hidden border-t px-4 py-4 space-y-3">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="block text-sm text-muted-foreground hover:text-foreground"
              onClick={() => setMobileOpen(false)}
            >
              {link.label}
            </Link>
          ))}
          <div className="flex gap-3 pt-2">
            {isAuthenticated ? (
              <Link href="/dashboard" className={cn(buttonVariants(), "w-full")}>
                {t("common.dashboard")}
              </Link>
            ) : (
              <>
                <Link href="/login" className={cn(buttonVariants({ variant: "outline" }), "flex-1")}>
                  {t("common.login")}
                </Link>
                <Link href="/register" className={cn(buttonVariants(), "flex-1")}>
                  {t("common.register")}
                </Link>
              </>
            )}
          </div>
        </div>
      )}
    </header>
  );
}
