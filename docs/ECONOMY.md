# Ekonomi Daun

Daun adalah mata uang kosmetik lokal. Daun tidak dapat ditukar uang, ditransfer, diperdagangkan, atau memengaruhi skor dan kompetisi.

## Sumber awal

| Sumber | Aturan |
|---|---|
| Welcome | 20 Daun sekali setelah tutorial selesai atau dilewati |
| Santai | `min(50, floor(validMoves / 4) + totalLinesCleared)` per sesi, diberikan bertahap |
| Daily hari ini | 25 Daun sekali per `dateKey` setelah minimal 8 move sah dalam satu attempt |
| Misi mingguan | 40 Daun sekali setelah memenuhi 3 tanggal berbeda dalam minggu WIB |
| Iklan rewarded | +15 Daun hanya setelah callback reward yang sah |

Bonus daily memakai ledger key `daily:<dateKey>` sehingga latihan lokal dan manifest resmi tidak dapat memberi bonus dua kali. Arsip, retry, dan tutorial tidak menggandakan bonus. Pada guest offline, waktu perangkat adalah mitigasi UX, bukan perlindungan anti-cheat.

## Guardrail

- Semua grant dan pengeluaran memakai idempotency key unik, amount integer, timestamp, dan metadata minimum.
- Saldo tidak boleh negatif; beli dekorasi dilakukan atomik bersama unlock item.
- Iklan bersifat opsional: tidak ada banner, interstitial, auto-show, energi, atau penawaran yang menyamar sebagai lanjut bermain.
- Rewarded ad tidak mengubah skor, line, combo, atau progres misi. Batas awal: maksimal tiga reward per hari WIB dan cooldown 180 detik setelah reward.
- Harga dan reward ini adalah konfigurasi awal untuk playtest, bukan janji laju progres atau nilai uang.

## Katalog dekorasi awal

Dekorasi dijual dengan Daun dan bersifat kosmetik permanen: Kaktus Mini 20, Pakis 40, Rumpun Daisy 60, Batu Pijakan 80, Bangku Kayu 100, Lentera 120, Sudut Penyiram 140, Tempat Minum Burung 160, Kolam Kecil 180, Pohon Maple 220, Hammock 260, dan Gazebo Mini 320. Total katalog awal 1.700 Daun.

Tema papan: Pagi gratis, Senja 180 Daun, Malam 240 Daun. Premium store, bila dikonfigurasi, memakai pembelian non-consumable terpisah dan tidak dapat dibeli dengan Daun.
