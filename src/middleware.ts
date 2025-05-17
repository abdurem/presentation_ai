import { NextResponse } from "next/server";
import { type NextRequest } from "next/server";

export async function middleware(request: NextRequest) {
  // Always redirect from root to /presentation
  if (request.nextUrl.pathname === "/") {
    return NextResponse.redirect(new URL("/presentation", request.url));
  }
  // No authentication or consent checks, allow all routes
  return NextResponse.next();
}

// No protected routes, all are public
export const config = {
  matcher: ["/(.*)"],
};
