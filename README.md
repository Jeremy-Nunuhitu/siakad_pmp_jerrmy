# siakad_jeremy

Flutter SIAKAD app with a Serverpod backend and PostgreSQL persistence.

## Run Backend

```powershell
cd siakad_backend\siakad_backend_server
docker compose up -d postgres
dart bin\main.dart --apply-migrations
```

The development API runs at `http://localhost:8080/`.

## Run Flutter

```powershell
flutter pub get
flutter run --dart-define=SIAKAD_API_URL=http://localhost:8080/
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
