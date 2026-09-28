# Keputusan

- Flutter Canvas/CustomPainter belum dipakai: MVP memakai GridView agar interaksi tap-to-place dapat diverifikasi lebih cepat. Upgrade ke CustomPainter diperlukan untuk drag ghost dan highlight line premium.
- SQLite dipakai untuk state ekonomis lokal; shared preferences tidak dipakai untuk wallet.
- Daily offline disebut latihan lokal dan memakai fixture immutable, bukan manifest resmi.
- Ads dan billing sengaja belum ditambahkan tanpa credential/test configuration supaya tidak ada tombol monetisasi palsu.