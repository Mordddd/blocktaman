import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const jsonHeaders = { "content-type": "application/json; charset=utf-8" };
const datePattern = /^\d{4}-\d{2}-\d{2}$/;
const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function reply(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), { status, headers: jsonHeaders });
}

function isUtcDate(value: unknown): value is string {
  if (typeof value !== "string" || !datePattern.test(value)) return false;
  const parsed = new Date(`${value}T00:00:00.000Z`);
  return !Number.isNaN(parsed.getTime()) && parsed.toISOString().slice(0, 10) === value;
}

function isBoundedInteger(value: unknown, maximum: number): value is number {
  return Number.isSafeInteger(value) && value >= 0 && value <= maximum;
}

function validateDailyCompletion(body: Record<string, unknown>): string | null {
  if (!isUtcDate(body.challengeDate)) return "challengeDate must be an ISO calendar date";
  if (!isBoundedInteger(body.score, 1_000_000_000)) return "score must be a non-negative integer";
  if (!isBoundedInteger(body.moveCount, 10_000)) return "moveCount must be a non-negative integer";
  if (body.clientSubmissionId !== undefined &&
      (typeof body.clientSubmissionId !== "string" || !uuidPattern.test(body.clientSubmissionId))) {
    return "clientSubmissionId must be a UUID";
  }
  return null;
}

function validatePurchase(body: Record<string, unknown>): string | null {
  if (body.platform !== "google_play" && body.platform !== "app_store") {
    return "platform must be google_play or app_store";
  }
  if (typeof body.transactionId !== "string" || body.transactionId.length < 1 || body.transactionId.length > 256) {
    return "transactionId must be a non-empty string of at most 256 characters";
  }
  return null;
}

Deno.serve(async (request) => {
  if (request.method !== "POST") return reply(405, { error: "method_not_allowed" });
  if (Number(request.headers.get("content-length") ?? 0) > 4096) {
    return reply(413, { error: "payload_too_large" });
  }

  const url = new URL(request.url);
  const validator = url.pathname.endsWith("/daily-completion")
    ? validateDailyCompletion
    : url.pathname.endsWith("/purchase")
    ? validatePurchase
    : null;
  if (validator === null) return reply(404, { error: "endpoint_not_found" });

  const authorization = request.headers.get("authorization");
  const token = authorization?.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!token) return reply(401, { error: "missing_bearer_token" });

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !supabaseAnonKey) {
    return reply(503, { error: "supabase_auth_not_configured" });
  }
  const authClient = createClient(supabaseUrl, supabaseAnonKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data: { user }, error: authError } = await authClient.auth.getUser(token);
  if (authError || !user) return reply(401, { error: "invalid_bearer_token" });

  let body: unknown;
  try {
    body = await request.json();
  } catch (_) {
    return reply(400, { error: "invalid_json" });
  }
  if (body === null || Array.isArray(body) || typeof body !== "object") {
    return reply(400, { error: "request_body_must_be_an_object" });
  }

  const issue = validator(body as Record<string, unknown>);
  if (issue) return reply(400, { error: "invalid_request", message: issue });

  // ponytail: validation only; add trusted replay/receipt verification before any write.
  return reply(501, { error: "validation_not_implemented" });
});
