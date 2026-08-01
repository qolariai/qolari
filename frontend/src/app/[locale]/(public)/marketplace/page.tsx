"use client";

import { useTranslations } from "next-intl";
import { Link } from "@/i18n/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { Car, ShoppingBag, HeartHandshake, ArrowRight, Layers } from "lucide-react";

const projects = [
  {
    id: "qolaridriver",
    href: "/marketplace/qolaridriver",
    icon: Car,
    color: "from-blue-600 to-cyan-500",
    badge: "Laravel + Flutter",
  },
  {
    id: "qolarifood",
    href: "/marketplace/qolarifood",
    icon: ShoppingBag,
    color: "from-orange-600 to-green-500",
    badge: "Laravel + Flutter + React",
  },
  {
    id: "noaholive",
    href: "/marketplace/noah-olive",
    icon: HeartHandshake,
    color: "from-rose-500 to-purple-500",
    badge: "Laravel + Next.js + Expo",
  },
] as const;

export default function MarketplacePage() {
  const t = useTranslations("marketplace");

  return (
    <div className="py-16">
      <div className="mx-auto max-w-6xl px-4">
        {/* Hero */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 rounded-full border px-4 py-1.5 text-sm text-muted-foreground mb-6">
            <Layers className="h-4 w-4" />
            {t("title")}
          </div>
          <h1 className="text-4xl font-bold mb-4 sm:text-5xl">{t("title")}</h1>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            {t("subtitle")}
          </p>
        </div>

        {/* Project Cards */}
        <div className="grid gap-8 md:grid-cols-3 mb-20">
          {projects.map((project) => {
            const Icon = project.icon;
            return (
              <Card
                key={project.id}
                className="group relative overflow-hidden transition-all hover:shadow-lg hover:-translate-y-1"
              >
                <div
                  className={cn(
                    "absolute inset-x-0 top-0 h-1.5 bg-gradient-to-r",
                    project.color
                  )}
                />
                <CardHeader className="pt-8 text-center">
                  <div
                    className={cn(
                      "mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br text-white",
                      project.color
                    )}
                  >
                    <Icon className="h-8 w-8" />
                  </div>
                  <CardTitle className="text-xl">
                    {t(`${project.id}.name`)}
                  </CardTitle>
                  <p className="text-sm text-muted-foreground">
                    {t(`${project.id}.tagline`)}
                  </p>
                </CardHeader>
                <CardContent className="text-center">
                  <Badge variant="secondary" className="mb-6">
                    {project.badge}
                  </Badge>
                  <div>
                    <Link
                      href={project.href}
                      className={cn(buttonVariants({ variant: "outline" }), "w-full group-hover:bg-primary group-hover:text-primary-foreground transition-colors")}
                    >
                      {t("explore")}
                      <ArrowRight className="ml-2 h-4 w-4" />
                    </Link>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>

        {/* Ecosystem Section */}
        <div className="rounded-2xl border bg-muted/30 p-8 sm:p-12 text-center">
          <h2 className="text-2xl font-bold mb-4">{t("ecosystemTitle")}</h2>
          <p className="text-muted-foreground max-w-3xl mx-auto leading-relaxed">
            {t("ecosystemDesc")}
          </p>
          <div className="mt-8 flex flex-wrap justify-center gap-4">
            {projects.map((project) => (
              <div
                key={project.id}
                className="flex items-center gap-2 rounded-full border bg-background px-4 py-2 text-sm"
              >
                <project.icon className="h-4 w-4" />
                {t(`${project.id}.name`)}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
