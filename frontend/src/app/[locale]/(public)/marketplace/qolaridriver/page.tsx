"use client";

import { useTranslations } from "next-intl";
import { Link } from "@/i18n/navigation";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import {
  Car,
  ArrowLeft,
  ExternalLink,
  Download,
  FolderGit2,
  MapPin,
  Wallet,
  Bell,
  BarChart3,
  MessageSquare,
  Bike,
  Radio,
  Package,
  DollarSign,
  Smartphone,
  Server,
  Database,
  Cloud,
} from "lucide-react";

const features = [
  { icon: Radio, key: "feature1" },
  { icon: MapPin, key: "feature2" },
  { icon: DollarSign, key: "feature3" },
  { icon: Package, key: "feature4" },
  { icon: MapPin, key: "feature5" },
  { icon: Wallet, key: "feature6" },
  { icon: Bell, key: "feature7" },
  { icon: BarChart3, key: "feature8" },
  { icon: Bike, key: "feature9" },
  { icon: MessageSquare, key: "feature10" },
] as const;

const techStack = ["Laravel 10", "Flutter", "MySQL 8", "Firebase", "WebSocket", "Google Maps"];

export default function QolariDriverPage() {
  const t = useTranslations("marketplace");
  const td = useTranslations("marketplace.qolaridriver");

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
            <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-blue-600 to-cyan-500 text-white">
              <Car className="h-8 w-8" />
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
                <Icon className="h-5 w-5 text-blue-600 mt-0.5 shrink-0" />
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
              { icon: Server, label: "Laravel API", desc: "PHP 8.2 + REST" },
              { icon: Smartphone, label: "Flutter Apps", desc: "User + Driver" },
              { icon: Database, label: "MySQL 8", desc: "Relational DB" },
              { icon: Cloud, label: "Firebase", desc: "Push + Realtime" },
            ].map(({ icon: Icon, label, desc }) => (
              <Card key={label}>
                <CardContent className="pt-6 text-center">
                  <Icon className="h-8 w-8 mx-auto mb-3 text-blue-600" />
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
                <CardTitle className="text-lg">{t("adminPanel")}</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground mb-4">
                  {t("credentials")}: admin@qolari.com / password
                </p>
                <a
                  href="https://driver.qolari.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className={cn(buttonVariants(), "w-full")}
                >
                  <ExternalLink className="mr-2 h-4 w-4" />
                  driver.qolari.com
                </a>
              </CardContent>
            </Card>
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">{t("downloadApk")}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <a
                  href="/marketplace/qolaridriver/qolaridriver-user.apk"
                  className={cn(buttonVariants({ variant: "outline" }), "w-full")}
                >
                  <Download className="mr-2 h-4 w-4" />
                  {td("userApp")} (Android)
                </a>
                <a
                  href="/marketplace/qolaridriver/qolaridriver-driver.apk"
                  className={cn(buttonVariants({ variant: "outline" }), "w-full")}
                >
                  <Download className="mr-2 h-4 w-4" />
                  {td("driverApp")} (Android)
                </a>
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
                  <p className="font-medium">QolariDriver — Full Source Code</p>
                  <p className="text-sm text-muted-foreground">
                    Laravel admin panel + Flutter apps (User & Driver) + Docker Compose
                  </p>
                </div>
                <a
                  href="https://github.com/qolariai/qolaridriver"
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
                <span className="flex h-7 w-7 items-center justify-center rounded-full bg-blue-100 text-xs font-bold text-blue-700">
                  {i + 1}
                </span>
                <span className="text-sm">{td(key)}</span>
              </div>
            ))}
          </div>
        </section>

        {/* CTA */}
        <section className="rounded-2xl border bg-gradient-to-br from-blue-50 to-cyan-50 dark:from-blue-950/20 dark:to-cyan-950/20 p-8 sm:p-12 text-center">
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
