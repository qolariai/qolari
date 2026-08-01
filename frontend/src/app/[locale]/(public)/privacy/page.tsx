"use client";

import { useTranslations } from "next-intl";
import { Link } from "@/i18n/navigation";
import { ArrowLeft } from "lucide-react";

export default function PrivacyPage() {
  const t = useTranslations();

  return (
    <div className="py-16">
      <div className="mx-auto max-w-3xl px-4">
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground mb-8"
        >
          <ArrowLeft className="h-4 w-4" />
          {t("common.back")}
        </Link>

        <h1 className="text-3xl font-bold mb-8">{t("landing.privacy")}</h1>

        <div className="prose prose-sm max-w-none space-y-6 text-muted-foreground">
          <section>
            <h2 className="text-xl font-semibold text-foreground">1. Data We Collect</h2>
            <p>
              We collect: account information (name, email), usage data (API requests, token
              consumption), and payment information (processed by Stripe — we do not store card
              numbers).
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">2. How We Use Your Data</h2>
            <p>
              To operate the Service, process payments, provide support, improve the platform,
              and comply with legal obligations. We do not sell your personal data.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">3. Data Storage &amp; Security</h2>
            <p>
              Data is stored on EU-based infrastructure (Hetzner, Germany). We use encryption
              in transit (TLS) and at rest. Backups are performed daily with 30-day retention.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">4. Third Parties</h2>
            <p>
              We share data only with: Stripe (payments), OpenRouter (AI model routing — no
              personal data, only request content), and Hetzner (hosting). Each is bound by
              their own privacy policies and GDPR compliance.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">5. Your Rights (GDPR)</h2>
            <p>
              You have the right to access, rectify, erase, restrict, or port your personal
              data. Contact us to exercise these rights.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">6. Cookies</h2>
            <p>
              We use essential cookies for authentication and session management. No advertising
              or tracking cookies are used.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">7. Contact</h2>
            <p>
              Data protection inquiries:{" "}
              <a href="mailto:qolari@qolari.com" className="text-primary hover:underline">
                qolari@qolari.com
              </a>
            </p>
          </section>
        </div>
      </div>
    </div>
  );
}
