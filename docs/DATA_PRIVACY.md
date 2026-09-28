# Data privacy

This is an engineering data inventory, not a privacy policy or legal advice. No production Supabase project is configured, and this scaffold does not send data anywhere by itself. Review this document with the product owner and counsel before release.

## Data in the proposed backend

| Data | Purpose | Access | Retention/deletion |
| --- | --- | --- | --- |
| Supabase Auth user ID | Bind private game state to an account | The signed-in user; trusted server code | Deleting the Auth user cascades to all tables in this migration. |
| Daily challenge date, seed, rules, publish time | Serve a reproducible shared challenge | Public only after publication and no earlier than that UTC date | Product-controlled; it contains no account data. |
| Score, move count, completion time | Personal challenge history; future validation/leaderboard work | The owning signed-in user; trusted server code writes | Deleted with the Auth user. |
| Leaf ledger source/amount/time | Personal economy and idempotency audit | The owning signed-in user; trusted server code writes | Deleted with the Auth user. |
| Owned item IDs and garden slot placements | Personal collection and garden state | The owning signed-in user; trusted server code writes | Deleted with the Auth user. |
| Store transaction ID (planned endpoint input) | Receipt verification and duplicate prevention | Trusted server code only | Define a documented retention period before implementing storage. The current skeleton does not store it. |

The current Flutter app also has local SQLite state. Local-device retention, backup behavior, and account-link migration must be specified before cloud sync is added.

## Security controls in this scaffold

- Row Level Security is enabled for every table.
- Published daily challenge rows are readable without an account; unpublished/future rows are not.
- Private tables permit only owner `SELECT`; no client mutation policy exists.
- Account deletion cascades from `auth.users` to private game tables.
- The Edge Function skeleton validates bearer tokens when Supabase Auth environment variables exist, validates payload shape, and makes no writes.

## Release requirements

- Publish a user-facing privacy notice naming the controller, contact, purposes, legal basis, retention, processors, international transfers, and data-subject request process applicable to the launch jurisdictions.
- Configure Supabase Auth email/OAuth and redirect URLs; do not collect profile fields unless they have a documented purpose.
- Keep service-role keys, store receipts, access tokens, and logs containing either out of the mobile app and source control.
- Establish a supported account-deletion flow and test that it removes Auth data and cascaded game data. Define a separate process for any operational backups.
- Set retention/deletion rules for purchase-verification records before adding their table or implementation.
- Review analytics, crash reporting, ads, push notifications, and payment SDKs before adding them; each introduces its own data collection and disclosure obligations.
