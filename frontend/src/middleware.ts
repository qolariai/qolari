import createMiddleware from "next-intl/middleware";
import { NextRequest, NextResponse } from "next/server";
import { routing } from "./i18n/routing";

const intlMiddleware = createMiddleware(routing);

export default function middleware(request: NextRequest) {
  // Tracking influenciadores: ?ref=CODIGO → cookie 30 dias
  const ref = request.nextUrl.searchParams.get("ref");
  const response = intlMiddleware(request) as NextResponse;

  if (ref) {
    response.cookies.set("qolari_ref", ref, {
      maxAge: 60 * 60 * 24 * 30, // 30 dias
      path: "/",
      sameSite: "lax",
    });
  }

  return response;
}

export const config = {
  // Match todos os paths exceto API, _next, ficheiros estaticos
  matcher: ["/", "/(pt|en)/:path*", "/((?!api|_next|_vercel|.*\\..*).*)"],
};
