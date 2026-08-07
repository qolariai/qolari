"use client";

import { useTranslations, useLocale } from "next-intl";
import { Link, usePathname, useRouter } from "@/i18n/navigation";
import { useAuth } from "@/lib/auth";
import { buttonVariants } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { cn } from "@/lib/utils";
import {
  LayoutDashboard,
  ShoppingCart,
  Activity,
  Key,
  Settings,
  LogOut,
  Zap,
  Menu,
  X,
  MessageSquare,
} from "lucide-react";
import { useState, useEffect } from "react";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const t = useTranslations();
  const locale = useLocale();
  const pathname = usePathname();
  const router = useRouter();
  const { user, isLoading, isAuthenticated, logout } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  // Redirect se nao autenticado
  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push("/login");
    }
  }, [isLoading, isAuthenticated, router]);

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <p className="text-muted-foreground">{t("common.loading")}</p>
      </div>
    );
  }

  if (!isAuthenticated) {
    return null;
  }

  const navItems = [
    { href: "/dashboard", icon: LayoutDashboard, label: t("nav.overview") },
    { href: "/dashboard/chat", icon: MessageSquare, label: t("nav.chat") },
    { href: "/dashboard/orders", icon: ShoppingCart, label: t("nav.orders") },
    { href: "/dashboard/usage", icon: Activity, label: t("nav.usage") },
    { href: "/dashboard/tokens", icon: Key, label: t("nav.tokens") },
    { href: "/dashboard/settings", icon: Settings, label: t("nav.settings") },
  ];

  const handleLogout = async () => {
    await logout();
    router.push("/");
  };

  const switchLocale = (newLocale: string) => {
    router.replace(pathname, { locale: newLocale });
  };

  return (
    <div className="flex min-h-screen">
      {/* Sidebar - desktop */}
      <aside className="hidden lg:flex lg:w-64 lg:flex-col lg:border-r lg:bg-muted/30">
        <div className="flex h-16 items-center gap-2 px-6 border-b">
          <Zap className="h-5 w-5 text-primary" />
          <span className="font-bold">{t("common.appName")}</span>
        </div>
        <nav className="flex-1 space-y-1 p-4">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors",
                pathname === item.href
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:bg-muted hover:text-foreground"
              )}
            >
              <item.icon className="h-4 w-4" />
              {item.label}
            </Link>
          ))}
        </nav>
        <div className="border-t p-4 space-y-2">
          <div className="flex items-center gap-1 text-xs mb-2">
            <button
              onClick={() => switchLocale("pt")}
              className={cn("px-2 py-1 rounded", locale === "pt" ? "bg-primary text-primary-foreground" : "text-muted-foreground")}
            >
              PT
            </button>
            <button
              onClick={() => switchLocale("en")}
              className={cn("px-2 py-1 rounded", locale === "en" ? "bg-primary text-primary-foreground" : "text-muted-foreground")}
            >
              EN
            </button>
          </div>
          <button
            onClick={handleLogout}
            className="flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
          >
            <LogOut className="h-4 w-4" />
            {t("common.logout")}
          </button>
        </div>
      </aside>

      {/* Mobile sidebar overlay */}
      {sidebarOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div className="fixed inset-0 bg-black/50" onClick={() => setSidebarOpen(false)} />
          <aside className="fixed left-0 top-0 h-full w-64 bg-background border-r p-4">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-2">
                <Zap className="h-5 w-5 text-primary" />
                <span className="font-bold">{t("common.appName")}</span>
              </div>
              <button onClick={() => setSidebarOpen(false)}>
                <X className="h-5 w-5" />
              </button>
            </div>
            <nav className="space-y-1">
              {navItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setSidebarOpen(false)}
                  className={cn(
                    "flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors",
                    pathname === item.href
                      ? "bg-primary text-primary-foreground"
                      : "text-muted-foreground hover:bg-muted hover:text-foreground"
                  )}
                >
                  <item.icon className="h-4 w-4" />
                  {item.label}
                </Link>
              ))}
            </nav>
            <Separator className="my-4" />
            <button
              onClick={handleLogout}
              className="flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm text-muted-foreground hover:bg-muted hover:text-foreground"
            >
              <LogOut className="h-4 w-4" />
              {t("common.logout")}
            </button>
          </aside>
        </div>
      )}

      {/* Main content */}
      <div className="flex-1 flex flex-col">
        {/* Mobile header */}
        <header className="flex h-16 items-center gap-4 border-b px-4 lg:hidden">
          <button onClick={() => setSidebarOpen(true)}>
            <Menu className="h-5 w-5" />
          </button>
          <div className="flex items-center gap-2">
            <Zap className="h-5 w-5 text-primary" />
            <span className="font-bold">{t("common.appName")}</span>
          </div>
        </header>

        <main className="flex-1 p-6 lg:p-8">{children}</main>
      </div>
    </div>
  );
}
