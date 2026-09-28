# BLOK TAMAN

Puzzle blok 8×8 Android berbahasa Indonesia. Build ini menyediakan Mode Santai lokal, Tantangan Harian latihan lokal, koleksi/taman dasar, penyimpanan SQLite, dan scaffold backend Supabase.

## Toolchain yang diverifikasi

- Flutter 3.44.4, Dart 3.12.2
- Android SDK 36.1.0, JDK 21

## Menjalankan

```text
C:\src\flutter\bin\flutter pub get
C:\src\flutter\bin\flutter test
C:\src\flutter\bin\flutter analyze
C:\src\flutter\bin\flutter run
C:\src\flutter\bin\flutter build apk --debug
```

APK debug: `build/app/outputs/flutter-apk/app-debug.apk`.

## Mode offline

Tanpa konfigurasi layanan, Santai tetap dapat dimainkan dan disimpan lokal. Tantangan Hari Ini memakai fixture latihan lokal; tidak ada klaim skor resmi atau leaderboard.

## Layanan belum dikonfigurasi

Ads, Play Billing, Supabase online/ranked/backup, analytics, deep links, dan release signing belum hidup karena credential/project/URL produksi tidak tersedia. Lihat `docs/SETUP_SERVICES.md` dan `docs/IMPLEMENTATION_STATUS.md`.

## Struktur

- `lib/game_engine`: aturan, skor, RNG deterministik
- `lib/features`: daily, taman, koleksi
- `assets/content/daily`: 14 manifest latihan lokal
- `supabase`: migration dan Edge Function skeleton
- `tools/daily_content.dart`: generator/validator fixture
