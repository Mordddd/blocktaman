"""Limited static regression checks; this does not execute SQL or deploy a function."""
from pathlib import Path

root = Path(__file__).resolve().parents[2]
migration = (root / "supabase/migrations/202609280001_initial_backend.sql").read_text(encoding="utf-8")
function = (root / "supabase/functions/validation-api/index.ts").read_text(encoding="utf-8")

for table in (
    "daily_challenges",
    "user_profiles",
    "daily_challenge_progress",
    "user_leaf_ledger",
    "user_owned_items",
    "user_garden_placements",
):
    assert f"alter table public.{table} enable row level security;" in migration

assert 'create policy "published daily challenges are readable"' in migration
assert "published_at <= now()" in migration
assert "challenge_date <= (now() at time zone 'UTC')::date" in migration
assert "create policy \"users read own daily progress\"" in migration
assert "revoke all on table public.daily_challenges" in migration
assert "return reply(501, { error: \"validation_not_implemented\" });" in function
assert "authClient.auth.getUser(token)" in function
assert "clientSubmissionId must be a UUID" in function

print("static scaffold checks passed")
