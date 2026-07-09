# Matriks Fitur Project SIAKAD Jeremy

Tanggal penyusunan: 8 Juli 2026

Dokumen ini menjadi checklist fitur berdasarkan kode project Flutter SIAKAD.

## 1. Fitur Umum

| Fitur | Status | Keterangan |
|---|---:|---|
| Splash screen | Ada | Halaman awal sebelum login. |
| Login | Ada | Login user internal, mahasiswa, dan dosen. |
| Role-based navigation | Ada | Routing berbeda untuk setiap role. |
| Logout | Ada | Menghapus sesi aktif dan mencatat activity log. |
| Tema terang/gelap | Ada | Diatur melalui `ThemeViewModel`. |
| Responsive scaffold | Ada | Layout mobile dan desktop melalui `AppScaffold` dan `RoleHomeView`. |
| Activity log | Ada | Mencatat login, logout, import, dan aksi domain. |
| Seed data | Ada | `assets/database/siakad_seed.json`. |
| Persistence backend | Ada | Serverpod, PostgreSQL, state JSON, dan tabel domain. |

## 2. Admin Universitas

| Fitur | Status | Keterangan |
|---|---:|---|
| Dashboard universitas | Ada | KPI mahasiswa, dosen, kelas, dan KRS. |
| Kelola fakultas | Ada | Tambah fakultas dan akun Admin Fakultas. |
| Data Global | Ada | Statistik global, fase KRS, export, dan activity log. |
| Mulai fase KRS | Ada | Validasi periode dalam tahun ajaran aktif. |
| Akhiri fase KRS | Ada | Menutup fase KRS aktif. |
| Import data | Ada | CSV/XLSX mahasiswa, dosen, mata kuliah, nilai. |
| Export template | Ada | Template CSV per tipe data akademik. |
| Export data | Ada | Export data akademik ke CSV. |
| Kelola user | Ada | Manajemen user sesuai scope universitas. |

## 3. Admin Fakultas

| Fitur | Status | Keterangan |
|---|---:|---|
| Dashboard alur fakultas | Ada | Menjelaskan alur pengelolaan prodi dan operator. |
| Kelola prodi | Ada | Tambah prodi dan akun Operator Prodi. |
| Data scope fakultas | Ada | Menampilkan data dalam cakupan fakultas. |
| Kelola user fakultas | Ada | User dalam cakupan fakultas. |
| Profil | Ada | Profil dan logout. |

## 4. Operator Prodi

| Fitur | Status | Keterangan |
|---|---:|---|
| Dashboard prodi | Ada | Ringkasan mahasiswa, dosen, mata kuliah, ruangan, kelas. |
| Kelola mahasiswa | Ada | Tambah, edit, hapus, cari, sorting, pagination. |
| Kelola status mahasiswa | Ada | Ubah status dengan bukti wajib. |
| Riwayat status mahasiswa | Ada | Menyimpan perubahan status dan bukti. |
| Kelola dosen | Ada | Tambah, edit, hapus. |
| Kelola mata kuliah | Ada | Tambah, edit, hapus, kategori, bobot nilai. |
| Kelola ruangan | Ada | Tambah, edit, hapus, validasi kapasitas. |
| Kelola kelas | Ada | Buka, edit, hapus kelas kuliah. |
| Multi dosen pengajar | Ada | Dosen utama dan dosen pendamping. |
| Validasi bentrok ruangan | Ada | Ruangan tidak boleh dipakai pada jadwal bentrok. |
| Validasi bentrok dosen | Ada | Dosen tidak boleh mengajar pada jadwal bentrok. |
| User prodi | Ada | Daftar user terkait prodi. |

## 5. Mahasiswa

| Fitur | Status | Keterangan |
|---|---:|---|
| Dashboard mahasiswa | Ada | Ringkasan akademik, tugas, agenda, grafik IPK. |
| Ambil KRS | Ada | Draft KRS berdasarkan kelas prodi. |
| Submit KRS | Ada | Mengajukan KRS ke Dosen PA. |
| Hapus KRS draft | Ada | Bisa dihapus sebelum diajukan/disetujui. |
| Status KRS | Ada | Draft, diajukan, disetujui, ditolak. |
| Catatan penolakan KRS | Ada | Ditampilkan dari Dosen PA. |
| Cetak KRS | Ada | PDF Kartu Rencana Studi. |
| Jadwal kuliah | Ada | Jadwal dari KRS mahasiswa. |
| Nilai/KHS | Ada | Detail nilai dan rekap IPK/SKS. |
| Cetak KHS | Ada | PDF Kartu Hasil Studi. |
| Pengajuan skripsi | Ada | Mahasiswa mengajukan judul dan topik. |
| Pengajuan magang | Ada | Mahasiswa mengajukan instansi dan posisi. |
| Pengajuan KKN | Ada | Mahasiswa mengajukan lokasi dan tema. |
| Presensi mahasiswa | Ada | Presensi saat pertemuan berlangsung. |
| Riwayat presensi | Ada | Daftar presensi dan persentase kehadiran. |
| Profil mahasiswa | Ada | Data akademik, kontak, edit profil tertentu. |

## 6. Dosen

| Fitur | Status | Keterangan |
|---|---:|---|
| Dashboard dosen | Ada | Kelas, mahasiswa, tugas, KRS menunggu, bimbingan. |
| Kelas Saya | Ada | Daftar kelas yang diajar. |
| Pertemuan kelas | Ada | 16 pertemuan per kelas. |
| Mulai pertemuan | Ada | Dosen membuka pertemuan dengan materi. |
| Presensi mahasiswa | Ada | Dosen mengisi status peserta. |
| Presensi dosen | Ada | Dosen mengisi status kehadiran sendiri. |
| Selesaikan pertemuan | Ada | Mengubah status pertemuan selesai. |
| Rekap presensi PDF | Ada | Cetak presensi kelas. |
| Pilih kelas nilai | Ada | Dosen memilih kelas yang diampu. |
| Input nilai detail | Ada | Tugas, UTS, UAS, softskill, final. |
| Hitung nilai huruf | Ada | Otomatis berdasarkan nilai akhir. |
| Validasi KRS | Ada | Setuju atau tolak KRS mahasiswa bimbingan. |
| Catatan tolak KRS | Ada | Wajib saat penolakan. |
| Buat tugas | Ada | Judul, deskripsi, kelas, deadline. |
| Bimbingan skripsi | Ada | Setujui skripsi dan tambah catatan. |
| Profil dosen | Ada | Edit kontak dan keahlian. |

## 7. Pimpinan Rektor

| Fitur | Status | Keterangan |
|---|---:|---|
| Dashboard Rektor | Ada | Command center universitas. |
| Health score | Ada | Gabungan KRS, presensi, kapasitas, utilisasi. |
| Filter analitik | Ada | Tahun ajaran, semester, fakultas, prodi, KRS, presensi. |
| Data Universitas | Ada | Mahasiswa, dosen, mata kuliah, kelas, ruang. |
| Monitoring KRS | Ada | Status KRS universitas. |
| Monitoring Presensi | Ada | Grafik presensi mahasiswa dan dosen. |
| Laporan Akademik | Ada | Ringkasan KRS, presensi, kelas, ruangan. |
| Perbandingan fakultas | Ada | Tabel dan grafik indikator fakultas. |

## 8. Pimpinan Dekan

| Fitur | Status | Keterangan |
|---|---:|---|
| Dashboard Fakultas | Ada | Ringkasan akademik scope fakultas. |
| Monitoring kelas | Ada | Kelas dan ruangan dalam fakultas. |
| Monitoring KRS | Ada | KRS scope fakultas. |
| Monitoring presensi | Ada | Presensi mahasiswa dan dosen. |
| Laporan Fakultas | Ada | Rekap akademik fakultas. |
| Grafik KRS | Ada | Komposisi status KRS. |
| Grafik presensi | Ada | Mahasiswa dan dosen. |
| Warning akademik | Ada | Belum KRS, dosen belum presensi, presensi rendah. |

## 9. Pimpinan Korpro

| Fitur | Status | Keterangan |
|---|---:|---|
| Dashboard Prodi | Ada | Health score prodi. |
| KPI prodi | Ada | Mahasiswa aktif, dosen, presensi, KRS, kelas. |
| Mahasiswa prioritas | Ada | Ranking risiko berdasarkan IPK/presensi/SKS. |
| Kelas perlu perhatian | Ada | Berdasarkan metrik presensi/pertemuan. |
| Data mahasiswa prodi | Ada | Filter, sorting, pagination, detail. |
| Data dosen prodi | Ada | Beban SKS, kelas, presensi, bimbingan. |
| Jadwal kuliah prodi | Ada | Timeline dan analitik jadwal. |
| Deteksi konflik jadwal | Ada | Analisis bentrok pada view jadwal Korpro. |
| Overview presensi | Ada | KPI, gauge, heatmap, distribusi, attention list. |

## 10. Validasi Bisnis

| Area | Validasi |
|---|---|
| Fakultas | Nama wajib, duplikasi ditolak, username admin unik. |
| Prodi | Harus punya fakultas, duplikasi dalam fakultas ditolak. |
| Mahasiswa | NIM unik, prodi valid, Dosen PA harus dari prodi yang sama. |
| Status mahasiswa | Bukti wajib, maksimal 5 MB, format PDF/JPG/JPEG/PNG. |
| Dosen | NIDN unik, prodi valid, tidak bisa dihapus jika mengajar. |
| Mata kuliah | SKS lebih dari 0, bobot nilai total 100%. |
| Ruangan | Kapasitas lebih dari 0, tidak bisa kurang dari kapasitas kelas aktif. |
| Kelas | Minimal satu dosen, kapasitas valid, ruangan dan dosen tidak bentrok. |
| KRS | Fase aktif, prodi sama, kapasitas tersedia, tidak duplikat, tidak bentrok, maksimal 24 SKS. |
| Validasi KRS | Hanya Dosen PA yang dapat menyetujui/menolak. |
| Nilai | Dosen harus mengajar kelas; nilai huruf otomatis. |
| Pertemuan | Hanya dosen pengajar yang dapat mengelola pertemuan kelas. |
| Presensi mahasiswa | Hanya saat pertemuan berlangsung dan KRS sudah disetujui. |
| Presensi dosen | Status harus Hadir, Izin, Sakit, atau Alfa; tidak boleh dobel. |
| Skripsi | Satu skripsi aktif per mahasiswa; hanya pembimbing dapat menyetujui/catat. |
| Magang/KKN | Satu pengajuan aktif per mahasiswa. |

## 11. Output dan Laporan

| Output | Status | Keterangan |
|---|---:|---|
| PDF KRS | Ada | Dari `PdfService.printKRS`. |
| PDF KHS | Ada | Dari `PdfService.printKHS`. |
| PDF presensi kelas | Ada | Dari `PdfService.printPresensiKelas`. |
| CSV template | Ada | Mahasiswa, dosen, mata kuliah, nilai. |
| CSV export | Ada | Mahasiswa, dosen, mata kuliah, nilai. |
| XLSX import | Ada | Dibaca melalui package `excel`. |
| Activity log | Ada | Tampil di Data Global. |

## 12. Backend dan Database

| Komponen | Status | Keterangan |
|---|---:|---|
| Serverpod server | Ada | Folder `siakad_backend/siakad_backend_server`. |
| Serverpod client | Ada | Folder `siakad_backend/siakad_backend_client`. |
| Endpoint `siakadState` | Ada | State dan operasi row-based. |
| `getState`/`saveState` | Ada | Load dan full save state. |
| `applyRowChanges` | Ada | Simpan delta upsert/delete. |
| `listRows`/`getRow` | Ada | Baca data per tabel whitelist. |
| `upsertRow`/`deleteRow` | Ada | Operasi row tunggal. |
| Migration tabel domain | Ada | Tabel akademik utama dan index. |
| PostgreSQL | Ada | Persistence utama. |
| Redis | Ada | Konfigurasi Serverpod. |

## 13. Test

| Test | Status | Keterangan |
|---|---:|---|
| Role label test | Ada | Menjaga label role untuk routing. |
| Dashboard cache key test | Ada | Menjaga cache dashboard sensitif revision/filter. |
| Backend integration test | Ada | Endpoint greeting dan state SIAKAD. |

## 14. Catatan Pengembangan

Fitur sudah luas dan cocok untuk demo SIAKAD multi-role. Penguatan yang disarankan untuk produksi:

- Hash password.
- Tambahkan role guard di backend.
- Tambahkan optimistic concurrency per row.
- Tampilkan status sinkronisasi/persistence di UI.
- Tambahkan test validasi KRS, nilai, presensi, import/export, dan activity log.
