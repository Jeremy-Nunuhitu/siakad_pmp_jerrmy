# siakad_jeremy

Aplikasi Flutter SIAKAD dengan backend Serverpod dan persistence PostgreSQL.
Project ini berisi frontend multi-role, backend API, seed data demo, dan tabel
relasional untuk data akademik utama.

## Status Saat Ini

- Frontend Flutter memakai Provider dan `MockService` sebagai lapisan domain.
- Backend Serverpod menyimpan state aplikasi di `siakad_state` dan menjaga
  proyeksi tabel relasional seperti `mahasiswa`, `dosen`, `kelas`, `krs`,
  `nilai`, `pertemuan`, `presensi`, dan `activity_log`.
- Schema tabel domain dibuat lewat migration Serverpod
  `20260702123000000`, dengan tambahan UAS di `20260702154500000`, bukan lagi
  dari endpoint runtime.
- Startup pertama mengisi data dari `assets/database/siakad_seed.json` ketika
  backend masih kosong.
- Perubahan CRUD normal sekarang dikirim sebagai delta per baris melalui
  `applyRowChanges`, bukan full-state save. Ini mengurangi risiko perubahan
  user lain tertimpa oleh snapshot lama.
- Full-state save tetap dipakai untuk bootstrap awal atau resync eksplisit.
- Fitur UAS utama yang sudah ada meliputi role-based login, CRUD data master,
  KRS dengan validasi fase, kapasitas, bentrok jadwal mahasiswa, maksimum 24
  SKS, approval/rejection Dosen PA dengan catatan, presensi, nilai/KHS,
  menu Import/Export CSV/XLSX untuk data akademik utama, dan log aktivitas
  pengguna.
- Mata kuliah memiliki kategori `Reguler`, `Praktikum`, atau `Case Method`
  beserta komposisi nilai. Input nilai dosen menghitung nilai akhir dari bobot
  mata kuliah tersebut.
- Dokumentasi detail persistence ada di [`docs/persistence.md`](docs/persistence.md).

## Run Backend

```powershell
cd siakad_backend\siakad_backend_server
docker compose up -d postgres redis
dart bin\main.dart --apply-migrations
```

Development API berjalan di `http://localhost:8080/`.
Pastikan `--apply-migrations` berhasil sebelum menjalankan Flutter. Endpoint
`siakadState` sekarang hanya memvalidasi schema dan akan gagal eksplisit jika
tabel domain belum tersedia.

Untuk restart PostgreSQL dan Redis tanpa menghapus data:

```powershell
docker compose stop
docker compose up -d postgres redis
```

Jangan gunakan `docker compose down -v` kecuali memang ingin menghapus volume
PostgreSQL.

## Run Flutter

```powershell
flutter pub get
flutter run -d windows --dart-define=SIAKAD_API_URL=http://localhost:8080/
```

Jika backend berjalan di host lain, ubah nilai `SIAKAD_API_URL`.

## Seed dan Resync Data

Isi ulang Serverpod state dan sinkronkan tabel domain:

```powershell
dart run tool\seed_backend.dart
```

Jika state masih ada tetapi tabel relasional di pgAdmin kosong, jalankan resync:

```powershell
dart run tool\resync_backend_tables.dart
```

Tabel domain yang disinkronkan meliputi `mahasiswa`, `dosen`, `fakultas`,
`prodi`, `mata_kuliah`, `ruangan`, `kelas`, `dosen_pengajar`, `krs`, `nilai`,
`tugas`, `skripsi`, `magang`, `kkn`, `pertemuan`, `presensi`, dan
`presensi_dosen`, serta `activity_log`.

## Fitur UAS Tambahan

- **KRS**: mahasiswa hanya dapat mengambil KRS saat fase aktif, dalam prodi yang
  sesuai, tidak melebihi 24 SKS, tidak bentrok jadwal, dan tidak melebihi
  kapasitas kelas.
- **Persetujuan KRS**: Dosen PA dapat menyetujui atau menolak KRS. Penolakan
  wajib menyertakan catatan.
- **Nilai**: kategori dan bobot nilai disimpan pada mata kuliah. Nilai akhir
  dihitung dari tugas, UTS, UAS, dan softskill sesuai bobot tersebut.
- **Import/export data**: Admin Universitas memiliki menu Import tersendiri
  untuk input CSV/XLSX dan membuat template/export CSV untuk mahasiswa, dosen,
  mata kuliah, dan nilai. Gunakan template dari menu ini agar header kolom
  sesuai.
- **Log aktivitas**: login, logout, perubahan CRUD, KRS, nilai, presensi, dan
  aksi data lain dicatat pada `activity_log` dan ditampilkan di Data Global.

## Generate Dataset Demo Besar

```powershell
python tool\generate_bulk_siakad_data.py
docker cp tmp\siakad_bulk_seed.sql siakad_backend_server-postgres-1:/tmp/siakad_bulk_seed.sql
docker exec siakad_backend_server-postgres-1 psql -U postgres -d siakad_backend -f /tmp/siakad_bulk_seed.sql
dart run tool\check_backend_state.dart
```

Dataset besar berisi 5 fakultas, 25 prodi, 5000 mahasiswa, 375 dosen, dan data
akademik terkait termasuk KRS, nilai, pertemuan, presensi dosen, presensi
mahasiswa, tugas, skripsi, magang, dan KKN.

## Integrasi Backend

Backend kompatibel dengan state JSON aplikasi pada tabel `siakad_state`, tetapi
juga menjaga tabel domain sebagai proyeksi relasional. Sinkronisasi row memakai
delete incremental dan `INSERT ... ON CONFLICT DO UPDATE`, sehingga tabel domain
tidak dikosongkan total pada setiap save.

Tabel domain, index, dan foreign key dibuat secara deterministik oleh migration
`20260702123000000`. Tambahan kategori/bobot mata kuliah dan `activity_log`
dibuat oleh migration `20260702154500000`. Backend tidak lagi menjalankan DDL seperti
`CREATE TABLE`, `ALTER TABLE ... DROP NOT NULL`, atau foreign key `NOT VALID`
dari endpoint request. Migration juga mengembalikan `NOT NULL` untuk kolom
wajib dan memvalidasi foreign key yang sudah ada. Jika schema belum siap,
endpoint mengembalikan error agar operator menjalankan migrasi terlebih dahulu.

Endpoint `siakadState` menyediakan operasi berbasis whitelist tabel:
`listRows`, `getRow`, `upsertRow`, `applyRowChanges`, dan `deleteRow`.
Frontend saat ini memakai `getState` untuk initial load, lalu memakai
`applyRowChanges` untuk persistence perubahan normal.

Konfigurasi development mengaktifkan Redis dari `docker-compose`. Password
database dan Redis dapat dioverride dengan environment variable
`SIAKAD_DB_PASSWORD` dan `SIAKAD_REDIS_PASSWORD`.

## Test dan Quality Check

```powershell
flutter test
flutter analyze
```

Status terakhir:

- `flutter test`: lulus, 2 test.
- `dart analyze` pada file Flutter yang diubah: lulus tanpa issue.
- `dart analyze` pada endpoint Serverpod yang diubah: lulus tanpa issue.
- `flutter analyze`: sempat timeout tanpa output pada mesin lokal; ulangi
  perintah ini sebelum pengumpulan bila ingin verifikasi full-project analyzer.

Backend integration test membutuhkan PostgreSQL test yang aktif sesuai
konfigurasi Serverpod test.

## Catatan Produksi

Project ini sudah lebih aman dari risiko overwrite full-state antar-client,
tetapi belum siap produksi multi-user penuh. Pekerjaan lanjutan yang masih
penting:

- Tambahkan auth dan role guard di endpoint backend.
- Hash password dan hilangkan kredensial demo dari build non-development.
- Tambahkan optimistic concurrency per row, misalnya `version` atau `updatedAt`.
- Tampilkan status pending/error save di UI dengan memakai
  `MockService.lastPersistenceError`.
- Migrasikan aksi UI penting ke endpoint domain typed agar validasi dan scope
  akses berada di backend.
