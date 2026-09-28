# Implementation status

Updated: 28 September 2026

## Completed and verified

- Flutter 3.44.4 / Dart 3.12.2 Android project built with application ID `com.mordddd.blocktaman.blocktaman_app`.
- Deterministic 8×8 engine: invalid no-op, simultaneous row/column clear, scoring/combo/all-clear, xorshift32, catalog 31 orientations, and explicit 24-piece daily sequence.
- Playable Santai with tap-to-place, score/combo/result, local active-session save after every valid move, and accessible labels.
- Daily practice mode loads local immutable fixtures and labels every score as local practice.
- SQLite foundation: session, idempotent leaf ledger, transactional cosmetic purchase, owned item, and garden placement storage.
- Garden/collection base: 12 decorations, 3 board themes catalog, 3×3 garden placement and explicit replace confirmation.
- 14 local daily challenge fixtures, stdlib generator/validator and solvability checks.
- Supabase migration/RLS scaffold and validation-only Edge Function skeleton. No connection/deployment is claimed.
- Required project documents are present.

## Current verification

- 28 September 2026: `flutter analyze` completed with no issues.
- 28 September 2026: `flutter test` passed, 14 tests.
- 28 September 2026: `flutter build apk --debug` succeeded: `build/app/outputs/flutter-apk/app-debug.apk`.
- Android emulator visual smoke test passed: home screen loaded and an accessible Santai move raised the score from 0 to 20 without a crash.
- Android manifest includes Google's official test AdMob application ID so the SDK can initialize in local builds; no production ad unit or live ad flow is enabled.
- Daily fixture validator: 14 fixtures passed.
- Supabase static scaffold checker: passed.

## External configuration not available

- Supabase project/keys, AdMob IDs/consent, Play Console products/credentials, signing keystore, production URLs, and a real Android device/emulator have not been supplied.
- No live ads, billing, ranked leaderboard, cloud backup, App Links, analytics collection, or release-signed AAB exists.

## Next verification

- Re-run test, analyze, debug APK build after final integration.
- Run device, gesture-drag, accessibility, text-scale, offline/network, IAP sandbox, Supabase RLS runtime, and monetization QA after corresponding environments exist.
