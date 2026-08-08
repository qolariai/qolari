"use client";

import { useTranslations } from "next-intl";
import { Link } from "@/i18n/navigation";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { Monitor, Layers, MessageSquare, CreditCard, Download } from "lucide-react";
import { cn } from "@/lib/utils";

export default function LandingPage() {
  const t = useTranslations();

  const features = [
    { icon: Monitor, title: t("landing.feature1Title"), desc: t("landing.feature1Desc") },
    { icon: Layers, title: t("landing.feature2Title"), desc: t("landing.feature2Desc") },
    { icon: MessageSquare, title: t("landing.feature3Title"), desc: t("landing.feature3Desc") },
    { icon: CreditCard, title: t("landing.feature4Title"), desc: t("landing.feature4Desc") },
  ];

  const faqs = [
    { q: t("landing.faq1Q"), a: t("landing.faq1A") },
    { q: t("landing.faq2Q"), a: t("landing.faq2A") },
    { q: t("landing.faq3Q"), a: t("landing.faq3A") },
    { q: t("landing.faq4Q"), a: t("landing.faq4A") },
  ];

  return (
    <div>
      {/* Hero */}
      <section className="relative overflow-hidden py-24 md:py-32">
        <div className="mx-auto max-w-6xl px-4 text-center">
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl md:text-6xl">
            {t("landing.heroTitle")}
          </h1>
          <p className="mx-auto mt-6 max-w-2xl text-lg text-muted-foreground">
            {t("landing.heroSubtitle")}
          </p>
          <div className="mt-10 flex items-center justify-center gap-4">
            <Link href="/register" className={cn(buttonVariants({ size: "lg" }))}>
              {t("landing.heroCta")}
            </Link>
            <Link href="/pricing" className={cn(buttonVariants({ size: "lg", variant: "outline" }))}>
              {t("landing.heroSecondary")}
            </Link>
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="py-20 bg-muted/50">
        <div className="mx-auto max-w-6xl px-4">
          <h2 className="text-3xl font-bold text-center mb-12">
            {t("landing.featuresTitle")}
          </h2>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {features.map((feature, i) => (
              <Card key={i} className="border-0 shadow-sm">
                <CardHeader>
                  <feature.icon className="h-10 w-10 text-primary mb-2" />
                  <CardTitle className="text-base">{feature.title}</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-sm text-muted-foreground">{feature.desc}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Download IDE */}
      <section id="download" className="py-20 bg-muted/50">
        <div className="mx-auto max-w-6xl px-4 text-center">
          <h2 className="text-3xl font-bold mb-4">{t("landing.downloadTitle")}</h2>
          <p className="mx-auto max-w-2xl text-muted-foreground mb-8">{t("landing.downloadSubtitle")}</p>
          <div className="flex items-center justify-center gap-4">
            <a href="/downloads/qolari-ide-win-x64.exe" className={cn(buttonVariants({ size: "lg" }))}>
              <Download className="mr-2 h-4 w-4" />
              {t("landing.downloadWin")}
            </a>
            <a href="/downloads/qolari-ide-linux-x64.tar.gz" className={cn(buttonVariants({ size: "lg", variant: "outline" }))}>
              <Download className="mr-2 h-4 w-4" />
              {t("landing.downloadLinux")}
            </a>
            <a href="/downloads/qolari-code.vsix" className={cn(buttonVariants({ size: "lg", variant: "outline" }))}>
              <Download className="mr-2 h-4 w-4" />
              {t("landing.downloadExt")}
            </a>
          </div>
        </div>
      </section>

      {/* Pricing CTA */}
      <section className="py-20">
        <div className="mx-auto max-w-6xl px-4 text-center">
          <h2 className="text-3xl font-bold mb-4">{t("landing.pricingTitle")}</h2>
          <p className="text-muted-foreground mb-8">{t("landing.pricingSubtitle")}</p>
          <Link href="/pricing" className={cn(buttonVariants({ size: "lg", variant: "outline" }))}>
            {t("landing.viewAllPricing")}
          </Link>
        </div>
      </section>

      {/* FAQ */}
      <section id="faq" className="py-20 bg-muted/50">
        <div className="mx-auto max-w-3xl px-4">
          <h2 className="text-3xl font-bold text-center mb-12">
            {t("landing.faqTitle")}
          </h2>
          <Accordion className="w-full">
            {faqs.map((faq, i) => (
              <AccordionItem key={i} value={`item-${i}`}>
                <AccordionTrigger>{faq.q}</AccordionTrigger>
                <AccordionContent>{faq.a}</AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </div>
      </section>
    </div>
  );
}
