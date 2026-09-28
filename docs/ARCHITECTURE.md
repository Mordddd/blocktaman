# Arsitektur

`game_engine` adalah Dart murni: board, katalog 31 orientasi, xorshift32, validasi move, clear simultan, skor, dan daily sequence eksplisit.

Flutter UI berada di `main.dart` untuk slice saat ini; modul taman/koleksi/daily dipisah di `features`. SQLite `LocalStore` menyimpan sesi Santai, ledger Daun, koleksi, dan penempatan taman. Backend `supabase/` adalah scaffold terpisah dan belum dihubungkan.

Batas konsistensi: mutasi ledger pembelian berjalan dalam transaksi SQLite. Move Santai disimpan sesudah commit engine.