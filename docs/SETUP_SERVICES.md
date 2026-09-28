# Service setup

## Current state

No Supabase project, project reference, URL, keys, Supabase CLI credentials, Auth provider configuration, or deployment environment was provided. Nothing in this repository is linked or deployed. Do not treat the migration or Edge Function source as a live service.

## Provision Supabase

1. Create a Supabase project in the intended production region and record its project reference outside source control.
2. Install and authenticate the Supabase CLI, then run these commands from the repository root with the real project reference:

   ```sh
   supabase init
   supabase login
   supabase link --project-ref <real-project-ref>
   supabase db push
   supabase functions deploy validation-api
   ```

   `supabase init` creates project-local CLI configuration. Review its generated configuration before committing it; do not add project URLs, keys, or secrets to tracked files.

3. In the Supabase dashboard, configure the intended Auth providers, valid redirect URLs, email templates, token lifetimes, CAPTCHA/rate limits where appropriate, database backups, and operational access controls.
4. Confirm the migration succeeded and test the RLS matrix with anonymous, user A, user B, and service-role contexts. In particular, user B must not read user A's rows and future daily challenges must not be selectable.

## Edge Function configuration

The source uses the platform-provided `SUPABASE_URL` and `SUPABASE_ANON_KEY` only to verify bearer tokens. It has no write path.

Before adding server writes, set a server-only service-role secret in the function environment and use it only inside the function. Never put a service-role key in Flutter, committed configuration, crash reports, or client logs. Add an explicit allowed-origin policy if a browser client will invoke the function.

## Production work still required

- Build a trusted daily-challenge publisher that inserts the real seed/rules and sets `published_at` only when the challenge may be revealed. It must use server credentials, not a client key.
- Implement deterministic replay verification, idempotent persistence, and abuse/rate-limit controls before accepting daily scores.
- Implement server-to-server Google Play/App Store receipt verification before granting purchases.
- Add the Flutter Supabase integration only after URL/key delivery and an approved authentication/offline-sync design. This scaffold intentionally does not modify `pubspec.yaml` or UI code.
- Define monitoring, incident response, backup restoration, privacy-request handling, and production release ownership.

## Local/static checks

Without a linked project, SQL cannot be applied and the function cannot be deployed. Run the repository check below to catch scaffold regressions:

```sh
python supabase/tests/static_check.py
```

If Deno is installed, also type-check the Edge Function source with the version used by the target Supabase runtime before deployment.
