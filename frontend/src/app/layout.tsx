import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Qolari",
  description: "Prepaid AI credits, no surprises.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return children;
}
