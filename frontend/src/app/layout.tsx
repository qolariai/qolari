import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Qolari",
  description: "Prepaid AI credits, no surprises.",
  icons: {
    icon: "/favicon.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return children;
}
