# SIAKAD Persistence

## Ringkasan

Aplikasi Flutter menyimpan data SIAKAD melalui Serverpod dan PostgreSQL. Saat pertama kali aplikasi dibuka, `MockService` mengambil state awal dari backend. Setelah itu, perubahan user tidak lagi dikirim sebagai full JSON state, tetapi sebagai delta per baris melalui `applyRowChanges`.

## Alur Simpan

- Bootstrap awal masih memakai `saveState` hanya ketika backend kosong atau saat proses resync eksplisit.
- Aksi CRUD normal memanggil `_saved`, membangun snapshot tabel lokal, lalu mengirim upsert/delete row yang berubah saja.
- Jika delta save gagal, aplikasi menyimpan error terakhir di `MockService.lastPersistenceError` dan menulis debug log.
- Fallback full-save dari perubahan user sengaja tidak dipakai karena dapat menimpa perubahan user lain yang terjadi setelah client memuat state awal.

## Batasan

- Strategi ini mengurangi risiko overwrite lintas tabel, tetapi belum menyelesaikan konflik dua user yang mengedit row yang sama secara bersamaan.
- Backend masih perlu auth, role guard, dan optimistic concurrency berbasis versi/hash row sebelum layak untuk multi-user produksi.
- UI saat ini belum menampilkan `lastPersistenceError`; error persistence baru tersedia untuk dipakai ViewModel atau banner status berikutnya.

## Rekomendasi Lanjutan

- Tambahkan kolom `version` atau `updatedAt` per row dan validasi expected version di `applyRowChanges`.
- Ubah endpoint domain agar setiap role hanya membaca dan menulis scope yang berhak diakses.
- Tampilkan indikator pending/error save di UI agar operator tahu ketika perubahan belum tersimpan.
