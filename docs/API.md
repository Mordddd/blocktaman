# API scaffold

## Status

No Supabase project, URL, keys, CLI login, or deployed function was supplied. The repository contains a migration and an Edge Function **source skeleton only**; no live endpoint is claimed.

The Flutter app has no Supabase client dependency or integration yet. Add that separately only after a project is provisioned and the security contract below is accepted.

## Database access contract

| Resource | Client access | Notes |
| --- | --- | --- |
| `daily_challenges` | Anonymous/authenticated `SELECT` after `published_at`, never for a future UTC date | No client writes. |
| `user_profiles` | Authenticated owner `SELECT` | Created from the `auth.users` insert trigger. |
| `daily_challenge_progress` | Authenticated owner `SELECT` | Submission writes are server-only. |
| `user_leaf_ledger` | Authenticated owner `SELECT` | Grants/revocations are server-only. |
| `user_owned_items` | Authenticated owner `SELECT` | Award writes are server-only. |
| `user_garden_placements` | Authenticated owner `SELECT` | Placement writes are server-only; item ownership is enforced by a composite foreign key. |

All listed tables have RLS enabled. There are intentionally no client `INSERT`, `UPDATE`, or `DELETE` grants/policies on player-owned state: client scores, rewards, and receipts are untrusted.

## Edge Function contract (not deployed)

Function source: `supabase/functions/validation-api/index.ts`.

After a project is linked and the function is deployed, the gateway route is expected to be one of these paths (depending on the Supabase function URL form):

- `POST .../validation-api/daily-completion`
- `POST .../validation-api/purchase`

Both require `Authorization: Bearer <user access token>`. The skeleton uses `SUPABASE_URL` and `SUPABASE_ANON_KEY` to verify that token with Supabase Auth. It rejects malformed JSON and malformed payloads, then returns `501 validation_not_implemented`; it does not write data, verify a game replay, verify a store receipt, or grant an entitlement.

### `daily-completion` body

```json
{
  "challengeDate": "2026-09-28",
  "score": 1240,
  "moveCount": 38,
  "clientSubmissionId": "optional UUID"
}
```

`challengeDate` must be a real UTC ISO calendar date; `score` is an integer from 0 through 1,000,000,000; `moveCount` is an integer from 0 through 10,000.

### `purchase` body

```json
{
  "platform": "google_play",
  "transactionId": "store-issued-transaction-id"
}
```

`platform` is `google_play` or `app_store`. `transactionId` is required and limited to 256 characters.

## Required implementation before enabling writes

1. Verify the authenticated user and enforce per-user rate limits.
2. For daily completion, validate a deterministic game replay against the published challenge and make the write idempotent using a server-generated key.
3. For purchases, verify the receipt with the relevant store server API, persist the verified transaction idempotently, then grant items in one database transaction.
4. Use a server-only service-role client for those writes; never ship the service-role key in Flutter.
5. Return only the caller's own result and log security-relevant failures without request tokens or raw receipts.
