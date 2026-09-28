# Aturan permainan

## Papan dan blok

- Papan berukuran 8×8. Koordinat `(row, col)` dimulai dari kiri atas pada 0–7.
- Letakkan blok jika seluruh cell berada di papan dan tidak menabrak cell terisi.
- Setiap baki memuat tiga blok. Gunakan dalam urutan bebas; baki baru hanya muncul setelah ketiganya habis.
- Blok tidak dapat diputar atau dicerminkan saat bermain. Orientasi adalah bagian dari `shapeId`.
- Penempatan tidak sah tidak mengubah papan, skor, RNG, atau giliran.
- Setelah penempatan sah, semua baris dan kolom penuh dibersihkan bersamaan. Cell perpotongan dibersihkan sekali, tetapi tetap dihitung sebagai dua line.
- Permainan selesai jika tidak ada blok tersisa yang dapat ditempatkan. Baki kosong diisi ulang sebelum pemeriksaan ini.

## Skor

Untuk piece dengan `n` cell dan `L` line yang dibersihkan:

- `placementPoints = 5 × n`
- `linePoints = 80 × L + 40 × max(0, L − 1)`
- Clear berturut-turut menaikkan pengali dari ×1 hingga maksimum ×5.
- `clearPoints = linePoints × pengali` bila `L > 0`; selain itu 0.
- All-clear memberi bonus tetap 150 bila penempatan juga melakukan clear.

Skor move adalah `placementPoints + clearPoints + allClearBonus`. Move tanpa clear mengatur ulang streak ke 0.

## Tantangan harian lokal

- Fallback offline adalah **Latihan • skor lokal**, bukan tantangan resmi atau leaderboard.
- Satu manifest berisi papan awal dan 24 `shapeId` tetap dalam 8 baki.
- Challenge memakai tanggal Asia/Jakarta, membuka pukul 00.00 WIB, dan dapat diulang gratis.
- Maksimal 24 penempatan sah; permainan juga dapat berakhir lebih awal bila tidak ada langkah legal.
- Urutan tidak berubah saat retry dan tidak dipengaruhi iklan, pembayaran, atau profil.
- Content lokal diuji dengan solver bounded sebelum dirilis. Witness replay hanya untuk QA dan tidak dimasukkan ke payload client.

## Kontrol aksesibel

Gunakan drag-and-drop atau pilih blok, pilih cell kiri-atas target, lalu tekan **Letakkan**. Lepas di luar papan atau posisi tidak sah membatalkan aksi tanpa penalti.
