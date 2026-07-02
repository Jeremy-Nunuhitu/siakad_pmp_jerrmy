# siakad_jeremy

Flutter SIAKAD app with a Serverpod backend and PostgreSQL persistence.

## Run Backend

```powershell
cd siakad_backend\siakad_backend_server
docker compose up -d postgres redis
dart bin\main.dart --apply-migrations
```

The development API runs at `http://localhost:8080/`.

To restart PostgreSQL and Redis without losing data, use `docker compose stop`
and `docker compose up -d postgres redis`. Do not use `docker compose down -v`
unless you intentionally want to delete the PostgreSQL volume.

## Run Flutter

```powershell
flutter pub get
flutter run -d windows --dart-define=SIAKAD_API_URL=http://localhost:8080/
```

The Flutter app now reads and writes its SIAKAD state through Serverpod. The
first app startup seeds PostgreSQL from `assets/database/siakad_seed.json` when
the backend state is empty.

## Seed PostgreSQL Tables

```powershell
dart run tool\seed_backend.dart
```

This fills the Serverpod state and synchronizes the visible SIAKAD entity tables:
`mahasiswa`, `dosen`, `fakultas`, `prodi`, `mata_kuliah`, `ruangan`, `kelas`,
`dosen_pengajar`, `krs`, `nilai`, `tugas`, `skripsi`, `magang`, `kkn`,
`pertemuan`, `presensi`, and `presensi_dosen`.

If the app state still exists but the visible pgAdmin tables are empty, resync
the relational tables from Serverpod state:

```powershell
dart run tool\resync_backend_tables.dart
```

## Generate Large Demo Dataset

```powershell
python tool\generate_bulk_siakad_data.py
docker cp tmp\siakad_bulk_seed.sql siakad_backend_server-postgres-1:/tmp/siakad_bulk_seed.sql
docker exec siakad_backend_server-postgres-1 psql -U postgres -d siakad_backend -f /tmp/siakad_bulk_seed.sql
dart run tool\check_backend_state.dart
```

The bulk dataset contains 5 faculties, 25 programs, 5000 students, 375 lecturers,
and related academic records including KRS, grades, meetings, lecturer
attendance, student attendance, assignments, thesis, internship, and KKN data.

## Integrasi Backend

Backend tetap kompatibel dengan state JSON aplikasi pada tabel `siakad_state`,
tetapi tabel domain sekarang ikut dikelola sebagai proyeksi relasional yang
lebih aman. Saat state disimpan, backend melakukan delete incremental untuk
baris yang hilang dan `INSERT ... ON CONFLICT DO UPDATE` untuk baris yang ada,
sehingga tabel domain tidak lagi dikosongkan dengan `TRUNCATE`.

Tabel domain juga dibuat dengan index dan foreign key penting untuk relasi utama
seperti fakultas-prodi, prodi-mahasiswa, prodi-dosen, kelas-KRS, kelas-nilai,
pertemuan-presensi, dan presensi dosen. Endpoint `siakadState` menyediakan
operasi CRUD generik berbasis whitelist tabel: `listRows`, `getRow`,
`upsertRow`, dan `deleteRow`.

Konfigurasi development mengaktifkan Redis dari `docker-compose`. Password
database dan Redis dapat dioverride dengan environment variable
`SIAKAD_DB_PASSWORD` dan `SIAKAD_REDIS_PASSWORD`, sementara default lokal tetap
tersedia agar setup tugas/prototipe masih mudah dijalankan.

Catatan produksi: UI Flutter saat ini masih memakai alur state JSON penuh untuk
kompatibilitas fitur yang sudah ada. Langkah lanjutan untuk produksi besar
adalah memindahkan tiap aksi UI agar memanggil endpoint CRUD per entitas secara
langsung dan menambahkan model Serverpod typed untuk tiap tabel domain.
