BEGIN;

CREATE TABLE IF NOT EXISTS siakad_users (
  id text PRIMARY KEY,
  username text NOT NULL,
  password text NOT NULL,
  role text NOT NULL,
  name text NOT NULL,
  scope_id text NOT NULL,
  tingkat_pimpinan text,
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS fakultas (
  id text PRIMARY KEY,
  nama text NOT NULL,
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS prodi (
  id text PRIMARY KEY,
  nama text NOT NULL,
  fakultas_id text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_prodi_fakultas
    FOREIGN KEY (fakultas_id) REFERENCES fakultas(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS tahun_ajaran (
  id text PRIMARY KEY,
  nama text NOT NULL,
  semester text NOT NULL,
  tanggal_mulai text NOT NULL,
  tanggal_selesai text NOT NULL,
  aktif boolean NOT NULL,
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS fase_krs (
  tahun_ajaran_id text PRIMARY KEY,
  mulai text NOT NULL,
  berakhir text NOT NULL,
  aktif boolean NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_fase_krs_tahun_ajaran
    FOREIGN KEY (tahun_ajaran_id) REFERENCES tahun_ajaran(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS mahasiswa (
  nim text PRIMARY KEY,
  nama text NOT NULL,
  jenis_kelamin text NOT NULL,
  prodi_id text NOT NULL,
  password text NOT NULL,
  pembimbing_akademik_id text NOT NULL,
  semester bigint NOT NULL,
  email text NOT NULL,
  no_hp text NOT NULL,
  alamat text NOT NULL,
  status text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_mahasiswa_prodi
    FOREIGN KEY (prodi_id) REFERENCES prodi(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS riwayat_status_mahasiswa (
  id text PRIMARY KEY,
  mahasiswa_id text NOT NULL,
  status_sebelumnya text NOT NULL,
  status_baru text NOT NULL,
  nama_bukti text NOT NULL,
  tipe_bukti text NOT NULL,
  ukuran_bukti bigint NOT NULL,
  bukti_base64 text NOT NULL,
  diubah_pada text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_riwayat_status_mahasiswa
    FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS dosen (
  nidn text PRIMARY KEY,
  nama text NOT NULL,
  prodi_id text NOT NULL,
  password text NOT NULL,
  email text NOT NULL,
  no_hp text NOT NULL,
  alamat text NOT NULL,
  keahlian text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_dosen_prodi
    FOREIGN KEY (prodi_id) REFERENCES prodi(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS mata_kuliah (
  kode text PRIMARY KEY,
  nama text NOT NULL,
  sks bigint NOT NULL,
  prodi_id text NOT NULL,
  kategori text NOT NULL DEFAULT 'reguler',
  bobot_tugas double precision NOT NULL DEFAULT 25,
  bobot_uts double precision NOT NULL DEFAULT 25,
  bobot_uas double precision NOT NULL DEFAULT 35,
  bobot_softskill double precision NOT NULL DEFAULT 15,
  data jsonb NOT NULL,
  CONSTRAINT fk_mata_kuliah_prodi
    FOREIGN KEY (prodi_id) REFERENCES prodi(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

ALTER TABLE mata_kuliah
  ADD COLUMN IF NOT EXISTS kategori text NOT NULL DEFAULT 'reguler',
  ADD COLUMN IF NOT EXISTS bobot_tugas double precision NOT NULL DEFAULT 25,
  ADD COLUMN IF NOT EXISTS bobot_uts double precision NOT NULL DEFAULT 25,
  ADD COLUMN IF NOT EXISTS bobot_uas double precision NOT NULL DEFAULT 35,
  ADD COLUMN IF NOT EXISTS bobot_softskill double precision NOT NULL DEFAULT 15;

CREATE TABLE IF NOT EXISTS ruangan (
  kode_ruangan text PRIMARY KEY,
  nama_ruangan text NOT NULL,
  kapasitas_ruangan bigint NOT NULL,
  lokasi text NOT NULL,
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS kelas (
  id text PRIMARY KEY,
  mata_kuliah_id text NOT NULL,
  dosen_id text NOT NULL,
  kapasitas bigint NOT NULL,
  hari text NOT NULL,
  jam text NOT NULL,
  ruangan text NOT NULL,
  tahun_ajaran_id text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_kelas_mata_kuliah
    FOREIGN KEY (mata_kuliah_id) REFERENCES mata_kuliah(kode)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_kelas_dosen
    FOREIGN KEY (dosen_id) REFERENCES dosen(nidn)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_kelas_tahun_ajaran
    FOREIGN KEY (tahun_ajaran_id) REFERENCES tahun_ajaran(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS dosen_pengajar (
  id text PRIMARY KEY,
  id_kelas text NOT NULL,
  nidn_dosen text NOT NULL,
  peran_mengajar text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_dosen_pengajar_kelas
    FOREIGN KEY (id_kelas) REFERENCES kelas(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_dosen_pengajar_dosen
    FOREIGN KEY (nidn_dosen) REFERENCES dosen(nidn)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS krs (
  id text PRIMARY KEY,
  mahasiswa_id text NOT NULL,
  kelas_id text NOT NULL,
  semester bigint NOT NULL,
  is_submitted boolean NOT NULL,
  is_validated boolean NOT NULL,
  is_rejected boolean NOT NULL,
  catatan_dosen_pa text NOT NULL,
  tahun_ajaran_id text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_krs_mahasiswa
    FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_krs_kelas
    FOREIGN KEY (kelas_id) REFERENCES kelas(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_krs_tahun_ajaran
    FOREIGN KEY (tahun_ajaran_id) REFERENCES tahun_ajaran(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS nilai (
  id text PRIMARY KEY,
  mahasiswa_id text NOT NULL,
  kelas_id text NOT NULL,
  nilai_angka double precision NOT NULL,
  nilai_huruf text NOT NULL,
  semester bigint NOT NULL,
  nilai_tugas double precision NOT NULL,
  nilai_uts double precision NOT NULL,
  nilai_uas double precision NOT NULL,
  nilai_softskill double precision NOT NULL,
  bobot_tugas double precision NOT NULL,
  bobot_uts double precision NOT NULL,
  bobot_uas double precision NOT NULL,
  bobot_softskill double precision NOT NULL,
  tahun_ajaran_id text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_nilai_mahasiswa
    FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_nilai_kelas
    FOREIGN KEY (kelas_id) REFERENCES kelas(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_nilai_tahun_ajaran
    FOREIGN KEY (tahun_ajaran_id) REFERENCES tahun_ajaran(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS tugas (
  id text PRIMARY KEY,
  kelas_id text NOT NULL,
  judul text NOT NULL,
  deskripsi text NOT NULL,
  deadline text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_tugas_kelas
    FOREIGN KEY (kelas_id) REFERENCES kelas(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS skripsi (
  id text PRIMARY KEY,
  mahasiswa_id text NOT NULL,
  judul text NOT NULL,
  topik text NOT NULL,
  pembimbing_id text NOT NULL,
  dibuat_pada text NOT NULL,
  status text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_skripsi_mahasiswa
    FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_skripsi_dosen
    FOREIGN KEY (pembimbing_id) REFERENCES dosen(nidn)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS magang (
  id text PRIMARY KEY,
  mahasiswa_id text NOT NULL,
  instansi text NOT NULL,
  posisi text NOT NULL,
  dibuat_pada text NOT NULL,
  status text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_magang_mahasiswa
    FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS kkn (
  id text PRIMARY KEY,
  mahasiswa_id text NOT NULL,
  lokasi text NOT NULL,
  tema text NOT NULL,
  dibuat_pada text NOT NULL,
  status text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_kkn_mahasiswa
    FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pertemuan (
  id text PRIMARY KEY,
  kelas_id text NOT NULL,
  pertemuan_ke bigint NOT NULL,
  status text NOT NULL,
  materi text,
  waktu_mulai text,
  data jsonb NOT NULL,
  CONSTRAINT fk_pertemuan_kelas
    FOREIGN KEY (kelas_id) REFERENCES kelas(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS presensi (
  id text PRIMARY KEY,
  pertemuan_id text NOT NULL,
  mahasiswa_id text NOT NULL,
  status_kehadiran text NOT NULL,
  waktu_presensi text,
  catatan text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_presensi_pertemuan
    FOREIGN KEY (pertemuan_id) REFERENCES pertemuan(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_presensi_mahasiswa
    FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS presensi_dosen (
  id text PRIMARY KEY,
  pertemuan_id text NOT NULL,
  dosen_id text NOT NULL,
  status_kehadiran text NOT NULL,
  waktu_presensi text NOT NULL,
  catatan text NOT NULL,
  data jsonb NOT NULL,
  CONSTRAINT fk_presensi_dosen_pertemuan
    FOREIGN KEY (pertemuan_id) REFERENCES pertemuan(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_presensi_dosen_dosen
    FOREIGN KEY (dosen_id) REFERENCES dosen(nidn)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS activity_log (
  id text PRIMARY KEY,
  actor_id text NOT NULL,
  actor_name text NOT NULL,
  role text NOT NULL,
  action text NOT NULL,
  target text NOT NULL,
  description text NOT NULL,
  created_at text NOT NULL,
  data jsonb NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_siakad_users_username ON siakad_users(username);
CREATE INDEX IF NOT EXISTS idx_prodi_fakultas_id ON prodi(fakultas_id);
CREATE INDEX IF NOT EXISTS idx_mahasiswa_prodi_id ON mahasiswa(prodi_id);
CREATE INDEX IF NOT EXISTS idx_mahasiswa_pembimbing_akademik_id ON mahasiswa(pembimbing_akademik_id);
CREATE INDEX IF NOT EXISTS idx_dosen_prodi_id ON dosen(prodi_id);
CREATE INDEX IF NOT EXISTS idx_mata_kuliah_prodi_id ON mata_kuliah(prodi_id);
CREATE INDEX IF NOT EXISTS idx_kelas_mata_kuliah_id ON kelas(mata_kuliah_id);
CREATE INDEX IF NOT EXISTS idx_kelas_dosen_id ON kelas(dosen_id);
CREATE INDEX IF NOT EXISTS idx_kelas_tahun_ajaran_id ON kelas(tahun_ajaran_id);
CREATE INDEX IF NOT EXISTS idx_dosen_pengajar_id_kelas ON dosen_pengajar(id_kelas);
CREATE INDEX IF NOT EXISTS idx_dosen_pengajar_nidn_dosen ON dosen_pengajar(nidn_dosen);
CREATE INDEX IF NOT EXISTS idx_krs_mahasiswa_id ON krs(mahasiswa_id);
CREATE INDEX IF NOT EXISTS idx_krs_kelas_id ON krs(kelas_id);
CREATE INDEX IF NOT EXISTS idx_nilai_mahasiswa_id ON nilai(mahasiswa_id);
CREATE INDEX IF NOT EXISTS idx_nilai_kelas_id ON nilai(kelas_id);
CREATE INDEX IF NOT EXISTS idx_pertemuan_kelas_id ON pertemuan(kelas_id);
CREATE INDEX IF NOT EXISTS idx_presensi_pertemuan_id ON presensi(pertemuan_id);
CREATE INDEX IF NOT EXISTS idx_presensi_mahasiswa_id ON presensi(mahasiswa_id);
CREATE INDEX IF NOT EXISTS idx_presensi_dosen_pertemuan_id ON presensi_dosen(pertemuan_id);
CREATE INDEX IF NOT EXISTS idx_presensi_dosen_dosen_id ON presensi_dosen(dosen_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_created_at ON activity_log(created_at);
CREATE INDEX IF NOT EXISTS idx_activity_log_actor_id ON activity_log(actor_id);

ALTER TABLE siakad_users
  ALTER COLUMN username SET NOT NULL,
  ALTER COLUMN password SET NOT NULL,
  ALTER COLUMN role SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN scope_id SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE fakultas
  ALTER COLUMN nama SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE prodi
  ALTER COLUMN nama SET NOT NULL,
  ALTER COLUMN fakultas_id SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE tahun_ajaran
  ALTER COLUMN nama SET NOT NULL,
  ALTER COLUMN semester SET NOT NULL,
  ALTER COLUMN tanggal_mulai SET NOT NULL,
  ALTER COLUMN tanggal_selesai SET NOT NULL,
  ALTER COLUMN aktif SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE fase_krs
  ALTER COLUMN mulai SET NOT NULL,
  ALTER COLUMN berakhir SET NOT NULL,
  ALTER COLUMN aktif SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE mahasiswa
  ALTER COLUMN nama SET NOT NULL,
  ALTER COLUMN jenis_kelamin SET NOT NULL,
  ALTER COLUMN prodi_id SET NOT NULL,
  ALTER COLUMN password SET NOT NULL,
  ALTER COLUMN pembimbing_akademik_id SET NOT NULL,
  ALTER COLUMN semester SET NOT NULL,
  ALTER COLUMN email SET NOT NULL,
  ALTER COLUMN no_hp SET NOT NULL,
  ALTER COLUMN alamat SET NOT NULL,
  ALTER COLUMN status SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE riwayat_status_mahasiswa
  ALTER COLUMN mahasiswa_id SET NOT NULL,
  ALTER COLUMN status_sebelumnya SET NOT NULL,
  ALTER COLUMN status_baru SET NOT NULL,
  ALTER COLUMN nama_bukti SET NOT NULL,
  ALTER COLUMN tipe_bukti SET NOT NULL,
  ALTER COLUMN ukuran_bukti SET NOT NULL,
  ALTER COLUMN bukti_base64 SET NOT NULL,
  ALTER COLUMN diubah_pada SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE dosen
  ALTER COLUMN nama SET NOT NULL,
  ALTER COLUMN prodi_id SET NOT NULL,
  ALTER COLUMN password SET NOT NULL,
  ALTER COLUMN email SET NOT NULL,
  ALTER COLUMN no_hp SET NOT NULL,
  ALTER COLUMN alamat SET NOT NULL,
  ALTER COLUMN keahlian SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE mata_kuliah
  ALTER COLUMN nama SET NOT NULL,
  ALTER COLUMN sks SET NOT NULL,
  ALTER COLUMN prodi_id SET NOT NULL,
  ALTER COLUMN kategori SET DEFAULT 'reguler',
  ALTER COLUMN kategori SET NOT NULL,
  ALTER COLUMN bobot_tugas SET DEFAULT 25,
  ALTER COLUMN bobot_tugas SET NOT NULL,
  ALTER COLUMN bobot_uts SET DEFAULT 25,
  ALTER COLUMN bobot_uts SET NOT NULL,
  ALTER COLUMN bobot_uas SET DEFAULT 35,
  ALTER COLUMN bobot_uas SET NOT NULL,
  ALTER COLUMN bobot_softskill SET DEFAULT 15,
  ALTER COLUMN bobot_softskill SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE ruangan
  ALTER COLUMN nama_ruangan SET NOT NULL,
  ALTER COLUMN kapasitas_ruangan SET NOT NULL,
  ALTER COLUMN lokasi SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE kelas
  ALTER COLUMN mata_kuliah_id SET NOT NULL,
  ALTER COLUMN dosen_id SET NOT NULL,
  ALTER COLUMN kapasitas SET NOT NULL,
  ALTER COLUMN hari SET NOT NULL,
  ALTER COLUMN jam SET NOT NULL,
  ALTER COLUMN ruangan SET NOT NULL,
  ALTER COLUMN tahun_ajaran_id SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE dosen_pengajar
  ALTER COLUMN id_kelas SET NOT NULL,
  ALTER COLUMN nidn_dosen SET NOT NULL,
  ALTER COLUMN peran_mengajar SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE krs
  ALTER COLUMN mahasiswa_id SET NOT NULL,
  ALTER COLUMN kelas_id SET NOT NULL,
  ALTER COLUMN semester SET NOT NULL,
  ALTER COLUMN is_submitted SET NOT NULL,
  ALTER COLUMN is_validated SET NOT NULL,
  ALTER COLUMN is_rejected SET NOT NULL,
  ALTER COLUMN catatan_dosen_pa SET NOT NULL,
  ALTER COLUMN tahun_ajaran_id SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE nilai
  ALTER COLUMN mahasiswa_id SET NOT NULL,
  ALTER COLUMN kelas_id SET NOT NULL,
  ALTER COLUMN nilai_angka SET NOT NULL,
  ALTER COLUMN nilai_huruf SET NOT NULL,
  ALTER COLUMN semester SET NOT NULL,
  ALTER COLUMN nilai_tugas SET NOT NULL,
  ALTER COLUMN nilai_uts SET NOT NULL,
  ALTER COLUMN nilai_uas SET NOT NULL,
  ALTER COLUMN nilai_softskill SET NOT NULL,
  ALTER COLUMN bobot_tugas SET NOT NULL,
  ALTER COLUMN bobot_uts SET NOT NULL,
  ALTER COLUMN bobot_uas SET NOT NULL,
  ALTER COLUMN bobot_softskill SET NOT NULL,
  ALTER COLUMN tahun_ajaran_id SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE tugas
  ALTER COLUMN kelas_id SET NOT NULL,
  ALTER COLUMN judul SET NOT NULL,
  ALTER COLUMN deskripsi SET NOT NULL,
  ALTER COLUMN deadline SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE skripsi
  ALTER COLUMN mahasiswa_id SET NOT NULL,
  ALTER COLUMN judul SET NOT NULL,
  ALTER COLUMN topik SET NOT NULL,
  ALTER COLUMN pembimbing_id SET NOT NULL,
  ALTER COLUMN dibuat_pada SET NOT NULL,
  ALTER COLUMN status SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE magang
  ALTER COLUMN mahasiswa_id SET NOT NULL,
  ALTER COLUMN instansi SET NOT NULL,
  ALTER COLUMN posisi SET NOT NULL,
  ALTER COLUMN dibuat_pada SET NOT NULL,
  ALTER COLUMN status SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE kkn
  ALTER COLUMN mahasiswa_id SET NOT NULL,
  ALTER COLUMN lokasi SET NOT NULL,
  ALTER COLUMN tema SET NOT NULL,
  ALTER COLUMN dibuat_pada SET NOT NULL,
  ALTER COLUMN status SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE pertemuan
  ALTER COLUMN kelas_id SET NOT NULL,
  ALTER COLUMN pertemuan_ke SET NOT NULL,
  ALTER COLUMN status SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE presensi
  ALTER COLUMN pertemuan_id SET NOT NULL,
  ALTER COLUMN mahasiswa_id SET NOT NULL,
  ALTER COLUMN status_kehadiran SET NOT NULL,
  ALTER COLUMN catatan SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE presensi_dosen
  ALTER COLUMN pertemuan_id SET NOT NULL,
  ALTER COLUMN dosen_id SET NOT NULL,
  ALTER COLUMN status_kehadiran SET NOT NULL,
  ALTER COLUMN waktu_presensi SET NOT NULL,
  ALTER COLUMN catatan SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

ALTER TABLE activity_log
  ALTER COLUMN actor_id SET NOT NULL,
  ALTER COLUMN actor_name SET NOT NULL,
  ALTER COLUMN role SET NOT NULL,
  ALTER COLUMN action SET NOT NULL,
  ALTER COLUMN target SET NOT NULL,
  ALTER COLUMN description SET NOT NULL,
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_prodi_fakultas') THEN
    ALTER TABLE prodi ADD CONSTRAINT fk_prodi_fakultas
      FOREIGN KEY (fakultas_id) REFERENCES fakultas(id)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE prodi VALIDATE CONSTRAINT fk_prodi_fakultas;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_fase_krs_tahun_ajaran') THEN
    ALTER TABLE fase_krs ADD CONSTRAINT fk_fase_krs_tahun_ajaran
      FOREIGN KEY (tahun_ajaran_id) REFERENCES tahun_ajaran(id)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE fase_krs VALIDATE CONSTRAINT fk_fase_krs_tahun_ajaran;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_mahasiswa_prodi') THEN
    ALTER TABLE mahasiswa ADD CONSTRAINT fk_mahasiswa_prodi
      FOREIGN KEY (prodi_id) REFERENCES prodi(id)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE mahasiswa VALIDATE CONSTRAINT fk_mahasiswa_prodi;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_riwayat_status_mahasiswa') THEN
    ALTER TABLE riwayat_status_mahasiswa ADD CONSTRAINT fk_riwayat_status_mahasiswa
      FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE riwayat_status_mahasiswa VALIDATE CONSTRAINT fk_riwayat_status_mahasiswa;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_dosen_prodi') THEN
    ALTER TABLE dosen ADD CONSTRAINT fk_dosen_prodi
      FOREIGN KEY (prodi_id) REFERENCES prodi(id)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE dosen VALIDATE CONSTRAINT fk_dosen_prodi;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_mata_kuliah_prodi') THEN
    ALTER TABLE mata_kuliah ADD CONSTRAINT fk_mata_kuliah_prodi
      FOREIGN KEY (prodi_id) REFERENCES prodi(id)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE mata_kuliah VALIDATE CONSTRAINT fk_mata_kuliah_prodi;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kelas_mata_kuliah') THEN
    ALTER TABLE kelas ADD CONSTRAINT fk_kelas_mata_kuliah
      FOREIGN KEY (mata_kuliah_id) REFERENCES mata_kuliah(kode)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE kelas VALIDATE CONSTRAINT fk_kelas_mata_kuliah;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kelas_dosen') THEN
    ALTER TABLE kelas ADD CONSTRAINT fk_kelas_dosen
      FOREIGN KEY (dosen_id) REFERENCES dosen(nidn)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE kelas VALIDATE CONSTRAINT fk_kelas_dosen;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kelas_tahun_ajaran') THEN
    ALTER TABLE kelas ADD CONSTRAINT fk_kelas_tahun_ajaran
      FOREIGN KEY (tahun_ajaran_id) REFERENCES tahun_ajaran(id)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE kelas VALIDATE CONSTRAINT fk_kelas_tahun_ajaran;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_dosen_pengajar_kelas') THEN
    ALTER TABLE dosen_pengajar ADD CONSTRAINT fk_dosen_pengajar_kelas
      FOREIGN KEY (id_kelas) REFERENCES kelas(id)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE dosen_pengajar VALIDATE CONSTRAINT fk_dosen_pengajar_kelas;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_dosen_pengajar_dosen') THEN
    ALTER TABLE dosen_pengajar ADD CONSTRAINT fk_dosen_pengajar_dosen
      FOREIGN KEY (nidn_dosen) REFERENCES dosen(nidn)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE dosen_pengajar VALIDATE CONSTRAINT fk_dosen_pengajar_dosen;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_krs_mahasiswa') THEN
    ALTER TABLE krs ADD CONSTRAINT fk_krs_mahasiswa
      FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE krs VALIDATE CONSTRAINT fk_krs_mahasiswa;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_krs_kelas') THEN
    ALTER TABLE krs ADD CONSTRAINT fk_krs_kelas
      FOREIGN KEY (kelas_id) REFERENCES kelas(id)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE krs VALIDATE CONSTRAINT fk_krs_kelas;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_krs_tahun_ajaran') THEN
    ALTER TABLE krs ADD CONSTRAINT fk_krs_tahun_ajaran
      FOREIGN KEY (tahun_ajaran_id) REFERENCES tahun_ajaran(id)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE krs VALIDATE CONSTRAINT fk_krs_tahun_ajaran;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_nilai_mahasiswa') THEN
    ALTER TABLE nilai ADD CONSTRAINT fk_nilai_mahasiswa
      FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE nilai VALIDATE CONSTRAINT fk_nilai_mahasiswa;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_nilai_kelas') THEN
    ALTER TABLE nilai ADD CONSTRAINT fk_nilai_kelas
      FOREIGN KEY (kelas_id) REFERENCES kelas(id)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE nilai VALIDATE CONSTRAINT fk_nilai_kelas;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_nilai_tahun_ajaran') THEN
    ALTER TABLE nilai ADD CONSTRAINT fk_nilai_tahun_ajaran
      FOREIGN KEY (tahun_ajaran_id) REFERENCES tahun_ajaran(id)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE nilai VALIDATE CONSTRAINT fk_nilai_tahun_ajaran;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tugas_kelas') THEN
    ALTER TABLE tugas ADD CONSTRAINT fk_tugas_kelas
      FOREIGN KEY (kelas_id) REFERENCES kelas(id)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE tugas VALIDATE CONSTRAINT fk_tugas_kelas;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_skripsi_mahasiswa') THEN
    ALTER TABLE skripsi ADD CONSTRAINT fk_skripsi_mahasiswa
      FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE skripsi VALIDATE CONSTRAINT fk_skripsi_mahasiswa;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_skripsi_dosen') THEN
    ALTER TABLE skripsi ADD CONSTRAINT fk_skripsi_dosen
      FOREIGN KEY (pembimbing_id) REFERENCES dosen(nidn)
      ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
  ALTER TABLE skripsi VALIDATE CONSTRAINT fk_skripsi_dosen;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_magang_mahasiswa') THEN
    ALTER TABLE magang ADD CONSTRAINT fk_magang_mahasiswa
      FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE magang VALIDATE CONSTRAINT fk_magang_mahasiswa;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kkn_mahasiswa') THEN
    ALTER TABLE kkn ADD CONSTRAINT fk_kkn_mahasiswa
      FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE kkn VALIDATE CONSTRAINT fk_kkn_mahasiswa;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_pertemuan_kelas') THEN
    ALTER TABLE pertemuan ADD CONSTRAINT fk_pertemuan_kelas
      FOREIGN KEY (kelas_id) REFERENCES kelas(id)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE pertemuan VALIDATE CONSTRAINT fk_pertemuan_kelas;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_presensi_pertemuan') THEN
    ALTER TABLE presensi ADD CONSTRAINT fk_presensi_pertemuan
      FOREIGN KEY (pertemuan_id) REFERENCES pertemuan(id)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE presensi VALIDATE CONSTRAINT fk_presensi_pertemuan;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_presensi_mahasiswa') THEN
    ALTER TABLE presensi ADD CONSTRAINT fk_presensi_mahasiswa
      FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(nim)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE presensi VALIDATE CONSTRAINT fk_presensi_mahasiswa;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_presensi_dosen_pertemuan') THEN
    ALTER TABLE presensi_dosen ADD CONSTRAINT fk_presensi_dosen_pertemuan
      FOREIGN KEY (pertemuan_id) REFERENCES pertemuan(id)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE presensi_dosen VALIDATE CONSTRAINT fk_presensi_dosen_pertemuan;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_presensi_dosen_dosen') THEN
    ALTER TABLE presensi_dosen ADD CONSTRAINT fk_presensi_dosen_dosen
      FOREIGN KEY (dosen_id) REFERENCES dosen(nidn)
      ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
  ALTER TABLE presensi_dosen VALIDATE CONSTRAINT fk_presensi_dosen_dosen;
END
$$;

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
  VALUES ('siakad_backend', '20260702123000000', now())
  ON CONFLICT ("module")
  DO UPDATE SET "version" = '20260702123000000', "timestamp" = now();

COMMIT;
