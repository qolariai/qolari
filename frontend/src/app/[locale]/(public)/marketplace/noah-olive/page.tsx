"use client";

import { useTranslations } from "next-intl";
import { Link } from "@/i18n/navigation";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import {
  HeartHandshake,
  ArrowLeft,
  ExternalLink,
  Download,
  FolderGit2,
  Radio,
  ShieldCheck,
  MapPin,
  Camera,
  CreditCard,
  Star,
  MessageSquare,
  CalendarCheck,
  Siren,
  BookOpen,
  Smartphone,
  Server,
  Database,
  Globe,
} from "lucide-react";

const features = [
  { icon: Radio, key: "feature1" },
  { icon: ShieldCheck, key: "feature2" },
  { icon: MapPin, key: "feature3" },
  { icon: Camera, key: "feature4" },
  { icon: CreditCard, key: "feature5" },
  { icon: Star, key: "feature6" },
  { icon: MessageSquare, key: "feature7" },
  { icon: CalendarCheck, key: "feature8" },
  { icon: Siren, key: "feature9" },
  { icon: BookOpen, key: "feature10" },
] as const;

const techStack = ["Laravel 12", "Next.js 14", "React Native (Expo)", "MySQL 8", "Stripe", "Docker"];

export default function NoahOlivePage() {
  const t = useTranslations("marketplace");
  const td = useTranslations("marketplace.noaholive");

  return (
    <div className="py-12">
      <div className="mx-auto max-w-6xl px-4">
        {/* Back link */}
        <Link
          href="/marketplace"
          className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground mb-8"
        >
          <ArrowLeft className="h-4 w-4" />
          {t("title")}
        </Link>

        {/* Hero */}
        <div className="mb-16">
          <div className="flex items-center gap-4 mb-6">
            <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-rose-500 to-purple-500 text-white">
              <HeartHandshake className="h-8 w-8" />
            </div>
            <div>
              <h1 className="text-3xl font-bold">{td("name")}</h1>
              <p className="text-muted-foreground">{td("tagline")}</p>
            </div>
          </div>
          <p className="text-lg text-muted-foreground max-w-3xl leading-relaxed">
            {td("description")}
          </p>
          <div className="flex flex-wrap gap-2 mt-6">
            {techStack.map((tech) => (
              <Badge key={tech} variant="secondary">
                {tech}
              </Badge>
            ))}
          </div>
        </div>

        {/* Features */}
        <section className="mb-16">
          <h2 className="text-2xl font-bold mb-8">{t("features")}</h2>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {features.map(({ icon: Icon, key }) => (
              <div
                key={key}
                className="flex items-start gap-3 rounded-lg border p-4"
              >
                <Icon className="h-5 w-5 text-rose-500 mt-0.5 shrink-0" />
                <span className="text-sm">{td(key)}</span>
              </div>
            ))}
          </div>
        </section>

        {/* Architecture */}
        <section className="mb-16">
          <h2 className="text-2xl font-bold mb-8">{t("architecture")}</h2>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            {[
              { icon: Server, label: "Laravel API", desc: "PHP 8.2 + Sanctum" },
              { icon: Globe, label: "Next.js Web", desc: "App Router + Tailwind" },
              { icon: Smartphone, label: "Expo Mobile", desc: "React Native" },
              { icon: Database, label: "MySQL 8 + Docker", desc: "Self-hosted Hetzner" },
            ].map(({ icon: Icon, label, desc }) => (
              <Card key={label}>
                <CardContent className="pt-6 text-center">
                  <Icon className="h-8 w-8 mx-auto mb-3 text-rose-500" />
                  <p className="font-medium text-sm">{label}</p>
                  <p className="text-xs text-muted-foreground">{desc}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </section>

        {/* Demo + Downloads */}
        <section className="mb-16">
          <h2 className="text-2xl font-bold mb-8">{t("demoLive")}</h2>
          <div className="grid gap-6 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">{t("website")}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <p className="text-sm text-muted-foreground">
                  {t("credentials")}: demo@noaholive.com / password
                </p>
                <a
                  href="https://care.qolari.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className={cn(buttonVariants(), "w-full")}
                >
                  <ExternalLink className="mr-2 h-4 w-4" />
                  care.qolari.com
                </a>
                <a
                  href="https://care-api.qolari.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className={cn(buttonVariants({ variant: "outline" }), "w-full")}
                >
                  <ExternalLink className="mr-2 h-4 w-4" />
                  API (care-api.qolari.com)
                </a>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">{t("downloadApk")}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <a
                  href="/marketplace/noaholive/noaholive.apk"
                  className={cn(buttonVariants({ variant: "outline" }), "w-full")}
                >
                  <Download className="mr-2 h-4 w-4" />
                  {td("mobileApp")} (Android)
                </a>
                <p className="text-xs text-muted-foreground">
                  Built with Expo (React Native). iOS via TestFlight.
                </p>
              </CardContent>
            </Card>
          </div>
        </section>

        {/* Repository */}
        <section className="mb-16">
          <h2 className="text-2xl font-bold mb-8">{t("viewRepo")}</h2>
          <Card>
            <CardContent className="pt-6">
              <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                <div>
                  <p className="font-medium">Noah & Olive — Full Source Code</p>
                  <p className="text-sm text-muted-foreground">
                    Monorepo Turborepo: Laravel API + Next.js web + Expo mobile + Docker Compose
                  </p>
                </div>
                <a
                  href="https://github.com/qolariai/noah-olive"
                  target="_blank"
                  rel="noopener noreferrer"
                  className={cn(buttonVariants({ variant: "outline" }))}
                >
                  <FolderGit2 className="mr-2 h-4 w-4" />
                  GitHub
                </a>
              </div>
            </CardContent>
          </Card>
        </section>

        {/* Roadmap */}
        <section className="mb-16">
          <h2 className="text-2xl font-bold mb-8">{t("roadmap")}</h2>
          <div className="space-y-3">
            {["roadmap1", "roadmap2", "roadmap3", "roadmap4"].map((key, i) => (
              <div key={key} className="flex items-center gap-3">
                <span className="flex h-7 w-7 items-center justify-center rounded-full bg-rose-100 text-xs font-bold text-rose-700">
                  {i + 1}
                </span>
                <span className="text-sm">{td(key)}</span>
              </div>
            ))}
          </div>
        </section>

        {/* CTA */}
        <section className="rounded-2xl border bg-gradient-to-br from-rose-50 to-purple-50 dark:from-rose-950/20 dark:to-purple-950/20 p-8 sm:p-12 text-center">
          <h2 className="text-2xl font-bold mb-3">{t("investCta")}</h2>
          <p className="text-muted-foreground max-w-xl mx-auto mb-6">
            {t("investDesc")}
          </p>
          <a
            href="mailto:invest@qolari.com"
            className={cn(buttonVariants({ size: "lg" }))}
          >
            {t("contactUs")}
          </a>
        </section>
      </div>
    </div>
  );
}
