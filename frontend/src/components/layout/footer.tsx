"use client";

import { useTranslations, useLocale } from "next-intl";
import { Link } from "@/i18n/navigation";
import { Zap } from "lucide-react";
import { usePathname, useRouter } from "@/i18n/navigation";

export function Footer() {
  const t = useTranslations();
  const locale = useLocale();
  const pathname = usePathname();
  const router = useRouter();

  const switchLocale = (newLocale: string) => {
    router.replace(pathname, { locale: newLocale });
  };

  return (
    <footer className="border-t py-8">
      <div className="mx-auto max-w-6xl px-4">
        <div className="flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <Zap className="h-4 w-4" />
            <span>
              &copy; {new Date().getFullYear()} {t("common.appName")}.{" "}
              {t("landing.footerRights")}
            </span>
          </div>

          <div className="flex items-center gap-4 text-sm text-muted-foreground">
            <Link href="/terms" className="hover:text-foreground transition-colors">
              {t("landing.terms")}
            </Link>
            <Link href="/privacy" className="hover:text-foreground transition-colors">
              {t("landing.privacy")}
            </Link>
          </div>

          {/* Language switcher */}
          <div className="flex items-center gap-1 text-sm">
            <button
              onClick={() => switchLocale("pt")}
              className={`px-2 py-1 rounded ${
                locale === "pt"
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              PT
            </button>
            <button
              onClick={() => switchLocale("en")}
              className={`px-2 py-1 rounded ${
                locale === "en"
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              EN
            </button>
          </div>
        </div>
      </div>
    </footer>
  );
}
