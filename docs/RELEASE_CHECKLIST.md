# Release checklist

- Tentukan final applicationId dan merek yang sudah dicek.
- Konfigurasi signing release, target SDK dan perangkat nyata.
- Sediakan privacy/support URL nyata dan deklarasi Data Safety.
- Provision Supabase, apply migration, test RLS/function runtime.
- Konfigurasi UMP/AdMob test IDs lalu production IDs setelah audit.
- Buat Play Console product, license tester, dan verifikasi purchase backend.
- Tambah App Links terverifikasi jika domain tersedia.
- Jalankan test/analyze/release build, visual QA dan accessibility QA.
- Secret scan; jangan commit key atau token.