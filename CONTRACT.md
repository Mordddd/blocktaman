# BLOK TAMAN module contract

Root app and game engine are owned by parent. Do not edit `lib/main.dart`, `lib/game_engine/`, `pubspec.yaml`, or Android files.

Design tokens: canvas `#F6F4EA`, ink `#23372D`, primary `#285B42`, terracotta `#B95735`, spacing 4/8/12/16/24, warm garden style, Bahasa Indonesia. No fake live integrations.

Source modules must be null-safe Dart, accessible, and use no additional dependency unless already listed in pubspec. Every non-trivial module needs a test.

File ownership:
- Agent A: `tools/`, `assets/content/`, `test/daily_*`, `docs/GAME_RULES.md`, `docs/ECONOMY.md`
- Agent B: `supabase/`, `docs/API.md`, `docs/DATA_PRIVACY.md`, `docs/SETUP_SERVICES.md`
- Agent C: `lib/features/garden/`, `lib/features/collection/`, `test/garden_*`

Verify scoped work with `C:\src\flutter\bin\flutter test`; backend SQL is static until Supabase CLI/config exists.
