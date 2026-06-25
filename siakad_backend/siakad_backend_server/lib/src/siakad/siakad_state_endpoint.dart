import 'dart:convert';

import '../generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class SiakadStateEndpoint extends Endpoint {
  static const _stateKey = 'app_state';

  Future<String?> getState(Session session) async {
    await _ensureSiakadTables(session);
    final row = await SiakadState.db.findFirstRow(
      session,
      where: (t) => t.key.equals(_stateKey),
    );
    return row?.value;
  }

  Future<void> saveState(Session session, String stateJson) async {
    await _ensureSiakadTables(session);
    final row = await SiakadState.db.findFirstRow(
      session,
      where: (t) => t.key.equals(_stateKey),
    );

    if (row == null) {
      await SiakadState.db.insertRow(
        session,
        SiakadState(key: _stateKey, value: stateJson),
      );
      await _syncRelationalTables(session, stateJson);
      return;
    }

    row.value = stateJson;
    await SiakadState.db.updateRow(session, row);
    await _syncRelationalTables(session, stateJson);
  }

  Future<void> _ensureSiakadTables(Session session) async {
    await session.db.unsafeExecute('''
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
  data jsonb NOT NULL
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
  data jsonb NOT NULL
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
  data jsonb NOT NULL
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
  data jsonb NOT NULL
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
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS mata_kuliah (
  kode text PRIMARY KEY,
  nama text NOT NULL,
  sks bigint NOT NULL,
  prodi_id text NOT NULL,
  data jsonb NOT NULL
);

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
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS dosen_pengajar (
  id text PRIMARY KEY,
  id_kelas text NOT NULL,
  nidn_dosen text NOT NULL,
  peran_mengajar text NOT NULL,
  data jsonb NOT NULL
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
  data jsonb NOT NULL
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
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS tugas (
  id text PRIMARY KEY,
  kelas_id text NOT NULL,
  judul text NOT NULL,
  deskripsi text NOT NULL,
  deadline text NOT NULL,
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS skripsi (
  id text PRIMARY KEY,
  mahasiswa_id text NOT NULL,
  judul text NOT NULL,
  topik text NOT NULL,
  pembimbing_id text NOT NULL,
  dibuat_pada text NOT NULL,
  status text NOT NULL,
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS magang (
  id text PRIMARY KEY,
  mahasiswa_id text NOT NULL,
  instansi text NOT NULL,
  posisi text NOT NULL,
  dibuat_pada text NOT NULL,
  status text NOT NULL,
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS kkn (
  id text PRIMARY KEY,
  mahasiswa_id text NOT NULL,
  lokasi text NOT NULL,
  tema text NOT NULL,
  dibuat_pada text NOT NULL,
  status text NOT NULL,
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS pertemuan (
  id text PRIMARY KEY,
  kelas_id text NOT NULL,
  pertemuan_ke bigint NOT NULL,
  status text NOT NULL,
  materi text,
  waktu_mulai text,
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS presensi (
  id text PRIMARY KEY,
  pertemuan_id text NOT NULL,
  mahasiswa_id text NOT NULL,
  status_kehadiran text NOT NULL,
  waktu_presensi text,
  catatan text NOT NULL,
  data jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS presensi_dosen (
  id text PRIMARY KEY,
  pertemuan_id text NOT NULL,
  dosen_id text NOT NULL,
  status_kehadiran text NOT NULL,
  waktu_presensi text NOT NULL,
  catatan text NOT NULL,
  data jsonb NOT NULL
);

DO \$\$
DECLARE
  column_record record;
BEGIN
  FOR column_record IN
    SELECT columns.table_name, columns.column_name
    FROM information_schema.columns columns
    WHERE columns.table_schema = 'public'
      AND columns.table_name IN (
        'siakad_users',
        'fakultas',
        'prodi',
        'tahun_ajaran',
        'fase_krs',
        'mahasiswa',
        'riwayat_status_mahasiswa',
        'dosen',
        'mata_kuliah',
        'ruangan',
        'kelas',
        'dosen_pengajar',
        'krs',
        'nilai',
        'tugas',
        'skripsi',
        'magang',
        'kkn',
        'pertemuan',
        'presensi',
        'presensi_dosen'
      )
      AND columns.column_name <> 'data'
      AND NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints constraints
        JOIN information_schema.key_column_usage key_usage
          ON key_usage.constraint_name = constraints.constraint_name
         AND key_usage.table_schema = constraints.table_schema
         AND key_usage.table_name = constraints.table_name
        WHERE constraints.constraint_type = 'PRIMARY KEY'
          AND key_usage.table_schema = columns.table_schema
          AND key_usage.table_name = columns.table_name
          AND key_usage.column_name = columns.column_name
      )
  LOOP
    EXECUTE format(
      'ALTER TABLE %I ALTER COLUMN %I DROP NOT NULL',
      column_record.table_name,
      column_record.column_name
    );
  END LOOP;
END
\$\$;
''');
  }

  Future<void> _syncRelationalTables(Session session, String stateJson) async {
    final state = jsonDecode(stateJson) as Map<String, dynamic>;

    await session.db.unsafeExecute('''
TRUNCATE TABLE
  siakad_users,
  fakultas,
  prodi,
  tahun_ajaran,
  fase_krs,
  mahasiswa,
  riwayat_status_mahasiswa,
  dosen,
  mata_kuliah,
  ruangan,
  kelas,
  dosen_pengajar,
  krs,
  nilai,
  tugas,
  skripsi,
  magang,
  kkn,
  pertemuan,
  presensi,
  presensi_dosen;
''');

    await _insertRows(session, 'siakad_users', state['users'], [
      'id',
      'username',
      'password',
      'role',
      'name',
      'scopeId',
      'tingkatPimpinan',
    ]);
    await _insertRows(session, 'fakultas', state['fakultas'], ['id', 'nama']);
    await _insertRows(session, 'prodi', state['prodi'], [
      'id',
      'nama',
      'fakultasId',
    ]);
    await _insertRows(session, 'tahun_ajaran', state['tahunAjaran'], [
      'id',
      'nama',
      'semester',
      'tanggalMulai',
      'tanggalSelesai',
      'aktif',
    ]);
    await _insertRows(session, 'fase_krs', state['faseKrs'], [
      'tahunAjaranId',
      'mulai',
      'berakhir',
      'aktif',
    ]);
    await _insertRows(session, 'mahasiswa', state['mahasiswa'], [
      'nim',
      'nama',
      'jenisKelamin',
      'prodiId',
      'password',
      'pembimbingAkademikId',
      'semester',
      'email',
      'noHp',
      'alamat',
      'status',
    ]);
    await _insertRows(
      session,
      'riwayat_status_mahasiswa',
      state['riwayatStatusMahasiswa'],
      [
        'id',
        'mahasiswaId',
        'statusSebelumnya',
        'statusBaru',
        'namaBukti',
        'tipeBukti',
        'ukuranBukti',
        'buktiBase64',
        'diubahPada',
      ],
    );
    await _insertRows(session, 'dosen', state['dosen'], [
      'nidn',
      'nama',
      'prodiId',
      'password',
      'email',
      'noHp',
      'alamat',
      'keahlian',
    ]);
    await _insertRows(session, 'mata_kuliah', state['mataKuliah'], [
      'kode',
      'nama',
      'sks',
      'prodiId',
    ]);
    await _insertRows(session, 'ruangan', state['ruangan'], [
      'kodeRuangan',
      'namaRuangan',
      'kapasitasRuangan',
      'lokasi',
    ]);
    await _insertRows(session, 'kelas', state['kelas'], [
      'id',
      'mataKuliahId',
      'dosenId',
      'kapasitas',
      'hari',
      'jam',
      'ruangan',
      'tahunAjaranId',
    ]);
    await _insertRows(session, 'dosen_pengajar', state['dosenPengajar'], [
      'id',
      'idKelas',
      'nidnDosen',
      'peranMengajar',
    ]);
    await _insertRows(session, 'krs', state['krs'], [
      'id',
      'mahasiswaId',
      'kelasId',
      'semester',
      'isSubmitted',
      'isValidated',
      'isRejected',
      'catatanDosenPa',
      'tahunAjaranId',
    ]);
    await _insertRows(session, 'nilai', state['nilai'], [
      'id',
      'mahasiswaId',
      'kelasId',
      'nilaiAngka',
      'nilaiHuruf',
      'semester',
      'nilaiTugas',
      'nilaiUts',
      'nilaiUas',
      'nilaiSoftskill',
      'bobotTugas',
      'bobotUts',
      'bobotUas',
      'bobotSoftskill',
      'tahunAjaranId',
    ]);
    await _insertRows(session, 'tugas', state['tugas'], [
      'id',
      'kelasId',
      'judul',
      'deskripsi',
      'deadline',
    ]);
    await _insertRows(session, 'skripsi', state['skripsi'], [
      'id',
      'mahasiswaId',
      'judul',
      'topik',
      'pembimbingId',
      'dibuatPada',
      'status',
    ]);
    await _insertRows(session, 'magang', state['magang'], [
      'id',
      'mahasiswaId',
      'instansi',
      'posisi',
      'dibuatPada',
      'status',
    ]);
    await _insertRows(session, 'kkn', state['kkn'], [
      'id',
      'mahasiswaId',
      'lokasi',
      'tema',
      'dibuatPada',
      'status',
    ]);
    await _insertRows(session, 'pertemuan', state['pertemuan'], [
      'id',
      'kelasId',
      'pertemuanKe',
      'status',
      'materi',
      'waktuMulai',
    ]);
    await _insertRows(session, 'presensi', state['presensi'], [
      'id',
      'pertemuanId',
      'mahasiswaId',
      'statusKehadiran',
      'waktuPresensi',
      'catatan',
    ]);
    await _insertRows(session, 'presensi_dosen', state['presensiDosen'], [
      'id',
      'pertemuanId',
      'dosenId',
      'statusKehadiran',
      'waktuPresensi',
      'catatan',
    ]);
  }

  Future<void> _insertRows(
    Session session,
    String tableName,
    Object? source,
    List<String> jsonKeys,
  ) async {
    final rows = source as List<dynamic>? ?? const [];
    const chunkSize = 500;
    for (var start = 0; start < rows.length; start += chunkSize) {
      final chunk = rows
          .skip(start)
          .take(chunkSize)
          .map((rawRow) => Map<String, dynamic>.from(rawRow as Map))
          .toList();
      await session.db.unsafeExecute(
        _insertSql(tableName, jsonKeys, chunk),
      );
    }
  }

  String _insertSql(
    String tableName,
    List<String> jsonKeys,
    List<Map<String, dynamic>> rows,
  ) {
    final columns = jsonKeys.map(_columnName).toList();
    final values = rows
        .map((row) {
          final rowValues = [
            for (final key in jsonKeys) _sqlValue(row[key]),
            '${_sqlValue(jsonEncode(row))}::jsonb',
          ];
          return '(${rowValues.join(', ')})';
        })
        .join(',\n');
    return '''
INSERT INTO $tableName (${columns.join(', ')}, data)
VALUES $values
''';
  }

  String _sqlValue(Object? value) {
    if (value == null) return 'NULL';
    if (value is bool) return value ? 'true' : 'false';
    if (value is num) return '$value';
    return "'${'$value'.replaceAll("'", "''")}'";
  }

  String _columnName(String key) {
    return switch (key) {
      'scopeId' => 'scope_id',
      'tingkatPimpinan' => 'tingkat_pimpinan',
      'fakultasId' => 'fakultas_id',
      'tahunAjaranId' => 'tahun_ajaran_id',
      'tanggalMulai' => 'tanggal_mulai',
      'tanggalSelesai' => 'tanggal_selesai',
      'jenisKelamin' => 'jenis_kelamin',
      'prodiId' => 'prodi_id',
      'pembimbingAkademikId' => 'pembimbing_akademik_id',
      'mahasiswaId' => 'mahasiswa_id',
      'statusSebelumnya' => 'status_sebelumnya',
      'statusBaru' => 'status_baru',
      'namaBukti' => 'nama_bukti',
      'tipeBukti' => 'tipe_bukti',
      'ukuranBukti' => 'ukuran_bukti',
      'buktiBase64' => 'bukti_base64',
      'diubahPada' => 'diubah_pada',
      'noHp' => 'no_hp',
      'mataKuliahId' => 'mata_kuliah_id',
      'kodeRuangan' => 'kode_ruangan',
      'namaRuangan' => 'nama_ruangan',
      'kapasitasRuangan' => 'kapasitas_ruangan',
      'idKelas' => 'id_kelas',
      'nidnDosen' => 'nidn_dosen',
      'peranMengajar' => 'peran_mengajar',
      'kelasId' => 'kelas_id',
      'isSubmitted' => 'is_submitted',
      'isValidated' => 'is_validated',
      'isRejected' => 'is_rejected',
      'catatanDosenPa' => 'catatan_dosen_pa',
      'nilaiAngka' => 'nilai_angka',
      'nilaiHuruf' => 'nilai_huruf',
      'nilaiTugas' => 'nilai_tugas',
      'nilaiUts' => 'nilai_uts',
      'nilaiUas' => 'nilai_uas',
      'nilaiSoftskill' => 'nilai_softskill',
      'bobotTugas' => 'bobot_tugas',
      'bobotUts' => 'bobot_uts',
      'bobotUas' => 'bobot_uas',
      'bobotSoftskill' => 'bobot_softskill',
      'pembimbingId' => 'pembimbing_id',
      'dibuatPada' => 'dibuat_pada',
      'pertemuanKe' => 'pertemuan_ke',
      'waktuMulai' => 'waktu_mulai',
      'pertemuanId' => 'pertemuan_id',
      'statusKehadiran' => 'status_kehadiran',
      'waktuPresensi' => 'waktu_presensi',
      'dosenId' => 'dosen_id',
      _ => key,
    };
  }
}
