"use client";

import { useTranslations } from "next-intl";
import { Link } from "@/i18n/navigation";
import { ArrowLeft } from "lucide-react";

export default function TermsPage() {
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

        <h1 className="text-3xl font-bold mb-8">{t("landing.terms")}</h1>

        <div className="prose prose-sm max-w-none space-y-6 text-muted-foreground">
          <section>
            <h2 className="text-xl font-semibold text-foreground">1. Acceptance of Terms</h2>
            <p>
              By accessing or using Qolari (&quot;the Service&quot;), you agree to be bound by these
              Terms of Service. If you do not agree, do not use the Service.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">2. Description of Service</h2>
            <p>
              Qolari provides prepaid AI credit packages that allow users to access AI models
              through a unified API and desktop IDE. Credits are purchased in advance and debited
              per usage.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">3. Credits &amp; Billing</h2>
            <p>
              Credits are denominated in USD and do not expire before 12 months from purchase.
              All sales are final unless required by law. Pricing and margins are determined by
              Qolari and may change with notice.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">4. Acceptable Use</h2>
            <p>
              You agree not to misuse the Service, including but not limited to: attempting to
              reverse-engineer the platform, reselling credits without authorization, or using
              the Service for illegal purposes.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">5. Limitation of Liability</h2>
            <p>
              The Service is provided &quot;as is&quot; without warranties of any kind. Qolari shall
              not be liable for any indirect, incidental, or consequential damages arising from
              your use of the Service.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">6. Changes</h2>
            <p>
              We reserve the right to modify these terms at any time. Continued use of the
              Service after changes constitutes acceptance of the updated terms.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground">7. Contact</h2>
            <p>
              Questions about these terms:{" "}
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
