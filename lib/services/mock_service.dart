import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:siakad_backend_client/siakad_backend_client.dart';

import '../models/siakad_models.dart';

class DemoAccount {
  const DemoAccount({
    required this.name,
    required this.username,
    required this.password,
    required this.role,
  });

  final String name;
  final String username;
  final String password;
  final String role;
}

enum AcademicExportType { mahasiswa, dosen, mataKuliah, nilai }

extension AcademicExportTypeLabel on AcademicExportType {
  String get label {
    switch (this) {
      case AcademicExportType.mahasiswa:
        return 'Mahasiswa';
      case AcademicExportType.dosen:
        return 'Dosen';
      case AcademicExportType.mataKuliah:
        return 'Mata Kuliah';
      case AcademicExportType.nilai:
        return 'Nilai';
    }
  }

  String get fileName {
    switch (this) {
      case AcademicExportType.mahasiswa:
        return 'template_mahasiswa.csv';
      case AcademicExportType.dosen:
        return 'template_dosen.csv';
      case AcademicExportType.mataKuliah:
        return 'template_mata_kuliah.csv';
      case AcademicExportType.nilai:
        return 'template_nilai.csv';
    }
  }
}

class AcademicImportResult {
  const AcademicImportResult({
    required this.created,
    required this.updated,
    required this.skipped,
    required this.errors,
  });

  final int created;
  final int updated;
  final int skipped;
  final List<String> errors;

  String get message {
    final base =
        'Import selesai: $created dibuat, $updated diperbarui, $skipped dilewati';
    if (errors.isEmpty) return base;
    return '$base. ${errors.length} baris error.';
  }
}

enum _ImportAction { created, updated, skipped }

class _RowUpsert {
  const _RowUpsert(this.tableName, this.row);

  final String tableName;
  final Map<String, Object?> row;
}

class _RowDelete {
  const _RowDelete(this.tableName, this.id);

  final String tableName;
  final String id;
}

class _TableSnapshot {
  const _TableSnapshot(this.rows);

  final Map<String, Map<String, Object?>> rows;
}

class MockService {
  MockService._(this._client);

  static const _apiUrl = String.fromEnvironment(
    'SIAKAD_API_URL',
    defaultValue: 'http://localhost:8080/',
  );
  static const _seedAsset = 'assets/database/siakad_seed.json';

  final Client _client;
  Future<void> _saveQueue = Future.value();
  Map<String, Map<String, String>> _persistedRows = {};
  Object? _lastPersistenceError;

  Object? get lastPersistenceError => _lastPersistenceError;
  bool get hasPersistenceError => _lastPersistenceError != null;

  static Future<MockService> create() async {
    final service = MockService._(
      Client(_apiUrl, connectionTimeout: const Duration(minutes: 2)),
    );
    final stateJson = await service._client.siakadState.getState();
    if (stateJson == null || stateJson.isEmpty) {
      await service._loadSeedData();
      service._seedPertemuanDefaults();
      service._rebuildIndexes();
      await service._saveAllAsync();
    } else {
      service._loadState(service._jsonMap(jsonDecode(stateJson)));
      await service._ensureFeatureDefaults();
      service._rebuildIndexes();
    }
    service._markCurrentRowsPersisted();
    return service;
  }

  // Serverpod/PostgreSQL is the source of truth. The bundled seed is imported
  // only when the backend has no saved state yet.
  final List<User> _users = [];
  final List<Fakultas> _fakultas = [];
  final List<Prodi> _prodi = [];
  final List<TahunAjaran> _tahunAjaran = [];
  final List<Mahasiswa> _mahasiswa = [];
  final List<RiwayatStatusMahasiswa> _riwayatStatusMahasiswa = [];
  final List<Dosen> _dosen = [];
  final List<MataKuliah> _mataKuliah = [];
  final List<Ruangan> _ruangan = [];
  final List<Kelas> _kelas = [];
  final List<DosenPengajar> _dosenPengajar = [];
  final List<KRS> _krs = [];
  final List<Nilai> _nilai = [];
  final List<Tugas> _tugas = [];
  final List<Skripsi> _skripsi = [];
  final List<Magang> _magang = [];
  final List<Kkn> _kkn = [];

  final List<Pertemuan> _pertemuan = [];
  final List<Presensi> _presensi = [];
  final List<PresensiDosen> _presensiDosen = [];
  final List<FaseKrs> _faseKrs = [];
  final List<ActivityLog> _activityLogs = [];

  final Map<String, User> _usersByUsername = {};
  final Map<String, Mahasiswa> _mahasiswaByNim = {};
  final Map<String, Mahasiswa> _mahasiswaByName = {};
  final Map<String, Dosen> _dosenByNidn = {};
  final Map<String, Dosen> _dosenByName = {};
  final Map<String, Fakultas> _fakultasById = {};
  final Map<String, Prodi> _prodiById = {};
  final Map<String, List<Prodi>> _prodiByFakultas = {};
  final Map<String, List<Mahasiswa>> _mahasiswaByProdi = {};
  final Map<String, List<Dosen>> _dosenByProdi = {};
  final Map<String, List<MataKuliah>> _mataKuliahByProdi = {};
  final Map<String, MataKuliah> _mataKuliahByKode = {};
  final Map<String, Ruangan> _ruanganByKode = {};
  final Map<String, Kelas> _kelasById = {};
  final Map<String, List<Kelas>> _kelasByTahunAjaran = {};
  final Map<String, List<DosenPengajar>> _dosenPengajarByKelas = {};
  final Map<String, int> _jumlahPesertaByKelas = {};
  final Map<String, int> _totalSksByDosen = {};
  final Map<String, List<KRS>> _krsByMahasiswa = {};
  final Map<String, List<KRS>> _krsByKelas = {};
  final Map<String, List<Nilai>> _nilaiByMahasiswa = {};
  final Map<String, List<Presensi>> _presensiByMahasiswa = {};
  final Map<String, List<Pertemuan>> _pertemuanByKelas = {};
  final Map<String, List<Presensi>> _presensiByPertemuan = {};
  final Map<String, List<PresensiDosen>> _presensiDosenByPertemuan = {};
  int _dataRevision = 0;

  int get dataRevision => _dataRevision;

  // View read-only dibuat sekali agar build UI tidak terus membuat list baru.
  late final List<User> users = UnmodifiableListView(_users);
  late final List<Fakultas> fakultas = UnmodifiableListView(_fakultas);
  late final List<Prodi> prodi = UnmodifiableListView(_prodi);
  late final List<TahunAjaran> tahunAjaran = UnmodifiableListView(_tahunAjaran);
  late final List<Mahasiswa> mahasiswa = UnmodifiableListView(_mahasiswa);
  late final List<RiwayatStatusMahasiswa> riwayatStatusMahasiswa =
      UnmodifiableListView(_riwayatStatusMahasiswa);
  late final List<Dosen> dosen = UnmodifiableListView(_dosen);
  late final List<MataKuliah> mataKuliah = UnmodifiableListView(_mataKuliah);
  late final List<Ruangan> ruangan = UnmodifiableListView(_ruangan);
  late final List<Kelas> kelas = UnmodifiableListView(_kelas);
  late final List<DosenPengajar> dosenPengajar = UnmodifiableListView(
    _dosenPengajar,
  );
  late final List<KRS> krs = UnmodifiableListView(_krs);
  late final List<Nilai> nilai = UnmodifiableListView(_nilai);
  late final List<Tugas> tugas = UnmodifiableListView(_tugas);
  late final List<Skripsi> skripsi = UnmodifiableListView(_skripsi);
  late final List<Magang> magang = UnmodifiableListView(_magang);
  late final List<Kkn> kkn = UnmodifiableListView(_kkn);
  late final List<Pertemuan> pertemuan = UnmodifiableListView(_pertemuan);
  late final List<Presensi> presensi = UnmodifiableListView(_presensi);
  late final List<PresensiDosen> presensiDosen = UnmodifiableListView(
    _presensiDosen,
  );
  late final List<FaseKrs> faseKrs = UnmodifiableListView(_faseKrs);
  late final List<ActivityLog> activityLogs = UnmodifiableListView(
    _activityLogs,
  );

  void _rebuildIndexes() {
    _usersByUsername
      ..clear()
      ..addEntries(_users.map((item) => MapEntry(item.username, item)));
    _mahasiswaByNim
      ..clear()
      ..addEntries(_mahasiswa.map((item) => MapEntry(item.nim, item)));
    _mahasiswaByName
      ..clear()
      ..addEntries(_mahasiswa.map((item) => MapEntry(item.nama, item)));
    _dosenByNidn
      ..clear()
      ..addEntries(_dosen.map((item) => MapEntry(item.nidn, item)));
    _dosenByName
      ..clear()
      ..addEntries(_dosen.map((item) => MapEntry(item.nama, item)));
    _fakultasById
      ..clear()
      ..addEntries(_fakultas.map((item) => MapEntry(item.id, item)));
    _prodiById
      ..clear()
      ..addEntries(_prodi.map((item) => MapEntry(item.id, item)));

    _prodiByFakultas.clear();
    for (final item in _prodi) {
      (_prodiByFakultas[item.fakultasId] ??= []).add(item);
    }

    _mahasiswaByProdi.clear();
    for (final item in _mahasiswa) {
      (_mahasiswaByProdi[item.prodiId] ??= []).add(item);
    }

    _dosenByProdi.clear();
    for (final item in _dosen) {
      (_dosenByProdi[item.prodiId] ??= []).add(item);
    }

    _mataKuliahByProdi.clear();
    for (final item in _mataKuliah) {
      (_mataKuliahByProdi[item.prodiId] ??= []).add(item);
    }

    _mataKuliahByKode
      ..clear()
      ..addEntries(_mataKuliah.map((item) => MapEntry(item.kode, item)));
    _ruanganByKode
      ..clear()
      ..addEntries(_ruangan.map((item) => MapEntry(item.kodeRuangan, item)));
    _kelasById
      ..clear()
      ..addEntries(_kelas.map((item) => MapEntry(item.id, item)));

    _kelasByTahunAjaran.clear();
    for (final item in _kelas) {
      (_kelasByTahunAjaran[item.tahunAjaranId] ??= []).add(item);
    }

    _dosenPengajarByKelas.clear();
    for (final item in _dosenPengajar) {
      (_dosenPengajarByKelas[item.idKelas] ??= []).add(item);
    }

    _jumlahPesertaByKelas.clear();
    _krsByMahasiswa.clear();
    _krsByKelas.clear();
    for (final item in _krs) {
      _jumlahPesertaByKelas[item.kelasId] =
          (_jumlahPesertaByKelas[item.kelasId] ?? 0) + 1;
      (_krsByMahasiswa[item.mahasiswaId] ??= []).add(item);
      (_krsByKelas[item.kelasId] ??= []).add(item);
    }

    _nilaiByMahasiswa.clear();
    for (final item in _nilai) {
      (_nilaiByMahasiswa[item.mahasiswaId] ??= []).add(item);
    }

    _presensiByMahasiswa.clear();
    _presensiByPertemuan.clear();
    for (final item in _presensi) {
      (_presensiByMahasiswa[item.mahasiswaId] ??= []).add(item);
      (_presensiByPertemuan[item.pertemuanId] ??= []).add(item);
    }

    _presensiDosenByPertemuan.clear();
    for (final item in _presensiDosen) {
      (_presensiDosenByPertemuan[item.pertemuanId] ??= []).add(item);
    }

    _pertemuanByKelas.clear();
    for (final item in _pertemuan) {
      (_pertemuanByKelas[item.kelasId] ??= []).add(item);
    }

    _totalSksByDosen.clear();
    for (final kelas in _kelas) {
      final sks = _mataKuliahByKode[kelas.mataKuliahId]?.sks ?? 0;
      for (final pengajar in getDosenPengajarKelas(kelas.id)) {
        _totalSksByDosen[pengajar.nidnDosen] =
            (_totalSksByDosen[pengajar.nidnDosen] ?? 0) + sks;
      }
    }
    _dataRevision++;
  }

  List<DemoAccount> get demoAccounts {
    final accounts = <DemoAccount>[];
    void addUser(String username) {
      final user = _usersByUsername[username];
      if (user == null) return;
      accounts.add(
        DemoAccount(
          name: user.name,
          username: user.username,
          password: user.password,
          role: user.role.label,
        ),
      );
    }

    addUser('rektor@siakad.com');
    addUser('univ');
    addUser('admin-f-01');
    addUser('operator-p-0101');
    addUser('korpro-p-0101');

    for (final dosen in _dosen.take(4)) {
      accounts.add(
        DemoAccount(
          name: dosen.nama,
          username: dosen.nidn,
          password: dosen.password,
          role: 'Dosen',
        ),
      );
    }
    for (final mahasiswa in _mahasiswa.take(6)) {
      accounts.add(
        DemoAccount(
          name: mahasiswa.nama,
          username: mahasiswa.nim,
          password: mahasiswa.password,
          role: 'Mahasiswa',
        ),
      );
    }
    return accounts;
  }

  TahunAjaran get tahunAjaranAktif => _tahunAjaran.firstWhere(
    (item) => item.aktif,
    orElse: () => _tahunAjaran.last,
  );

  FaseKrs? get faseKrsTahunAktif {
    final tahunId = tahunAjaranAktif.id;
    for (final fase in _faseKrs.reversed) {
      if (fase.tahunAjaranId == tahunId) return fase;
    }
    return null;
  }

  bool get isFaseKrsBerlangsung =>
      faseKrsTahunAktif?.berlangsungPada(DateTime.now()) ?? false;

  String mulaiFaseKrs({required DateTime mulai, required DateTime berakhir}) {
    final tahunAktif = tahunAjaranAktif;
    final mulaiNormal = DateTime(mulai.year, mulai.month, mulai.day);
    final berakhirNormal = DateTime(
      berakhir.year,
      berakhir.month,
      berakhir.day,
      23,
      59,
      59,
      999,
    );
    if (berakhirNormal.isBefore(mulaiNormal)) {
      throw StateError('Batas akhir KRS tidak boleh sebelum tanggal mulai');
    }
    final akhirTahunAktif = DateTime(
      tahunAktif.tanggalSelesai.year,
      tahunAktif.tanggalSelesai.month,
      tahunAktif.tanggalSelesai.day,
      23,
      59,
      59,
      999,
    );
    if (mulaiNormal.isBefore(tahunAktif.tanggalMulai) ||
        berakhirNormal.isAfter(akhirTahunAktif)) {
      throw StateError('Fase KRS harus berada dalam tahun akademik aktif');
    }

    for (var i = 0; i < _faseKrs.length; i++) {
      if (_faseKrs[i].aktif) {
        _faseKrs[i] = _faseKrs[i].copyWith(aktif: false);
      }
    }
    _faseKrs.add(
      FaseKrs(
        tahunAjaranId: tahunAktif.id,
        mulai: mulaiNormal,
        berakhir: berakhirNormal,
      ),
    );
    return _saved('Fase KRS universitas berhasil dimulai');
  }

  String akhiriFaseKrs() {
    final fase = faseKrsTahunAktif;
    if (fase == null || !fase.aktif) {
      throw StateError('Tidak ada fase KRS aktif untuk diakhiri');
    }
    final index = _faseKrs.indexOf(fase);
    _faseKrs[index] = fase.copyWith(aktif: false);
    return _saved('Fase KRS universitas berhasil diakhiri');
  }

  void _seedPertemuanDefaults() {
    for (final k in _kelas) {
      for (int i = 1; i <= 16; i++) {
        _pertemuan.add(
          Pertemuan(
            id: 'ptm-${k.id}-$i',
            kelasId: k.id,
            pertemuanKe: i,
            status: StatusPertemuan.belumDimulai,
          ),
        );
      }
    }
  }

  Future<void> _ensureFeatureDefaults() async {
    var changed = false;
    final seed = await _readSeedData();
    final pimpinanDefaults = _seedList(
      seed,
      'users',
      _userFromJson,
    ).where((item) => item.role == Role.pimpinan);
    for (final user in pimpinanDefaults) {
      if (!_users.any((item) => item.username == user.username)) {
        _users.add(user);
        changed = true;
      }
    }
    if (_tahunAjaran.isEmpty) {
      _tahunAjaran.addAll(_seedList(seed, 'tahunAjaran', _tahunAjaranFromJson));
      changed = true;
    }
    for (final kelas in _kelas) {
      for (var nomor = 1; nomor <= 16; nomor++) {
        if (!_pertemuan.any(
          (item) => item.kelasId == kelas.id && item.pertemuanKe == nomor,
        )) {
          _pertemuan.add(
            Pertemuan(
              id: 'ptm-${kelas.id}-$nomor',
              kelasId: kelas.id,
              pertemuanKe: nomor,
              status: StatusPertemuan.belumDimulai,
            ),
          );
          changed = true;
        }
      }
    }
    if (changed) {
      _rebuildIndexes();
      await _saveAllAsync();
    }
  }

  User? login(String username, String password) {
    final uname = username.trim();

    final user = _usersByUsername[uname];
    if (user != null && user.password == password) {
      return user;
    }

    final m = _mahasiswaByNim[uname] ?? _mahasiswaByName[uname];
    if (m != null && m.password == password) {
      return User(
        id: 'u-m-${m.nim}',
        username: m.nim,
        password: m.password,
        role: Role.mahasiswa,
        name: m.nama,
        scopeId: m.nim,
      );
    }

    final d = _dosenByNidn[uname] ?? _dosenByName[uname];
    if (d != null && d.password == password) {
      return User(
        id: 'u-d-${d.nidn}',
        username: d.nidn,
        password: d.password,
        role: Role.dosen,
        name: d.nama,
        scopeId: d.nidn,
      );
    }

    return null;
  }

  void recordActivity({
    required User actor,
    required String action,
    required String target,
    required String description,
  }) {
    _addActivityLog(
      actor: actor,
      action: action,
      target: target,
      description: description,
    );
    _persistChanges();
  }

  List<ActivityLog> recentActivityLogs({int limit = 20}) {
    final ordered = _activityLogs.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return UnmodifiableListView(ordered.take(limit));
  }

  String academicCsvTemplate(AcademicExportType type) {
    return _csvRows([_academicCsvHeaders(type)]);
  }

  String exportAcademicCsv(AcademicExportType type) {
    final headers = _academicCsvHeaders(type);
    final rows = switch (type) {
      AcademicExportType.mahasiswa => _mahasiswa.map(
        (item) => [
          item.nim,
          item.nama,
          item.jenisKelamin,
          item.prodiId,
          item.pembimbingAkademikId,
          item.password,
          item.semester,
          item.email,
          item.noHp,
          item.alamat,
          item.status.label,
        ],
      ),
      AcademicExportType.dosen => _dosen.map(
        (item) => [
          item.nidn,
          item.nama,
          item.prodiId,
          item.password,
          item.email,
          item.noHp,
          item.alamat,
          item.keahlian,
        ],
      ),
      AcademicExportType.mataKuliah => _mataKuliah.map(
        (item) => [
          item.kode,
          item.nama,
          item.sks,
          item.prodiId,
          item.kategori.label,
          item.bobotTugas,
          item.bobotUts,
          item.bobotUas,
          item.bobotSoftskill,
        ],
      ),
      AcademicExportType.nilai => _nilai.map((item) {
        final kelas = _kelasById[item.kelasId];
        return [
          item.mahasiswaId,
          item.kelasId,
          kelas?.dosenId ?? '',
          kelas?.mataKuliahId ?? '',
          item.nilaiTugas,
          item.nilaiUts,
          item.nilaiUas,
          item.nilaiSoftskill,
          item.nilaiAngka,
          item.nilaiHuruf,
          item.tahunAjaranId,
        ];
      }),
    };
    return _csvRows([headers, ...rows]);
  }

  AcademicImportResult importAcademicRows(
    AcademicExportType type,
    List<Map<String, String>> rows,
  ) {
    var created = 0;
    var updated = 0;
    var skipped = 0;
    final errors = <String>[];

    for (var i = 0; i < rows.length; i++) {
      final rowNumber = i + 2;
      final row = rows[i];
      try {
        final action = switch (type) {
          AcademicExportType.mahasiswa => _importMahasiswaRow(row),
          AcademicExportType.dosen => _importDosenRow(row),
          AcademicExportType.mataKuliah => _importMataKuliahRow(row),
          AcademicExportType.nilai => _importNilaiRow(row),
        };
        switch (action) {
          case _ImportAction.created:
            created++;
          case _ImportAction.updated:
            updated++;
          case _ImportAction.skipped:
            skipped++;
        }
      } on StateError catch (error) {
        errors.add('Baris $rowNumber: ${error.message}');
      } catch (error) {
        errors.add('Baris $rowNumber: $error');
      }
    }

    if (created > 0 || updated > 0) {
      _addActivityLog(
        actor: null,
        action: 'Import Data',
        target: type.label,
        description:
            'Import ${type.label}: $created dibuat, $updated diperbarui',
      );
      _rebuildIndexes();
      _saveDelta();
    }

    return AcademicImportResult(
      created: created,
      updated: updated,
      skipped: skipped,
      errors: errors,
    );
  }

  _ImportAction _importMahasiswaRow(Map<String, String> row) {
    final nim = _cell(row, 'nim');
    if (nim.isEmpty) return _ImportAction.skipped;
    final nama = _requiredCell(row, 'nama');
    final prodiId = _requiredCell(row, 'prodiId');
    final jenisKelamin = _cell(row, 'jenisKelamin', fallback: 'L');
    final pembimbingId = _cell(row, 'pembimbingAkademikId');
    _ensureExists(_prodi.any((item) => item.id == prodiId), 'Prodi');
    final dosenProdi = _dosen.where((item) => item.prodiId == prodiId).toList();
    if (pembimbingId.isEmpty && dosenProdi.isEmpty) {
      throw StateError('Dosen PA wajib diisi karena prodi belum punya dosen');
    }
    final resolvedPembimbing = pembimbingId.isNotEmpty
        ? pembimbingId
        : dosenProdi.first.nidn;
    _ensureDosenPaValid(prodiId, resolvedPembimbing);

    final existingIndex = _mahasiswa.indexWhere((item) => item.nim == nim);
    final mahasiswa = Mahasiswa(
      nim: nim,
      nama: nama,
      jenisKelamin: jenisKelamin,
      prodiId: prodiId,
      password: _cell(row, 'password', fallback: 'password'),
      pembimbingAkademikId: resolvedPembimbing,
      semester: int.tryParse(_cell(row, 'semester', fallback: '1')) ?? 1,
      email: _cell(row, 'email'),
      noHp: _cell(row, 'noHp'),
      alamat: _cell(row, 'alamat'),
      status: _statusMahasiswaFromLabel(_cell(row, 'status')),
    );

    if (existingIndex == -1) {
      _mahasiswa.add(mahasiswa);
      return _ImportAction.created;
    }
    _mahasiswa[existingIndex] = mahasiswa;
    return _ImportAction.updated;
  }

  _ImportAction _importDosenRow(Map<String, String> row) {
    final nidn = _cell(row, 'nidn');
    if (nidn.isEmpty) return _ImportAction.skipped;
    final nama = _requiredCell(row, 'nama');
    final prodiId = _requiredCell(row, 'prodiId');
    _ensureExists(_prodi.any((item) => item.id == prodiId), 'Prodi');

    final existingIndex = _dosen.indexWhere((item) => item.nidn == nidn);
    final dosen = Dosen(
      nidn: nidn,
      nama: nama,
      prodiId: prodiId,
      password: _cell(row, 'password', fallback: 'password'),
      email: _cell(row, 'email'),
      noHp: _cell(row, 'noHp'),
      alamat: _cell(row, 'alamat'),
      keahlian: _cell(row, 'keahlian'),
    );

    if (existingIndex == -1) {
      _dosen.add(dosen);
      return _ImportAction.created;
    }
    _dosen[existingIndex] = dosen;
    return _ImportAction.updated;
  }

  _ImportAction _importMataKuliahRow(Map<String, String> row) {
    final kode = _cell(row, 'kode');
    if (kode.isEmpty) return _ImportAction.skipped;
    final nama = _requiredCell(row, 'nama');
    final prodiId = _requiredCell(row, 'prodiId');
    final sks = int.tryParse(_requiredCell(row, 'sks')) ?? 0;
    final kategori = _kategoriFromLabel(_cell(row, 'kategori'));
    final bobotTugas = double.tryParse(_cell(row, 'bobotTugas')) ?? 25;
    final bobotUts = double.tryParse(_cell(row, 'bobotUts')) ?? 25;
    final bobotUas = double.tryParse(_cell(row, 'bobotUas')) ?? 35;
    final bobotSoftskill = double.tryParse(_cell(row, 'bobotSoftskill')) ?? 15;
    if (sks <= 0) throw StateError('SKS harus lebih dari 0');
    _ensureExists(_prodi.any((item) => item.id == prodiId), 'Prodi');
    _ensureBobotNilaiValid(
      bobotTugas: bobotTugas,
      bobotUts: bobotUts,
      bobotUas: bobotUas,
      bobotSoftskill: bobotSoftskill,
    );

    final existingIndex = _mataKuliah.indexWhere((item) => item.kode == kode);
    final mataKuliah = MataKuliah(
      kode: kode,
      nama: nama,
      sks: sks,
      prodiId: prodiId,
      kategori: kategori,
      bobotTugas: bobotTugas,
      bobotUts: bobotUts,
      bobotUas: bobotUas,
      bobotSoftskill: bobotSoftskill,
    );

    if (existingIndex == -1) {
      _mataKuliah.add(mataKuliah);
      return _ImportAction.created;
    }
    _mataKuliah[existingIndex] = mataKuliah;
    return _ImportAction.updated;
  }

  _ImportAction _importNilaiRow(Map<String, String> row) {
    final mahasiswaId = _cell(row, 'mahasiswaId');
    final kelasId = _cell(row, 'kelasId');
    if (mahasiswaId.isEmpty || kelasId.isEmpty) return _ImportAction.skipped;
    final kelas = _kelasById[kelasId];
    if (kelas == null) throw StateError('Kelas tidak ditemukan');
    final dosenId = _cell(row, 'dosenId', fallback: kelas.dosenId);
    final before = _nilai.any(
      (item) => item.mahasiswaId == mahasiswaId && item.kelasId == kelasId,
    );
    inputNilai(
      dosenId: dosenId,
      mahasiswaId: mahasiswaId,
      kelasId: kelasId,
      angka: double.tryParse(_cell(row, 'nilaiAkhir', fallback: '0')) ?? 0,
      tugas: double.tryParse(_cell(row, 'nilaiTugas')),
      uts: double.tryParse(_cell(row, 'nilaiUts')),
      uas: double.tryParse(_cell(row, 'nilaiUas')),
      softskill: double.tryParse(_cell(row, 'nilaiSoftskill')),
    );
    return before ? _ImportAction.updated : _ImportAction.created;
  }

  List<String> _academicCsvHeaders(AcademicExportType type) {
    return switch (type) {
      AcademicExportType.mahasiswa => [
        'nim',
        'nama',
        'jenisKelamin',
        'prodiId',
        'pembimbingAkademikId',
        'password',
        'semester',
        'email',
        'noHp',
        'alamat',
        'status',
      ],
      AcademicExportType.dosen => [
        'nidn',
        'nama',
        'prodiId',
        'password',
        'email',
        'noHp',
        'alamat',
        'keahlian',
      ],
      AcademicExportType.mataKuliah => [
        'kode',
        'nama',
        'sks',
        'prodiId',
        'kategori',
        'bobotTugas',
        'bobotUts',
        'bobotUas',
        'bobotSoftskill',
      ],
      AcademicExportType.nilai => [
        'mahasiswaId',
        'kelasId',
        'dosenId',
        'mataKuliahId',
        'nilaiTugas',
        'nilaiUts',
        'nilaiUas',
        'nilaiSoftskill',
        'nilaiAkhir',
        'nilaiHuruf',
        'tahunAjaranId',
      ],
    };
  }

  String _csvRows(Iterable<Iterable<Object?>> rows) {
    return rows.map((row) => row.map(_csvCell).join(',')).join('\r\n');
  }

  String _csvCell(Object? value) {
    final text = '${value ?? ''}';
    final escaped = text.replaceAll('"', '""');
    return RegExp(r'[",\r\n]').hasMatch(escaped) ? '"$escaped"' : escaped;
  }

  String _cell(Map<String, String> row, String key, {String fallback = ''}) {
    final direct = row[key];
    if (direct != null) return direct.trim();
    final normalizedKey = _normalizeImportHeader(key);
    for (final entry in row.entries) {
      if (_normalizeImportHeader(entry.key) == normalizedKey) {
        return entry.value.trim();
      }
    }
    return fallback;
  }

  String _requiredCell(Map<String, String> row, String key) {
    final value = _cell(row, key);
    if (value.isEmpty) throw StateError('Kolom $key wajib diisi');
    return value;
  }

  String _normalizeImportHeader(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  StatusMahasiswa _statusMahasiswaFromLabel(String value) {
    final normalized = _normalizeImportHeader(value);
    return StatusMahasiswa.values.firstWhere(
      (item) =>
          _normalizeImportHeader(item.name) == normalized ||
          _normalizeImportHeader(item.label) == normalized,
      orElse: () => StatusMahasiswa.aktif,
    );
  }

  KategoriMataKuliah _kategoriFromLabel(String value) {
    final normalized = _normalizeImportHeader(value);
    return KategoriMataKuliah.values.firstWhere(
      (item) =>
          _normalizeImportHeader(item.name) == normalized ||
          _normalizeImportHeader(item.label) == normalized,
      orElse: () => KategoriMataKuliah.reguler,
    );
  }

  String addFakultas(String nama, String adminUsername, String adminPassword) {
    // Admin universitas menambah fakultas sekaligus akun admin fakultasnya.
    _ensureNotBlank(nama, 'Nama fakultas');
    _ensureNotBlank(adminUsername, 'Username admin fakultas');
    _ensureNotBlank(adminPassword, 'Password admin fakultas');
    if (_fakultas.any(
      (item) => item.nama.toLowerCase() == nama.toLowerCase(),
    )) {
      throw StateError('Fakultas sudah ada');
    }
    if (_users.any(
      (item) => item.username.toLowerCase() == adminUsername.toLowerCase(),
    )) {
      throw StateError('Username admin sudah terdaftar');
    }
    final fakultasId = _nextId('f', _fakultas.length);
    _fakultas.add(Fakultas(id: fakultasId, nama: nama));

    _users.add(
      User(
        id: _nextId('u', _users.length),
        username: adminUsername,
        password: adminPassword,
        role: Role.adminFakultas,
        name: 'Admin $nama',
        scopeId: fakultasId,
      ),
    );
    return _saved('Fakultas dan Admin berhasil ditambahkan');
  }

  String addProdi(
    String nama,
    String fakultasId,
    String adminUsername,
    String adminPassword,
  ) {
    // Admin fakultas menambah prodi dan membuat akun operator prodi.
    _ensureNotBlank(nama, 'Nama prodi');
    _ensureNotBlank(adminUsername, 'Username admin prodi');
    _ensureNotBlank(adminPassword, 'Password admin prodi');
    _ensureExists(_fakultas.any((item) => item.id == fakultasId), 'Fakultas');
    if (_prodi.any(
      (item) =>
          item.fakultasId == fakultasId &&
          item.nama.toLowerCase() == nama.toLowerCase(),
    )) {
      throw StateError('Prodi sudah ada di fakultas ini');
    }
    if (_users.any(
      (item) => item.username.toLowerCase() == adminUsername.toLowerCase(),
    )) {
      throw StateError('Username admin sudah terdaftar');
    }
    final prodiId = _nextId('p', _prodi.length);
    _prodi.add(Prodi(id: prodiId, nama: nama, fakultasId: fakultasId));

    _users.add(
      User(
        id: _nextId('u', _users.length),
        username: adminUsername,
        password: adminPassword,
        role: Role.adminProdi,
        name: 'Admin $nama',
        scopeId: prodiId,
      ),
    );
    return _saved('Prodi dan Admin berhasil ditambahkan');
  }

  String updateProdi(String id, String nama, String fakultasId) {
    _ensureNotBlank(nama, 'Nama prodi');
    final index = _prodi.indexWhere((item) => item.id == id);
    if (index == -1) throw StateError('Prodi tidak ditemukan');
    _ensureExists(_fakultas.any((item) => item.id == fakultasId), 'Fakultas');
    _prodi[index] = Prodi(id: id, nama: nama, fakultasId: fakultasId);
    return _saved('Prodi berhasil diperbarui');
  }

  String deleteProdi(String id) {
    // Prodi tidak boleh dihapus jika masih dipakai oleh data akademik.
    if (_mahasiswa.any((item) => item.prodiId == id) ||
        _dosen.any((item) => item.prodiId == id) ||
        _mataKuliah.any((item) => item.prodiId == id)) {
      throw StateError('Prodi masih memiliki data akademik');
    }
    _prodi.removeWhere((item) => item.id == id);
    _users.removeWhere(
      (item) => item.role == Role.adminProdi && item.scopeId == id,
    );
    return _saved('Prodi berhasil dihapus');
  }

  String addMahasiswa(
    String nim,
    String nama,
    String jenisKelamin,
    String prodiId,
    String pembimbingAkademikId,
  ) {
    // Operator prodi menambahkan mahasiswa dengan password awal default.
    _ensureNotBlank(nim, 'NIM');
    _ensureNotBlank(nama, 'Nama mahasiswa');
    _ensureNotBlank(jenisKelamin, 'Jenis kelamin');
    _ensureExists(_prodi.any((item) => item.id == prodiId), 'Prodi');
    _ensureDosenPaValid(prodiId, pembimbingAkademikId);
    if (_mahasiswa.any((item) => item.nim == nim)) {
      throw StateError('NIM mahasiswa sudah terdaftar');
    }
    final mahasiswa = Mahasiswa(
      nim: nim,
      nama: nama,
      jenisKelamin: jenisKelamin,
      prodiId: prodiId,
      password: 'password',
      pembimbingAkademikId: pembimbingAkademikId,
      semester: 1,
    );
    _mahasiswa.add(mahasiswa);

    return _savedRows(
      'Mahasiswa berhasil ditambahkan (Password default: password)',
      upserts: [_rowUpsert('mahasiswa', _mahasiswaToJson(mahasiswa))],
    );
  }

  String updateMahasiswa({
    required String nim,
    required String nama,
    required String jenisKelamin,
    required String prodiId,
    required String pembimbingAkademikId,
  }) {
    _ensureNotBlank(nama, 'Nama mahasiswa');
    _ensureNotBlank(jenisKelamin, 'Jenis kelamin');
    final index = _mahasiswa.indexWhere((item) => item.nim == nim);
    if (index == -1) throw StateError('Mahasiswa tidak ditemukan');
    _ensureDosenPaValid(prodiId, pembimbingAkademikId);
    final mahasiswa = Mahasiswa(
      nim: nim,
      nama: nama,
      jenisKelamin: jenisKelamin,
      prodiId: prodiId,
      password: _mahasiswa[index].password,
      pembimbingAkademikId: pembimbingAkademikId,
      semester: _mahasiswa[index].semester,
      email: _mahasiswa[index].email,
      noHp: _mahasiswa[index].noHp,
      alamat: _mahasiswa[index].alamat,
      status: _mahasiswa[index].status,
    );
    _mahasiswa[index] = mahasiswa;
    return _savedRows(
      'Mahasiswa berhasil diperbarui',
      upserts: [_rowUpsert('mahasiswa', _mahasiswaToJson(mahasiswa))],
    );
  }

  String updateProfilMahasiswa({
    required String nim,
    required String jenisKelamin,
    required int semester,
    required String email,
    required String noHp,
    required String alamat,
  }) {
    _ensureNotBlank(jenisKelamin, 'Jenis kelamin');
    if (semester < 1 || semester > 14) {
      throw StateError('Semester harus berada di rentang 1-14');
    }
    final index = _mahasiswa.indexWhere((item) => item.nim == nim);
    if (index == -1) throw StateError('Mahasiswa tidak ditemukan');

    final mahasiswa = _mahasiswa[index].copyWith(
      jenisKelamin: jenisKelamin,
      semester: semester,
      email: email.trim(),
      noHp: noHp.trim(),
      alamat: alamat.trim(),
    );
    _mahasiswa[index] = mahasiswa;
    return _savedRows(
      'Profil berhasil diperbarui',
      upserts: [_rowUpsert('mahasiswa', _mahasiswaToJson(mahasiswa))],
    );
  }

  String deleteMahasiswa(String nim) {
    // Mahasiswa hanya bisa dihapus jika belum punya KRS aktif.
    _ensureExists(
      !_krs.any((item) => item.mahasiswaId == nim),
      'Mahasiswa tanpa KRS aktif',
    );
    final nilaiIds = _nilai
        .where((item) => item.mahasiswaId == nim)
        .map((item) => item.id)
        .toList();
    final presensiIds = _presensi
        .where((item) => item.mahasiswaId == nim)
        .map((item) => item.id)
        .toList();
    final riwayatIds = _riwayatStatusMahasiswa
        .where((item) => item.mahasiswaId == nim)
        .map((item) => item.id)
        .toList();
    _mahasiswa.removeWhere((item) => item.nim == nim);
    _nilai.removeWhere((item) => item.mahasiswaId == nim);
    _presensi.removeWhere((item) => item.mahasiswaId == nim);
    _riwayatStatusMahasiswa.removeWhere((item) => item.mahasiswaId == nim);
    return _savedRows(
      'Mahasiswa berhasil dihapus',
      deletes: [
        for (final id in nilaiIds) _RowDelete('nilai', id),
        for (final id in presensiIds) _RowDelete('presensi', id),
        for (final id in riwayatIds) _RowDelete('riwayat_status_mahasiswa', id),
        _RowDelete('mahasiswa', nim),
      ],
    );
  }

  String ubahStatusMahasiswa({
    required String nim,
    required StatusMahasiswa statusBaru,
    required String namaBukti,
    required List<int> buktiBytes,
  }) {
    const maxBuktiBytes = 5 * 1024 * 1024;
    final index = _mahasiswa.indexWhere((item) => item.nim == nim);
    if (index == -1) throw StateError('Mahasiswa tidak ditemukan');
    if (_mahasiswa[index].status == statusBaru) {
      throw StateError('Pilih status yang berbeda dari status saat ini');
    }
    _ensureNotBlank(namaBukti, 'Bukti perubahan status');
    if (buktiBytes.isEmpty) {
      throw StateError('Bukti perubahan status wajib diunggah');
    }
    if (buktiBytes.length > maxBuktiBytes) {
      throw StateError('Ukuran bukti maksimal 5 MB');
    }
    final extension = namaBukti.split('.').last.toLowerCase();
    const allowedExtensions = {'pdf', 'jpg', 'jpeg', 'png'};
    if (!allowedExtensions.contains(extension)) {
      throw StateError('Bukti harus berupa PDF, JPG, JPEG, atau PNG');
    }

    final statusSebelumnya = _mahasiswa[index].status;
    final mahasiswa = _mahasiswa[index].copyWith(status: statusBaru);
    final riwayat = RiwayatStatusMahasiswa(
      id: _nextId('rsm', _riwayatStatusMahasiswa.length),
      mahasiswaId: nim,
      statusSebelumnya: statusSebelumnya,
      statusBaru: statusBaru,
      namaBukti: namaBukti.trim(),
      tipeBukti: extension,
      ukuranBukti: buktiBytes.length,
      buktiBase64: base64Encode(buktiBytes),
      diubahPada: DateTime.now(),
    );
    _mahasiswa[index] = mahasiswa;
    _riwayatStatusMahasiswa.add(riwayat);
    return _savedRows(
      'Status mahasiswa berhasil diperbarui',
      upserts: [
        _rowUpsert('mahasiswa', _mahasiswaToJson(mahasiswa)),
        _rowUpsert(
          'riwayat_status_mahasiswa',
          _riwayatStatusMahasiswaToJson(riwayat),
        ),
      ],
    );
  }

  List<RiwayatStatusMahasiswa> getRiwayatStatusMahasiswa(String nim) {
    final items = _riwayatStatusMahasiswa
        .where((item) => item.mahasiswaId == nim)
        .toList();
    items.sort((a, b) => b.diubahPada.compareTo(a.diubahPada));
    return items;
  }

  String addDosen(String nidn, String nama, String prodiId) {
    // Dosen baru didaftarkan ke prodi dan diberi password awal default.
    _ensureNotBlank(nidn, 'NIDN');
    _ensureNotBlank(nama, 'Nama dosen');
    _ensureExists(_prodi.any((item) => item.id == prodiId), 'Prodi');
    if (_dosen.any((item) => item.nidn == nidn)) {
      throw StateError('NIDN dosen sudah terdaftar');
    }
    _dosen.add(
      Dosen(nidn: nidn, nama: nama, prodiId: prodiId, password: 'password'),
    );

    return _saved('Dosen berhasil ditambahkan (Password default: password)');
  }

  String updateDosen({
    required String nidn,
    required String nama,
    required String prodiId,
  }) {
    _ensureNotBlank(nama, 'Nama dosen');
    final index = _dosen.indexWhere((item) => item.nidn == nidn);
    if (index == -1) throw StateError('Dosen tidak ditemukan');
    _dosen[index] = Dosen(
      nidn: nidn,
      nama: nama,
      prodiId: prodiId,
      password: _dosen[index].password,
      email: _dosen[index].email,
      noHp: _dosen[index].noHp,
      alamat: _dosen[index].alamat,
      keahlian: _dosen[index].keahlian,
    );
    return _saved('Dosen berhasil diperbarui');
  }

  String updateProfilDosen({
    required String nidn,
    required String email,
    required String noHp,
    required String alamat,
    required String keahlian,
  }) {
    final index = _dosen.indexWhere((item) => item.nidn == nidn);
    if (index == -1) throw StateError('Dosen tidak ditemukan');

    _dosen[index] = _dosen[index].copyWith(
      email: email.trim(),
      noHp: noHp.trim(),
      alamat: alamat.trim(),
      keahlian: keahlian.trim(),
    );
    return _saved('Profil dosen berhasil diperbarui');
  }

  String deleteDosen(String nidn) {
    // Dosen tidak boleh dihapus jika masih menjadi pengampu kelas.
    _ensureExists(
      !_kelas.any((item) => item.dosenId == nidn) &&
          !_dosenPengajar.any((item) => item.nidnDosen == nidn),
      'Dosen tanpa kelas aktif',
    );
    _dosen.removeWhere((item) => item.nidn == nidn);
    return _saved('Dosen berhasil dihapus');
  }

  String addAdmin(String username, String nama, Role role, String scopeId) {
    _ensureNotBlank(username, 'Username');
    _ensureNotBlank(nama, 'Nama admin');
    if (_users.any((item) => item.username == username)) {
      throw StateError('Username sudah terdaftar');
    }
    _users.add(
      User(
        id: _nextId('u', _users.length),
        username: username,
        password: 'password', // Default password
        role: role,
        name: nama,
        scopeId: scopeId,
      ),
    );
    return _saved('${role.label} berhasil ditambahkan');
  }

  String addMataKuliah(
    String kode,
    String nama,
    int sks,
    String prodiId, {
    KategoriMataKuliah kategori = KategoriMataKuliah.reguler,
    double bobotTugas = 25,
    double bobotUts = 25,
    double bobotUas = 35,
    double bobotSoftskill = 15,
  }) {
    // Mata kuliah menjadi dasar pembukaan kelas kuliah.
    _ensureNotBlank(kode, 'Kode mata kuliah');
    _ensureNotBlank(nama, 'Nama mata kuliah');
    if (sks <= 0) throw StateError('SKS harus lebih dari 0');
    _ensureBobotNilaiValid(
      bobotTugas: bobotTugas,
      bobotUts: bobotUts,
      bobotUas: bobotUas,
      bobotSoftskill: bobotSoftskill,
    );
    _ensureExists(_prodi.any((item) => item.id == prodiId), 'Prodi');
    if (_mataKuliah.any((item) => item.kode == kode)) {
      throw StateError('Kode mata kuliah sudah ada');
    }
    _mataKuliah.add(
      MataKuliah(
        kode: kode,
        nama: nama,
        sks: sks,
        prodiId: prodiId,
        kategori: kategori,
        bobotTugas: bobotTugas,
        bobotUts: bobotUts,
        bobotUas: bobotUas,
        bobotSoftskill: bobotSoftskill,
      ),
    );
    return _saved('Mata kuliah berhasil ditambahkan');
  }

  String updateMataKuliah({
    required String kode,
    required String nama,
    required int sks,
    required String prodiId,
    required KategoriMataKuliah kategori,
    required double bobotTugas,
    required double bobotUts,
    required double bobotUas,
    required double bobotSoftskill,
  }) {
    _ensureNotBlank(nama, 'Nama mata kuliah');
    if (sks <= 0) throw StateError('SKS harus lebih dari 0');
    _ensureBobotNilaiValid(
      bobotTugas: bobotTugas,
      bobotUts: bobotUts,
      bobotUas: bobotUas,
      bobotSoftskill: bobotSoftskill,
    );
    final index = _mataKuliah.indexWhere((item) => item.kode == kode);
    if (index == -1) throw StateError('Mata kuliah tidak ditemukan');
    _mataKuliah[index] = MataKuliah(
      kode: kode,
      nama: nama,
      sks: sks,
      prodiId: prodiId,
      kategori: kategori,
      bobotTugas: bobotTugas,
      bobotUts: bobotUts,
      bobotUas: bobotUas,
      bobotSoftskill: bobotSoftskill,
    );
    return _saved('Mata kuliah berhasil diperbarui');
  }

  String deleteMataKuliah(String kode) {
    // Mata kuliah yang sudah dipakai kelas tidak boleh dihapus.
    if (_kelas.any((item) => item.mataKuliahId == kode)) {
      throw StateError('Mata kuliah masih dipakai pada kelas kuliah');
    }
    _mataKuliah.removeWhere((item) => item.kode == kode);
    return _saved('Mata kuliah berhasil dihapus');
  }

  String addRuangan({
    required String kodeRuangan,
    required String namaRuangan,
    required int kapasitasRuangan,
    required String lokasi,
  }) {
    _ensureNotBlank(kodeRuangan, 'Kode ruangan');
    _ensureNotBlank(namaRuangan, 'Nama ruangan');
    _ensureNotBlank(lokasi, 'Lokasi ruangan');
    if (kapasitasRuangan <= 0) {
      throw StateError('Kapasitas ruangan harus lebih dari 0');
    }
    if (_ruangan.any(
      (item) =>
          item.kodeRuangan.toLowerCase() == kodeRuangan.trim().toLowerCase(),
    )) {
      throw StateError('Kode ruangan sudah terdaftar');
    }

    _ruangan.add(
      Ruangan(
        kodeRuangan: kodeRuangan.trim().toUpperCase(),
        namaRuangan: namaRuangan.trim(),
        kapasitasRuangan: kapasitasRuangan,
        lokasi: lokasi.trim(),
      ),
    );
    return _saved('Ruangan berhasil ditambahkan');
  }

  String updateRuangan({
    required String kodeRuangan,
    required String namaRuangan,
    required int kapasitasRuangan,
    required String lokasi,
  }) {
    _ensureNotBlank(namaRuangan, 'Nama ruangan');
    _ensureNotBlank(lokasi, 'Lokasi ruangan');
    if (kapasitasRuangan <= 0) {
      throw StateError('Kapasitas ruangan harus lebih dari 0');
    }
    final index = _ruangan.indexWhere(
      (item) => item.kodeRuangan == kodeRuangan,
    );
    if (index == -1) throw StateError('Ruangan tidak ditemukan');
    final maxKapasitasKelas = _kelas
        .where((item) => item.ruangan == kodeRuangan)
        .fold<int>(
          0,
          (max, item) => item.kapasitas > max ? item.kapasitas : max,
        );
    if (kapasitasRuangan < maxKapasitasKelas) {
      throw StateError(
        'Kapasitas ruangan tidak boleh kurang dari kapasitas kelas aktif',
      );
    }

    _ruangan[index] = Ruangan(
      kodeRuangan: kodeRuangan,
      namaRuangan: namaRuangan.trim(),
      kapasitasRuangan: kapasitasRuangan,
      lokasi: lokasi.trim(),
    );
    return _saved('Ruangan berhasil diperbarui');
  }

  String deleteRuangan(String kodeRuangan) {
    if (_kelas.any((item) => item.ruangan == kodeRuangan)) {
      throw StateError('Ruangan masih digunakan kelas kuliah');
    }
    _ruangan.removeWhere((item) => item.kodeRuangan == kodeRuangan);
    return _saved('Ruangan berhasil dihapus');
  }

  String openKelas({
    required String mataKuliahId,
    required List<String> dosenIds,
    required int kapasitas,
    required String hari,
    required String jam,
    required String ruangan,
  }) {
    // Membuka kelas berarti memilih mata kuliah, para dosen, kapasitas, dan jadwal.
    final pengajarIds = dosenIds.toSet().toList();
    _ensureExists(
      _mataKuliah.any((item) => item.kode == mataKuliahId),
      'Mata kuliah',
    );
    if (pengajarIds.isEmpty) {
      throw StateError('Pilih minimal satu dosen pengajar');
    }
    for (final dosenId in pengajarIds) {
      _ensureExists(_dosen.any((item) => item.nidn == dosenId), 'Dosen');
    }
    if (kapasitas <= 0) throw StateError('Kapasitas harus lebih dari 0');
    _ensureNotBlank(hari, 'Hari');
    _ensureNotBlank(jam, 'Jam');
    _ensureNotBlank(ruangan, 'Ruangan');
    _ensureRuanganAvailable(
      kodeRuangan: ruangan,
      kapasitasKelas: kapasitas,
      hari: hari,
      jam: jam,
    );
    for (final dosenId in pengajarIds) {
      _ensureDosenAvailable(dosenId: dosenId, hari: hari, jam: jam);
    }
    final newKelasId = _nextId('k', _kelas.length);
    _kelas.add(
      Kelas(
        id: newKelasId,
        mataKuliahId: mataKuliahId,
        dosenId: pengajarIds.first,
        kapasitas: kapasitas,
        hari: hari,
        jam: jam,
        ruangan: ruangan.trim().toUpperCase(),
        tahunAjaranId: tahunAjaranAktif.id,
      ),
    );
    _syncDosenPengajar(newKelasId, pengajarIds);

    // Setelah kelas dibuat, 16 slot pertemuan ikut dibuat untuk presensi.
    for (int i = 1; i <= 16; i++) {
      _pertemuan.add(
        Pertemuan(
          id: 'ptm-$newKelasId-$i',
          kelasId: newKelasId,
          pertemuanKe: i,
          status: StatusPertemuan.belumDimulai,
        ),
      );
    }

    return _saved('Kelas berhasil dibuka');
  }

  String updateKelas({
    required String id,
    required String mataKuliahId,
    required List<String> dosenIds,
    required int kapasitas,
    required String hari,
    required String jam,
    required String ruangan,
  }) {
    final index = _kelas.indexWhere((item) => item.id == id);
    if (index == -1) throw StateError('Kelas tidak ditemukan');
    final pengajarIds = dosenIds.toSet().toList();
    if (pengajarIds.isEmpty) {
      throw StateError('Pilih minimal satu dosen pengajar');
    }
    final jumlahPeserta = getJumlahPesertaKelas(id);
    if (kapasitas < jumlahPeserta) {
      throw StateError('Kapasitas tidak boleh kurang dari jumlah peserta');
    }
    _ensureExists(
      _mataKuliah.any((item) => item.kode == mataKuliahId),
      'Mata kuliah',
    );
    for (final dosenId in pengajarIds) {
      _ensureExists(_dosen.any((item) => item.nidn == dosenId), 'Dosen');
    }
    _ensureRuanganAvailable(
      kodeRuangan: ruangan,
      kapasitasKelas: kapasitas,
      hari: hari,
      jam: jam,
      ignoreKelasId: id,
    );
    for (final dosenId in pengajarIds) {
      _ensureDosenAvailable(
        dosenId: dosenId,
        hari: hari,
        jam: jam,
        ignoreKelasId: id,
      );
    }
    _kelas[index] = Kelas(
      id: id,
      mataKuliahId: mataKuliahId,
      dosenId: pengajarIds.first,
      kapasitas: kapasitas,
      hari: hari,
      jam: jam,
      ruangan: ruangan.trim().toUpperCase(),
      tahunAjaranId: _kelas[index].tahunAjaranId,
    );
    _syncDosenPengajar(id, pengajarIds);
    return _saved('Kelas berhasil diperbarui');
  }

  String deleteKelas(String id) {
    if (_krs.any((item) => item.kelasId == id)) {
      throw StateError('Kelas masih memiliki peserta KRS');
    }
    _kelas.removeWhere((item) => item.id == id);
    _dosenPengajar.removeWhere((item) => item.idKelas == id);
    _pertemuan.removeWhere((item) => item.kelasId == id);
    _tugas.removeWhere((item) => item.kelasId == id);
    return _saved('Kelas berhasil dihapus');
  }

  String takeKrs(String mahasiswaId, String kelasId) {
    // Alur KRS: pastikan mahasiswa dan kelas valid, prodinya sama,
    // kapasitas belum penuh, lalu simpan relasi mahasiswa-kelas.
    _ensureExists(
      _mahasiswa.any((item) => item.nim == mahasiswaId),
      'Mahasiswa',
    );
    _ensureExists(_kelas.any((item) => item.id == kelasId), 'Kelas');
    final mahasiswa = _mahasiswa.firstWhere((item) => item.nim == mahasiswaId);
    final kelas = _kelas.firstWhere((item) => item.id == kelasId);
    _ensureFaseKrsOpen(kelas.tahunAjaranId);
    final mataKuliah = _mataKuliah.firstWhere(
      (item) => item.kode == kelas.mataKuliahId,
    );
    if (mahasiswa.prodiId != mataKuliah.prodiId) {
      throw StateError('Mahasiswa hanya bisa mengambil kelas dari prodinya');
    }
    if (isKelasPenuh(kelasId)) {
      throw StateError('Kapasitas kelas sudah penuh');
    }
    if (_krs.any(
      (item) =>
          item.mahasiswaId == mahasiswaId &&
          item.kelasId == kelasId &&
          item.semester == mahasiswa.semester,
    )) {
      throw StateError('Kelas sudah ada di KRS');
    }
    final krsSemesterIni = _krs.where(
      (item) =>
          item.mahasiswaId == mahasiswaId &&
          item.semester == mahasiswa.semester &&
          item.tahunAjaranId == kelas.tahunAjaranId,
    );
    var totalSks = mataKuliah.sks;
    for (final item in krsSemesterIni) {
      final existingKelas = _kelasById[item.kelasId];
      final existingMk = existingKelas == null
          ? null
          : _mataKuliahByKode[existingKelas.mataKuliahId];
      totalSks += existingMk?.sks ?? 0;
      if (existingKelas != null &&
          existingKelas.hari.toLowerCase() == kelas.hari.trim().toLowerCase() &&
          _isJamBentrok(existingKelas.jam, kelas.jam)) {
        throw StateError('Jadwal kelas bentrok dengan KRS yang sudah dipilih');
      }
    }
    if (totalSks > 24) {
      throw StateError('Total KRS maksimal 24 SKS');
    }
    if (_krs.any(
      (item) =>
          item.mahasiswaId == mahasiswaId &&
          item.semester == mahasiswa.semester &&
          (item.isSubmitted || item.isValidated),
    )) {
      throw StateError('KRS yang sudah diajukan/disetujui tidak bisa diubah');
    }
    _krs.add(
      KRS(
        id: _nextId('krs', _krs.length),
        mahasiswaId: mahasiswaId,
        kelasId: kelasId,
        semester: mahasiswa.semester,
        isSubmitted: false,
        isValidated: false,
        tahunAjaranId: _kelas
            .firstWhere((item) => item.id == kelasId)
            .tahunAjaranId,
      ),
    );
    return _saved('KRS berhasil disimpan sebagai draft');
  }

  String submitKrs(String mahasiswaId, int semester) {
    _ensureFaseKrsOpen(tahunAjaranAktif.id);
    final indexList = <int>[];
    for (int i = 0; i < _krs.length; i++) {
      final item = _krs[i];
      if (item.mahasiswaId == mahasiswaId &&
          item.semester == semester &&
          item.tahunAjaranId == tahunAjaranAktif.id) {
        indexList.add(i);
      }
    }
    if (indexList.isEmpty) {
      throw StateError('Isi KRS terlebih dahulu sebelum diajukan');
    }
    if (indexList.every((index) => _krs[index].isValidated)) {
      throw StateError('KRS semester ini sudah disetujui');
    }
    for (final index in indexList) {
      if (_krs[index].isValidated) {
        throw StateError('KRS semester ini sudah disetujui');
      }
      _krs[index] = _krs[index].copyWith(
        isSubmitted: true,
        isRejected: false,
        catatanDosenPa: '',
      );
    }
    return _saved('KRS berhasil diajukan ke dosen pembimbing akademik');
  }

  String validateKrs(String krsId, String dosenId) {
    final index = _krs.indexWhere((item) => item.id == krsId);
    if (index == -1) throw StateError('KRS tidak ditemukan');
    final mahasiswa = _mahasiswa.firstWhere(
      (item) => item.nim == _krs[index].mahasiswaId,
    );
    if (mahasiswa.pembimbingAkademikId != dosenId) {
      throw StateError('KRS hanya dapat disetujui dosen pembimbing akademik');
    }
    final target = _krs[index];
    if (!target.isSubmitted) {
      throw StateError('KRS belum diajukan mahasiswa');
    }
    for (int i = 0; i < _krs.length; i++) {
      final item = _krs[i];
      if (item.mahasiswaId == target.mahasiswaId &&
          item.semester == target.semester &&
          item.isSubmitted) {
        _krs[i] = item.copyWith(
          isValidated: true,
          isRejected: false,
          catatanDosenPa: '',
        );
      }
    }
    return _saved('KRS berhasil disetujui');
  }

  String rejectKrs(String krsId, String dosenId, String catatan) {
    _ensureNotBlank(catatan, 'Catatan penolakan');
    final index = _krs.indexWhere((item) => item.id == krsId);
    if (index == -1) throw StateError('KRS tidak ditemukan');
    final mahasiswa = _mahasiswa.firstWhere(
      (item) => item.nim == _krs[index].mahasiswaId,
    );
    if (mahasiswa.pembimbingAkademikId != dosenId) {
      throw StateError('KRS hanya dapat ditolak dosen pembimbing akademik');
    }
    final target = _krs[index];
    if (!target.isSubmitted) {
      throw StateError('KRS belum diajukan mahasiswa');
    }
    for (int i = 0; i < _krs.length; i++) {
      final item = _krs[i];
      if (item.mahasiswaId == target.mahasiswaId &&
          item.semester == target.semester &&
          item.isSubmitted) {
        _krs[i] = item.copyWith(
          isSubmitted: false,
          isValidated: false,
          isRejected: true,
          catatanDosenPa: catatan.trim(),
        );
      }
    }
    return _saved('KRS ditolak dengan catatan');
  }

  String removeKrs(String krsId, String mahasiswaId) {
    final index = _krs.indexWhere(
      (item) => item.id == krsId && item.mahasiswaId == mahasiswaId,
    );
    if (index == -1) throw StateError('KRS tidak ditemukan');
    _ensureFaseKrsOpen(_krs[index].tahunAjaranId);
    if (_krs[index].isSubmitted || _krs[index].isValidated) {
      throw StateError('KRS yang sudah diajukan/disetujui tidak bisa dihapus');
    }
    _krs.removeAt(index);
    return _saved('Kelas berhasil dihapus dari KRS');
  }

  void _ensureFaseKrsOpen(String tahunAjaranId) {
    final fase = faseKrsTahunAktif;
    if (fase == null) {
      throw StateError('Admin Universitas belum membuka fase KRS');
    }
    if (fase.tahunAjaranId != tahunAjaranId) {
      throw StateError('KRS hanya dapat diisi untuk tahun akademik aktif');
    }
    final now = DateTime.now();
    if (!fase.aktif) {
      throw StateError('Fase KRS telah ditutup oleh Admin Universitas');
    }
    if (now.isBefore(fase.mulai)) {
      throw StateError('Fase KRS belum dimulai');
    }
    if (now.isAfter(fase.berakhir)) {
      throw StateError('Batas waktu pengisian KRS telah berakhir');
    }
  }

  String inputNilai({
    required String dosenId,
    required String mahasiswaId,
    required String kelasId,
    required double angka,
    double? tugas,
    double? uts,
    double? uas,
    double? softskill,
  }) {
    // Nilai hanya bisa diinput oleh dosen pengampu dan untuk mahasiswa
    // yang benar-benar mengambil kelas tersebut di KRS.
    final kelas = _kelas.firstWhere((item) => item.id == kelasId);
    if (!isDosenMengajarKelas(dosenId, kelas.id)) {
      throw StateError('Dosen hanya bisa input nilai kelas yang diajar');
    }
    _ensureExists(
      _krs.any(
        (item) => item.mahasiswaId == mahasiswaId && item.kelasId == kelasId,
      ),
      'KRS mahasiswa untuk kelas ini',
    );
    _nilai.removeWhere(
      (item) => item.mahasiswaId == mahasiswaId && item.kelasId == kelasId,
    );
    final mataKuliah = _mataKuliahByKode[kelas.mataKuliahId];
    final nilaiTugas = tugas ?? angka;
    final nilaiUts = uts ?? angka;
    final nilaiUas = uas ?? angka;
    final nilaiSoftskill = softskill ?? angka;
    final bobotTugas = mataKuliah?.bobotTugas ?? 25;
    final bobotUts = mataKuliah?.bobotUts ?? 25;
    final bobotUas = mataKuliah?.bobotUas ?? 35;
    final bobotSoftskill = mataKuliah?.bobotSoftskill ?? 15;
    final nilaiAkhir =
        nilaiTugas * bobotTugas / 100 +
        nilaiUts * bobotUts / 100 +
        nilaiUas * bobotUas / 100 +
        nilaiSoftskill * bobotSoftskill / 100;
    _nilai.add(
      Nilai(
        id: _nextId('n', _nilai.length),
        mahasiswaId: mahasiswaId,
        kelasId: kelasId,
        nilaiAngka: nilaiAkhir,
        nilaiHuruf: _huruf(nilaiAkhir),
        semester: _mahasiswa
            .firstWhere((item) => item.nim == mahasiswaId)
            .semester,
        nilaiTugas: nilaiTugas,
        nilaiUts: nilaiUts,
        nilaiUas: nilaiUas,
        nilaiSoftskill: nilaiSoftskill,
        bobotTugas: bobotTugas,
        bobotUts: bobotUts,
        bobotUas: bobotUas,
        bobotSoftskill: bobotSoftskill,
        tahunAjaranId: kelas.tahunAjaranId,
      ),
    );
    return _saved('Nilai berhasil disimpan');
  }

  String getMataKuliahName(String kode) {
    return _mataKuliahByKode[kode]?.nama ?? kode;
  }

  String getDosenName(String nidn) {
    return _dosenByNidn[nidn]?.nama ?? nidn;
  }

  String getRuanganName(String kodeRuangan) {
    return _ruanganByKode[kodeRuangan]?.namaRuangan ?? kodeRuangan;
  }

  String getRuanganInfo(String kodeRuangan) {
    final item = _ruanganByKode[kodeRuangan];
    if (item == null) return kodeRuangan;
    return '${item.namaRuangan} (${item.kodeRuangan}) - ${item.lokasi}';
  }

  List<DosenPengajar> getDosenPengajarKelas(String kelasId) {
    final pengajar = _dosenPengajarByKelas[kelasId] ?? const [];
    if (pengajar.isNotEmpty) return pengajar;
    final kelas = _kelasById[kelasId];
    if (kelas == null) return const [];
    return [
      DosenPengajar(
        id: 'fallback-${kelas.id}',
        idKelas: kelas.id,
        nidnDosen: kelas.dosenId,
      ),
    ];
  }

  String getDosenPengajarNames(String kelasId) {
    return getDosenPengajarKelas(kelasId)
        .map(
          (item) => '${getDosenName(item.nidnDosen)} (${item.peranMengajar})',
        )
        .join(', ');
  }

  bool isDosenMengajarKelas(String dosenId, String kelasId) {
    return getDosenPengajarKelas(
      kelasId,
    ).any((item) => item.nidnDosen == dosenId);
  }

  String getMahasiswaName(String nim) {
    return _mahasiswaByNim[nim]?.nama ?? nim;
  }

  int getJumlahPesertaKelas(String kelasId) {
    return _jumlahPesertaByKelas[kelasId] ?? 0;
  }

  bool isKelasPenuh(String kelasId) {
    final kelas = _kelasById[kelasId];
    if (kelas == null) return false;
    return getJumlahPesertaKelas(kelasId) >= kelas.kapasitas;
  }

  int getTotalSksDosen(String nidn) {
    return _totalSksByDosen[nidn] ?? 0;
  }

  List<KRS> getKrsMahasiswa(String nim) {
    return _krsByMahasiswa[nim] ?? const [];
  }

  List<KRS> getKrsKelas(String kelasId) {
    return _krsByKelas[kelasId] ?? const [];
  }

  List<KRS> krsByKelasIds(Iterable<String> kelasIds) {
    final result = <KRS>[];
    for (final kelasId in kelasIds) {
      result.addAll(getKrsKelas(kelasId));
    }
    return UnmodifiableListView(result);
  }

  List<Nilai> getNilaiMahasiswa(String nim) {
    return _nilaiByMahasiswa[nim] ?? const [];
  }

  List<Presensi> getPresensiMahasiswa(String nim) {
    return _presensiByMahasiswa[nim] ?? const [];
  }

  List<Pertemuan> getPertemuanKelas(String kelasId) {
    return _pertemuanByKelas[kelasId] ?? const [];
  }

  List<Presensi> getPresensiPertemuan(String pertemuanId) {
    return _presensiByPertemuan[pertemuanId] ?? const [];
  }

  List<PresensiDosen> getPresensiDosenPertemuan(String pertemuanId) {
    return _presensiDosenByPertemuan[pertemuanId] ?? const [];
  }

  List<Prodi> prodiByFakultasId(String fakultasId) {
    return _prodiByFakultas[fakultasId] ?? const [];
  }

  List<Mahasiswa> mahasiswaByProdiId(String prodiId) {
    return _mahasiswaByProdi[prodiId] ?? const [];
  }

  List<Mahasiswa> mahasiswaByProdiIds(Iterable<String> prodiIds) {
    final result = <Mahasiswa>[];
    for (final prodiId in prodiIds) {
      result.addAll(mahasiswaByProdiId(prodiId));
    }
    return UnmodifiableListView(result);
  }

  List<Dosen> dosenByProdiId(String prodiId) {
    return _dosenByProdi[prodiId] ?? const [];
  }

  List<Dosen> dosenByProdiIds(Iterable<String> prodiIds) {
    final result = <Dosen>[];
    for (final prodiId in prodiIds) {
      result.addAll(dosenByProdiId(prodiId));
    }
    return UnmodifiableListView(result);
  }

  List<MataKuliah> mataKuliahByProdiId(String prodiId) {
    return _mataKuliahByProdi[prodiId] ?? const [];
  }

  List<MataKuliah> mataKuliahByProdiIds(Iterable<String> prodiIds) {
    final result = <MataKuliah>[];
    for (final prodiId in prodiIds) {
      result.addAll(mataKuliahByProdiId(prodiId));
    }
    return UnmodifiableListView(result);
  }

  List<Kelas> kelasByTahunAjaran(String tahunAjaranId) {
    return _kelasByTahunAjaran[tahunAjaranId] ?? const [];
  }

  List<Pertemuan> pertemuanByKelasIds(Iterable<String> kelasIds) {
    final result = <Pertemuan>[];
    for (final kelasId in kelasIds) {
      result.addAll(getPertemuanKelas(kelasId));
    }
    return UnmodifiableListView(result);
  }

  List<Presensi> presensiByPertemuanIds(Iterable<String> pertemuanIds) {
    final result = <Presensi>[];
    for (final pertemuanId in pertemuanIds) {
      result.addAll(getPresensiPertemuan(pertemuanId));
    }
    return UnmodifiableListView(result);
  }

  List<PresensiDosen> presensiDosenByPertemuanIds(
    Iterable<String> pertemuanIds,
  ) {
    final result = <PresensiDosen>[];
    for (final pertemuanId in pertemuanIds) {
      result.addAll(getPresensiDosenPertemuan(pertemuanId));
    }
    return UnmodifiableListView(result);
  }

  Kelas? getKelasById(String id) {
    return _kelasById[id];
  }

  MataKuliah? getMataKuliahByKode(String kode) {
    return _mataKuliahByKode[kode];
  }

  String getDosenFullInfo(String nidn) {
    try {
      final d = _dosenByNidn[nidn]!;
      final p = _prodiById[d.prodiId]!;
      final f = _fakultasById[p.fakultasId]!;
      return '${p.nama}, ${f.nama}';
    } catch (_) {
      return '-';
    }
  }

  Future<Map<String, dynamic>> _readSeedData() async {
    final source = await rootBundle.loadString(_seedAsset);
    return _jsonMap(jsonDecode(source));
  }

  Future<void> _loadSeedData() async {
    final seed = await _readSeedData();
    _replaceFromSeed(_users, seed, 'users', _userFromJson);
    _replaceFromSeed(_fakultas, seed, 'fakultas', _fakultasFromJson);
    _replaceFromSeed(_prodi, seed, 'prodi', _prodiFromJson);
    _replaceFromSeed(_tahunAjaran, seed, 'tahunAjaran', _tahunAjaranFromJson);
    _replaceFromSeed(_mahasiswa, seed, 'mahasiswa', _mahasiswaFromJson);
    _replaceFromSeed(
      _riwayatStatusMahasiswa,
      seed,
      'riwayatStatusMahasiswa',
      _riwayatStatusMahasiswaFromJson,
    );
    _replaceFromSeed(_dosen, seed, 'dosen', _dosenFromJson);
    _replaceFromSeed(_mataKuliah, seed, 'mataKuliah', _mataKuliahFromJson);
    _replaceFromSeed(_ruangan, seed, 'ruangan', _ruanganFromJson);
    _replaceFromSeed(_kelas, seed, 'kelas', _kelasFromJson);
    _replaceFromSeed(
      _dosenPengajar,
      seed,
      'dosenPengajar',
      _dosenPengajarFromJson,
    );
    _replaceFromSeed(_krs, seed, 'krs', _krsFromJson);
    _replaceFromSeed(_faseKrs, seed, 'faseKrs', _faseKrsFromJson);
    _replaceFromSeed(_nilai, seed, 'nilai', _nilaiFromJson);
    _replaceFromSeed(_tugas, seed, 'tugas', _tugasFromJson);
    _replaceFromSeed(_skripsi, seed, 'skripsi', _skripsiFromJson);
    _replaceFromSeed(_magang, seed, 'magang', _magangFromJson);
    _replaceFromSeed(_kkn, seed, 'kkn', _kknFromJson);
    _replaceFromSeed(_pertemuan, seed, 'pertemuan', _pertemuanFromJson);
    _replaceFromSeed(_presensi, seed, 'presensi', _presensiFromJson);
    _replaceFromSeed(
      _presensiDosen,
      seed,
      'presensiDosen',
      _presensiDosenFromJson,
    );
    _replaceFromSeed(_activityLogs, seed, 'activityLogs', _activityLogFromJson);
  }

  void _replaceFromSeed<T>(
    List<T> target,
    Map<String, dynamic> seed,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    target
      ..clear()
      ..addAll(_seedList(seed, key, fromJson));
  }

  List<T> _seedList<T>(
    Map<String, dynamic> seed,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rows = seed[key] as List<dynamic>? ?? const [];
    return rows.map((row) => fromJson(_jsonMap(row))).toList();
  }

  void _loadState(Map<String, dynamic> state) {
    _users
      ..clear()
      ..addAll(_readList(state, 'users', _userFromJson));
    _fakultas
      ..clear()
      ..addAll(_readList(state, 'fakultas', _fakultasFromJson));
    _prodi
      ..clear()
      ..addAll(_readList(state, 'prodi', _prodiFromJson));
    _tahunAjaran
      ..clear()
      ..addAll(_readList(state, 'tahunAjaran', _tahunAjaranFromJson));
    _mahasiswa
      ..clear()
      ..addAll(_readList(state, 'mahasiswa', _mahasiswaFromJson));
    _riwayatStatusMahasiswa
      ..clear()
      ..addAll(
        _readList(
          state,
          'riwayatStatusMahasiswa',
          _riwayatStatusMahasiswaFromJson,
        ),
      );
    _dosen
      ..clear()
      ..addAll(_readList(state, 'dosen', _dosenFromJson));
    _mataKuliah
      ..clear()
      ..addAll(_readList(state, 'mataKuliah', _mataKuliahFromJson));
    _ruangan
      ..clear()
      ..addAll(_readList(state, 'ruangan', _ruanganFromJson));
    _kelas
      ..clear()
      ..addAll(_readList(state, 'kelas', _kelasFromJson));
    _dosenPengajar
      ..clear()
      ..addAll(_readList(state, 'dosenPengajar', _dosenPengajarFromJson));
    _krs
      ..clear()
      ..addAll(_readList(state, 'krs', _krsFromJson));
    _faseKrs
      ..clear()
      ..addAll(_readList(state, 'faseKrs', _faseKrsFromJson));
    _nilai
      ..clear()
      ..addAll(_readList(state, 'nilai', _nilaiFromJson));
    _tugas
      ..clear()
      ..addAll(_readList(state, 'tugas', _tugasFromJson));
    _skripsi
      ..clear()
      ..addAll(_readList(state, 'skripsi', _skripsiFromJson));
    _magang
      ..clear()
      ..addAll(_readList(state, 'magang', _magangFromJson));
    _kkn
      ..clear()
      ..addAll(_readList(state, 'kkn', _kknFromJson));
    _pertemuan
      ..clear()
      ..addAll(_readList(state, 'pertemuan', _pertemuanFromJson));
    _presensi
      ..clear()
      ..addAll(_readList(state, 'presensi', _presensiFromJson));
    _presensiDosen
      ..clear()
      ..addAll(_readList(state, 'presensiDosen', _presensiDosenFromJson));
    _activityLogs
      ..clear()
      ..addAll(_readList(state, 'activityLogs', _activityLogFromJson));
  }

  List<T> _readList<T>(
    Map<String, dynamic> state,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rows = state[key] as List<dynamic>? ?? const [];
    return rows.map((row) => fromJson(_jsonMap(row))).toList();
  }

  Future<void> _saveAllAsync() async {
    await _client.siakadState.saveState(_buildStateJson());
    _markCurrentRowsPersisted();
    _lastPersistenceError = null;
  }

  void _saveRows({
    List<_RowUpsert> upserts = const [],
    List<_RowDelete> deletes = const [],
  }) {
    _saveDelta();
  }

  void _saveDelta() {
    final snapshots = _tableSnapshots();
    final currentRows = _rowHashes(snapshots);
    final upserts = <Map<String, Object?>>[];
    final deletes = <Map<String, Object?>>[];

    for (final entry in snapshots.entries) {
      final tableName = entry.key;
      final currentTable = currentRows[tableName] ?? const <String, String>{};
      final persistedTable =
          _persistedRows[tableName] ?? const <String, String>{};
      for (final rowEntry in entry.value.rows.entries) {
        if (persistedTable[rowEntry.key] != currentTable[rowEntry.key]) {
          upserts.add({'tableName': tableName, 'row': rowEntry.value});
        }
      }
    }

    for (final tableName in _persistedRows.keys.toList().reversed) {
      final persistedTable =
          _persistedRows[tableName] ?? const <String, String>{};
      final currentTable = currentRows[tableName] ?? const <String, String>{};
      for (final id in persistedTable.keys) {
        if (!currentTable.containsKey(id)) {
          deletes.add({'tableName': tableName, 'id': id});
        }
      }
    }

    if (upserts.isEmpty && deletes.isEmpty) {
      _lastPersistenceError = null;
      return;
    }

    _saveQueue = _saveQueue.catchError((_) {}).then((_) async {
      try {
        await _client.siakadState.applyRowChanges(
          jsonEncode(upserts),
          jsonEncode(deletes),
        );
        _persistedRows = currentRows;
        _lastPersistenceError = null;
      } catch (error, stackTrace) {
        _lastPersistenceError = error;
        debugPrint('Gagal menyimpan delta SIAKAD: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });
    unawaited(_saveQueue.catchError((_) {}));
  }

  String _buildStateJson() {
    return jsonEncode({
      'users': _users.map(_userToJson).toList(),
      'fakultas': _fakultas.map(_fakultasToJson).toList(),
      'prodi': _prodi.map(_prodiToJson).toList(),
      'tahunAjaran': _tahunAjaran.map(_tahunAjaranToJson).toList(),
      'mahasiswa': _mahasiswa.map(_mahasiswaToJson).toList(),
      'riwayatStatusMahasiswa': _riwayatStatusMahasiswa
          .map(_riwayatStatusMahasiswaToJson)
          .toList(),
      'dosen': _dosen.map(_dosenToJson).toList(),
      'mataKuliah': _mataKuliah.map(_mataKuliahToJson).toList(),
      'ruangan': _ruangan.map(_ruanganToJson).toList(),
      'kelas': _kelas.map(_kelasToJson).toList(),
      'dosenPengajar': _dosenPengajar.map(_dosenPengajarToJson).toList(),
      'krs': _krs.map(_krsToJson).toList(),
      'faseKrs': _faseKrs.map(_faseKrsToJson).toList(),
      'nilai': _nilai.map(_nilaiToJson).toList(),
      'tugas': _tugas.map(_tugasToJson).toList(),
      'skripsi': _skripsi.map(_skripsiToJson).toList(),
      'magang': _magang.map(_magangToJson).toList(),
      'kkn': _kkn.map(_kknToJson).toList(),
      'pertemuan': _pertemuan.map(_pertemuanToJson).toList(),
      'presensi': _presensi.map(_presensiToJson).toList(),
      'presensiDosen': _presensiDosen.map(_presensiDosenToJson).toList(),
      'activityLogs': _activityLogs.map(_activityLogToJson).toList(),
    });
  }

  String _saved(String message) {
    _addActivityLog(
      actor: null,
      action: 'Perubahan Data',
      target: 'SIAKAD',
      description: message,
    );
    _rebuildIndexes();
    _saveDelta();
    return message;
  }

  void _persistChanges() {
    _rebuildIndexes();
    _saveDelta();
  }

  String _savedRows(
    String message, {
    List<_RowUpsert> upserts = const [],
    List<_RowDelete> deletes = const [],
  }) {
    _addActivityLog(
      actor: null,
      action: 'Perubahan Data',
      target: 'SIAKAD',
      description: message,
    );
    _rebuildIndexes();
    _saveRows(upserts: upserts, deletes: deletes);
    return message;
  }

  void _addActivityLog({
    required User? actor,
    required String action,
    required String target,
    required String description,
  }) {
    final now = DateTime.now();
    _activityLogs.add(
      ActivityLog(
        id: 'log-${now.microsecondsSinceEpoch}',
        actorId: actor?.id ?? 'system',
        actorName: actor?.name ?? 'Sistem',
        role: actor?.role.label ?? 'System',
        action: action,
        target: target,
        description: description,
        createdAt: now,
      ),
    );
    if (_activityLogs.length > 500) {
      _activityLogs.removeRange(0, _activityLogs.length - 500);
    }
  }

  _RowUpsert _rowUpsert(String tableName, Map<String, Object?> row) {
    return _RowUpsert(tableName, row);
  }

  void _markCurrentRowsPersisted() {
    _persistedRows = _rowHashes(_tableSnapshots());
  }

  Map<String, Map<String, String>> _rowHashes(
    Map<String, _TableSnapshot> snapshots,
  ) {
    return {
      for (final table in snapshots.entries)
        table.key: {
          for (final row in table.value.rows.entries)
            row.key: jsonEncode(row.value),
        },
    };
  }

  Map<String, _TableSnapshot> _tableSnapshots() {
    Map<String, Map<String, Object?>> rows<T>(
      Iterable<T> items,
      String Function(T item) idOf,
      Map<String, Object?> Function(T item) jsonOf,
    ) {
      return {for (final item in items) idOf(item): jsonOf(item)};
    }

    return {
      'siakad_users': _TableSnapshot(
        rows(_users, (item) => item.id, _userToJson),
      ),
      'fakultas': _TableSnapshot(
        rows(_fakultas, (item) => item.id, _fakultasToJson),
      ),
      'prodi': _TableSnapshot(rows(_prodi, (item) => item.id, _prodiToJson)),
      'tahun_ajaran': _TableSnapshot(
        rows(_tahunAjaran, (item) => item.id, _tahunAjaranToJson),
      ),
      'fase_krs': _TableSnapshot(
        rows(_faseKrs, (item) => item.tahunAjaranId, _faseKrsToJson),
      ),
      'mahasiswa': _TableSnapshot(
        rows(_mahasiswa, (item) => item.nim, _mahasiswaToJson),
      ),
      'riwayat_status_mahasiswa': _TableSnapshot(
        rows(
          _riwayatStatusMahasiswa,
          (item) => item.id,
          _riwayatStatusMahasiswaToJson,
        ),
      ),
      'dosen': _TableSnapshot(rows(_dosen, (item) => item.nidn, _dosenToJson)),
      'mata_kuliah': _TableSnapshot(
        rows(_mataKuliah, (item) => item.kode, _mataKuliahToJson),
      ),
      'ruangan': _TableSnapshot(
        rows(_ruangan, (item) => item.kodeRuangan, _ruanganToJson),
      ),
      'kelas': _TableSnapshot(rows(_kelas, (item) => item.id, _kelasToJson)),
      'dosen_pengajar': _TableSnapshot(
        rows(_dosenPengajar, (item) => item.id, _dosenPengajarToJson),
      ),
      'krs': _TableSnapshot(rows(_krs, (item) => item.id, _krsToJson)),
      'nilai': _TableSnapshot(rows(_nilai, (item) => item.id, _nilaiToJson)),
      'tugas': _TableSnapshot(rows(_tugas, (item) => item.id, _tugasToJson)),
      'skripsi': _TableSnapshot(
        rows(_skripsi, (item) => item.id, _skripsiToJson),
      ),
      'magang': _TableSnapshot(rows(_magang, (item) => item.id, _magangToJson)),
      'kkn': _TableSnapshot(rows(_kkn, (item) => item.id, _kknToJson)),
      'pertemuan': _TableSnapshot(
        rows(_pertemuan, (item) => item.id, _pertemuanToJson),
      ),
      'presensi': _TableSnapshot(
        rows(_presensi, (item) => item.id, _presensiToJson),
      ),
      'presensi_dosen': _TableSnapshot(
        rows(_presensiDosen, (item) => item.id, _presensiDosenToJson),
      ),
      'activity_log': _TableSnapshot(
        rows(_activityLogs, (item) => item.id, _activityLogToJson),
      ),
    };
  }

  Map<String, dynamic> _jsonMap(Object? value) {
    return Map<String, dynamic>.from(value as Map);
  }

  bool _boolFromJson(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return value == 'true';
  }

  DateTime _dateFromJson(Object? value) => DateTime.parse(value as String);

  DateTime? _nullableDateFromJson(Object? value) {
    if (value == null || value == '') return null;
    return DateTime.parse(value as String);
  }

  StatusPengajuan _statusPengajuanFromJson(Object? value) {
    return StatusPengajuan.values.firstWhere(
      (item) => item.name == value,
      orElse: () => StatusPengajuan.diajukan,
    );
  }

  StatusPertemuan _statusPertemuanFromJson(Object? value) {
    return StatusPertemuan.values.firstWhere(
      (item) => item.name == value,
      orElse: () => StatusPertemuan.belumDimulai,
    );
  }

  Map<String, Object?> _userToJson(User item) => {
    'id': item.id,
    'username': item.username,
    'password': item.password,
    'role': item.role.name,
    'name': item.name,
    'scopeId': item.scopeId,
    'tingkatPimpinan': item.tingkatPimpinan?.name,
  };

  User _userFromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    username: json['username'] as String,
    password: json['password'] as String,
    role: Role.values.firstWhere((item) => item.name == json['role']),
    name: json['name'] as String,
    scopeId: json['scopeId'] as String,
    tingkatPimpinan: json['tingkatPimpinan'] == null
        ? null
        : TingkatPimpinan.values.byName(json['tingkatPimpinan'] as String),
  );

  Map<String, Object?> _fakultasToJson(Fakultas item) => {
    'id': item.id,
    'nama': item.nama,
  };

  Fakultas _fakultasFromJson(Map<String, dynamic> json) =>
      Fakultas(id: json['id'] as String, nama: json['nama'] as String);

  Map<String, Object?> _prodiToJson(Prodi item) => {
    'id': item.id,
    'nama': item.nama,
    'fakultasId': item.fakultasId,
  };

  Prodi _prodiFromJson(Map<String, dynamic> json) => Prodi(
    id: json['id'] as String,
    nama: json['nama'] as String,
    fakultasId: json['fakultasId'] as String,
  );

  Map<String, Object?> _tahunAjaranToJson(TahunAjaran item) => {
    'id': item.id,
    'nama': item.nama,
    'semester': item.semester.name,
    'tanggalMulai': item.tanggalMulai.toIso8601String(),
    'tanggalSelesai': item.tanggalSelesai.toIso8601String(),
    'aktif': item.aktif,
  };

  TahunAjaran _tahunAjaranFromJson(Map<String, dynamic> json) => TahunAjaran(
    id: json['id'] as String,
    nama: json['nama'] as String,
    semester: SemesterAkademik.values.byName(json['semester'] as String),
    tanggalMulai: _dateFromJson(json['tanggalMulai']),
    tanggalSelesai: _dateFromJson(json['tanggalSelesai']),
    aktif: _boolFromJson(json['aktif']),
  );

  Map<String, Object?> _faseKrsToJson(FaseKrs item) => {
    'tahunAjaranId': item.tahunAjaranId,
    'mulai': item.mulai.toIso8601String(),
    'berakhir': item.berakhir.toIso8601String(),
    'aktif': item.aktif,
  };

  FaseKrs _faseKrsFromJson(Map<String, dynamic> json) => FaseKrs(
    tahunAjaranId: json['tahunAjaranId'] as String,
    mulai: _dateFromJson(json['mulai']),
    berakhir: _dateFromJson(json['berakhir']),
    aktif: _boolFromJson(json['aktif']),
  );

  Map<String, Object?> _mahasiswaToJson(Mahasiswa item) => {
    'nim': item.nim,
    'nama': item.nama,
    'jenisKelamin': item.jenisKelamin,
    'prodiId': item.prodiId,
    'password': item.password,
    'pembimbingAkademikId': item.pembimbingAkademikId,
    'semester': item.semester,
    'email': item.email,
    'noHp': item.noHp,
    'alamat': item.alamat,
    'status': item.status.name,
  };

  Mahasiswa _mahasiswaFromJson(Map<String, dynamic> json) => Mahasiswa(
    nim: json['nim'] as String,
    nama: json['nama'] as String,
    jenisKelamin: json['jenisKelamin'] as String,
    prodiId: json['prodiId'] as String,
    password: json['password'] as String,
    pembimbingAkademikId: json['pembimbingAkademikId'] as String,
    semester: json['semester'] as int? ?? 1,
    email: json['email'] as String? ?? '',
    noHp: json['noHp'] as String? ?? '',
    alamat: json['alamat'] as String? ?? '',
    status: StatusMahasiswa.values.firstWhere(
      (item) => item.name == json['status'],
      orElse: () => StatusMahasiswa.aktif,
    ),
  );

  Map<String, Object?> _riwayatStatusMahasiswaToJson(
    RiwayatStatusMahasiswa item,
  ) => {
    'id': item.id,
    'mahasiswaId': item.mahasiswaId,
    'statusSebelumnya': item.statusSebelumnya.name,
    'statusBaru': item.statusBaru.name,
    'namaBukti': item.namaBukti,
    'tipeBukti': item.tipeBukti,
    'ukuranBukti': item.ukuranBukti,
    'buktiBase64': item.buktiBase64,
    'diubahPada': item.diubahPada.toIso8601String(),
  };

  RiwayatStatusMahasiswa _riwayatStatusMahasiswaFromJson(
    Map<String, dynamic> json,
  ) => RiwayatStatusMahasiswa(
    id: json['id'] as String,
    mahasiswaId: json['mahasiswaId'] as String,
    statusSebelumnya: StatusMahasiswa.values.byName(
      json['statusSebelumnya'] as String,
    ),
    statusBaru: StatusMahasiswa.values.byName(json['statusBaru'] as String),
    namaBukti: json['namaBukti'] as String,
    tipeBukti: json['tipeBukti'] as String,
    ukuranBukti: json['ukuranBukti'] as int,
    buktiBase64: json['buktiBase64'] as String,
    diubahPada: DateTime.parse(json['diubahPada'] as String),
  );

  Map<String, Object?> _dosenToJson(Dosen item) => {
    'nidn': item.nidn,
    'nama': item.nama,
    'prodiId': item.prodiId,
    'password': item.password,
    'email': item.email,
    'noHp': item.noHp,
    'alamat': item.alamat,
    'keahlian': item.keahlian,
  };

  Dosen _dosenFromJson(Map<String, dynamic> json) => Dosen(
    nidn: json['nidn'] as String,
    nama: json['nama'] as String,
    prodiId: json['prodiId'] as String,
    password: json['password'] as String,
    email: json['email'] as String? ?? '',
    noHp: json['noHp'] as String? ?? '',
    alamat: json['alamat'] as String? ?? '',
    keahlian: json['keahlian'] as String? ?? '',
  );

  Map<String, Object?> _mataKuliahToJson(MataKuliah item) => {
    'kode': item.kode,
    'nama': item.nama,
    'sks': item.sks,
    'prodiId': item.prodiId,
    'kategori': item.kategori.name,
    'bobotTugas': item.bobotTugas,
    'bobotUts': item.bobotUts,
    'bobotUas': item.bobotUas,
    'bobotSoftskill': item.bobotSoftskill,
  };

  MataKuliah _mataKuliahFromJson(Map<String, dynamic> json) => MataKuliah(
    kode: json['kode'] as String,
    nama: json['nama'] as String,
    sks: json['sks'] as int,
    prodiId: json['prodiId'] as String,
    kategori: KategoriMataKuliah.values.firstWhere(
      (item) => item.name == json['kategori'],
      orElse: () => KategoriMataKuliah.reguler,
    ),
    bobotTugas: (json['bobotTugas'] as num? ?? 25).toDouble(),
    bobotUts: (json['bobotUts'] as num? ?? 25).toDouble(),
    bobotUas: (json['bobotUas'] as num? ?? 35).toDouble(),
    bobotSoftskill: (json['bobotSoftskill'] as num? ?? 15).toDouble(),
  );

  Map<String, Object?> _ruanganToJson(Ruangan item) => {
    'kodeRuangan': item.kodeRuangan,
    'namaRuangan': item.namaRuangan,
    'kapasitasRuangan': item.kapasitasRuangan,
    'lokasi': item.lokasi,
  };

  Ruangan _ruanganFromJson(Map<String, dynamic> json) => Ruangan(
    kodeRuangan: json['kodeRuangan'] as String,
    namaRuangan: json['namaRuangan'] as String,
    kapasitasRuangan: json['kapasitasRuangan'] as int,
    lokasi: json['lokasi'] as String,
  );

  Map<String, Object?> _kelasToJson(Kelas item) => {
    'id': item.id,
    'mataKuliahId': item.mataKuliahId,
    'dosenId': item.dosenId,
    'kapasitas': item.kapasitas,
    'hari': item.hari,
    'jam': item.jam,
    'ruangan': item.ruangan,
    'tahunAjaranId': item.tahunAjaranId,
  };

  Kelas _kelasFromJson(Map<String, dynamic> json) => Kelas(
    id: json['id'] as String,
    mataKuliahId: json['mataKuliahId'] as String,
    dosenId: json['dosenId'] as String,
    kapasitas: json['kapasitas'] as int,
    hari: json['hari'] as String,
    jam: json['jam'] as String,
    ruangan: json['ruangan'] as String,
    tahunAjaranId: json['tahunAjaranId'] as String? ?? 'ta-2025-genap',
  );

  Map<String, Object?> _dosenPengajarToJson(DosenPengajar item) => {
    'id': item.id,
    'idKelas': item.idKelas,
    'nidnDosen': item.nidnDosen,
    'peranMengajar': item.peranMengajar,
  };

  DosenPengajar _dosenPengajarFromJson(Map<String, dynamic> json) =>
      DosenPengajar(
        id: json['id'] as String,
        idKelas: json['idKelas'] as String,
        nidnDosen: json['nidnDosen'] as String,
        peranMengajar: json['peranMengajar'] as String? ?? 'Dosen Utama',
      );

  Map<String, Object?> _krsToJson(KRS item) => {
    'id': item.id,
    'mahasiswaId': item.mahasiswaId,
    'kelasId': item.kelasId,
    'semester': item.semester,
    'isSubmitted': item.isSubmitted,
    'isValidated': item.isValidated,
    'isRejected': item.isRejected,
    'catatanDosenPa': item.catatanDosenPa,
    'tahunAjaranId': item.tahunAjaranId,
  };

  KRS _krsFromJson(Map<String, dynamic> json) => KRS(
    id: json['id'] as String,
    mahasiswaId: json['mahasiswaId'] as String,
    kelasId: json['kelasId'] as String,
    semester: json['semester'] as int? ?? 1,
    isSubmitted: _boolFromJson(json['isSubmitted']),
    isValidated: _boolFromJson(json['isValidated']),
    isRejected: _boolFromJson(json['isRejected']),
    catatanDosenPa: json['catatanDosenPa'] as String? ?? '',
    tahunAjaranId: json['tahunAjaranId'] as String? ?? 'ta-2025-genap',
  );

  Map<String, Object?> _nilaiToJson(Nilai item) => {
    'id': item.id,
    'mahasiswaId': item.mahasiswaId,
    'kelasId': item.kelasId,
    'nilaiAngka': item.nilaiAngka,
    'nilaiHuruf': item.nilaiHuruf,
    'semester': item.semester,
    'nilaiTugas': item.nilaiTugas,
    'nilaiUts': item.nilaiUts,
    'nilaiUas': item.nilaiUas,
    'nilaiSoftskill': item.nilaiSoftskill,
    'bobotTugas': item.bobotTugas,
    'bobotUts': item.bobotUts,
    'bobotUas': item.bobotUas,
    'bobotSoftskill': item.bobotSoftskill,
    'tahunAjaranId': item.tahunAjaranId,
  };

  Nilai _nilaiFromJson(Map<String, dynamic> json) => Nilai(
    id: json['id'] as String,
    mahasiswaId: json['mahasiswaId'] as String,
    kelasId: json['kelasId'] as String,
    nilaiAngka: (json['nilaiAngka'] as num).toDouble(),
    nilaiHuruf: json['nilaiHuruf'] as String,
    semester: json['semester'] as int? ?? 1,
    nilaiTugas: (json['nilaiTugas'] as num? ?? 0).toDouble(),
    nilaiUts: (json['nilaiUts'] as num? ?? 0).toDouble(),
    nilaiUas: (json['nilaiUas'] as num? ?? 0).toDouble(),
    nilaiSoftskill: (json['nilaiSoftskill'] as num? ?? 0).toDouble(),
    bobotTugas: (json['bobotTugas'] as num? ?? 25).toDouble(),
    bobotUts: (json['bobotUts'] as num? ?? 25).toDouble(),
    bobotUas: (json['bobotUas'] as num? ?? 35).toDouble(),
    bobotSoftskill: (json['bobotSoftskill'] as num? ?? 15).toDouble(),
    tahunAjaranId: json['tahunAjaranId'] as String? ?? 'ta-2025-genap',
  );

  Map<String, Object?> _tugasToJson(Tugas item) => {
    'id': item.id,
    'kelasId': item.kelasId,
    'judul': item.judul,
    'deskripsi': item.deskripsi,
    'deadline': item.deadline.toIso8601String(),
  };

  Tugas _tugasFromJson(Map<String, dynamic> json) => Tugas(
    id: json['id'] as String,
    kelasId: json['kelasId'] as String,
    judul: json['judul'] as String,
    deskripsi: json['deskripsi'] as String,
    deadline: _dateFromJson(json['deadline']),
  );

  Map<String, Object?> _skripsiToJson(Skripsi item) => {
    'id': item.id,
    'mahasiswaId': item.mahasiswaId,
    'judul': item.judul,
    'topik': item.topik,
    'pembimbingId': item.pembimbingId,
    'dibuatPada': item.dibuatPada.toIso8601String(),
    'status': item.status.name,
    'catatan': item.catatan,
  };

  Skripsi _skripsiFromJson(Map<String, dynamic> json) => Skripsi(
    id: json['id'] as String,
    mahasiswaId: json['mahasiswaId'] as String,
    judul: json['judul'] as String,
    topik: json['topik'] as String,
    pembimbingId: json['pembimbingId'] as String,
    dibuatPada: _dateFromJson(json['dibuatPada']),
    status: _statusPengajuanFromJson(json['status']),
    catatan: List<String>.from(json['catatan'] as List? ?? const []),
  );

  Map<String, Object?> _magangToJson(Magang item) => {
    'id': item.id,
    'mahasiswaId': item.mahasiswaId,
    'instansi': item.instansi,
    'posisi': item.posisi,
    'dibuatPada': item.dibuatPada.toIso8601String(),
    'status': item.status.name,
  };

  Magang _magangFromJson(Map<String, dynamic> json) => Magang(
    id: json['id'] as String,
    mahasiswaId: json['mahasiswaId'] as String,
    instansi: json['instansi'] as String,
    posisi: json['posisi'] as String,
    dibuatPada: _dateFromJson(json['dibuatPada']),
    status: _statusPengajuanFromJson(json['status']),
  );

  Map<String, Object?> _kknToJson(Kkn item) => {
    'id': item.id,
    'mahasiswaId': item.mahasiswaId,
    'lokasi': item.lokasi,
    'tema': item.tema,
    'dibuatPada': item.dibuatPada.toIso8601String(),
    'status': item.status.name,
  };

  Kkn _kknFromJson(Map<String, dynamic> json) => Kkn(
    id: json['id'] as String,
    mahasiswaId: json['mahasiswaId'] as String,
    lokasi: json['lokasi'] as String,
    tema: json['tema'] as String,
    dibuatPada: _dateFromJson(json['dibuatPada']),
    status: _statusPengajuanFromJson(json['status']),
  );

  Map<String, Object?> _pertemuanToJson(Pertemuan item) => {
    'id': item.id,
    'kelasId': item.kelasId,
    'pertemuanKe': item.pertemuanKe,
    'status': item.status.name,
    'materi': item.materi,
    'waktuMulai': item.waktuMulai?.toIso8601String(),
  };

  Pertemuan _pertemuanFromJson(Map<String, dynamic> json) => Pertemuan(
    id: json['id'] as String,
    kelasId: json['kelasId'] as String,
    pertemuanKe: json['pertemuanKe'] as int,
    status: _statusPertemuanFromJson(json['status']),
    materi: json['materi'] as String?,
    waktuMulai: _nullableDateFromJson(json['waktuMulai']),
  );

  Map<String, Object?> _presensiToJson(Presensi item) => {
    'id': item.id,
    'pertemuanId': item.pertemuanId,
    'mahasiswaId': item.mahasiswaId,
    'statusKehadiran': item.statusKehadiran,
    'waktuPresensi': item.waktuPresensi?.toIso8601String(),
    'catatan': item.catatan,
  };

  Presensi _presensiFromJson(Map<String, dynamic> json) => Presensi(
    id: json['id'] as String,
    pertemuanId: json['pertemuanId'] as String,
    mahasiswaId: json['mahasiswaId'] as String,
    statusKehadiran: json['statusKehadiran'] as String,
    waktuPresensi: _nullableDateFromJson(json['waktuPresensi']),
    catatan: json['catatan'] as String? ?? '',
  );

  Map<String, Object?> _presensiDosenToJson(PresensiDosen item) => {
    'id': item.id,
    'pertemuanId': item.pertemuanId,
    'dosenId': item.dosenId,
    'statusKehadiran': item.statusKehadiran,
    'waktuPresensi': item.waktuPresensi.toIso8601String(),
    'catatan': item.catatan,
  };

  PresensiDosen _presensiDosenFromJson(Map<String, dynamic> json) =>
      PresensiDosen(
        id: json['id'] as String,
        pertemuanId: json['pertemuanId'] as String,
        dosenId: json['dosenId'] as String,
        statusKehadiran: json['statusKehadiran'] as String,
        waktuPresensi: _dateFromJson(json['waktuPresensi']),
        catatan: json['catatan'] as String? ?? '',
      );

  Map<String, Object?> _activityLogToJson(ActivityLog item) => {
    'id': item.id,
    'actorId': item.actorId,
    'actorName': item.actorName,
    'role': item.role,
    'action': item.action,
    'target': item.target,
    'description': item.description,
    'createdAt': item.createdAt.toIso8601String(),
  };

  ActivityLog _activityLogFromJson(Map<String, dynamic> json) => ActivityLog(
    id: json['id'] as String,
    actorId: json['actorId'] as String? ?? 'system',
    actorName: json['actorName'] as String? ?? 'Sistem',
    role: json['role'] as String? ?? 'System',
    action: json['action'] as String? ?? 'Aktivitas',
    target: json['target'] as String? ?? 'SIAKAD',
    description: json['description'] as String? ?? '',
    createdAt: _dateFromJson(json['createdAt']),
  );

  void _ensureDosenPaValid(String prodiId, String dosenId) {
    _ensureNotBlank(dosenId, 'Dosen PA');
    _ensureExists(
      _dosen.any((item) => item.nidn == dosenId && item.prodiId == prodiId),
      'Dosen PA pada prodi ini',
    );
  }

  String addTugas({
    required String dosenId,
    required String kelasId,
    required String judul,
    required String deskripsi,
    required DateTime deadline,
  }) {
    // Tugas hanya dapat dibuat oleh dosen untuk kelas yang dia ampu.
    final kelas = _kelas.firstWhere((item) => item.id == kelasId);
    if (!isDosenMengajarKelas(dosenId, kelas.id)) {
      throw StateError('Dosen hanya bisa memberi tugas pada kelas yang diajar');
    }
    _ensureNotBlank(judul, 'Judul tugas');
    _ensureNotBlank(deskripsi, 'Deskripsi tugas');

    _tugas.add(
      Tugas(
        id: _nextId('t', _tugas.length),
        kelasId: kelasId,
        judul: judul,
        deskripsi: deskripsi,
        deadline: deadline,
      ),
    );
    return _saved('Tugas berhasil ditambahkan');
  }

  String mulaiSkripsi({
    required String mahasiswaId,
    required String judul,
    required String topik,
  }) {
    _ensureNotBlank(judul, 'Judul skripsi');
    _ensureNotBlank(topik, 'Topik skripsi');
    final mahasiswa = _mahasiswa.firstWhere((item) => item.nim == mahasiswaId);
    if (_skripsi.any(
      (item) =>
          item.mahasiswaId == mahasiswaId &&
          item.status != StatusPengajuan.selesai,
    )) {
      throw StateError('Skripsi aktif sudah pernah diajukan');
    }
    _skripsi.add(
      Skripsi(
        id: _nextId('skr', _skripsi.length),
        mahasiswaId: mahasiswaId,
        judul: judul,
        topik: topik,
        pembimbingId: mahasiswa.pembimbingAkademikId,
        dibuatPada: DateTime.now(),
      ),
    );
    return _saved('Skripsi berhasil diajukan ke dosen pembimbing');
  }

  String setujuiSkripsi(String skripsiId, String dosenId) {
    final index = _skripsi.indexWhere((item) => item.id == skripsiId);
    if (index == -1) throw StateError('Pengajuan skripsi tidak ditemukan');
    if (_skripsi[index].pembimbingId != dosenId) {
      throw StateError('Hanya dosen pembimbing yang bisa menyetujui skripsi');
    }
    _skripsi[index] = _skripsi[index].copyWith(
      status: StatusPengajuan.disetujui,
    );
    return _saved('Skripsi berhasil disetujui');
  }

  String tambahCatatanBimbingan({
    required String skripsiId,
    required String dosenId,
    required String catatan,
  }) {
    _ensureNotBlank(catatan, 'Catatan bimbingan');
    final index = _skripsi.indexWhere((item) => item.id == skripsiId);
    if (index == -1) throw StateError('Data skripsi tidak ditemukan');
    if (_skripsi[index].pembimbingId != dosenId) {
      throw StateError('Hanya dosen pembimbing yang bisa memberi catatan');
    }
    _skripsi[index] = _skripsi[index].copyWith(
      catatan: [
        ..._skripsi[index].catatan,
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}: $catatan',
      ],
    );
    return _saved('Catatan bimbingan berhasil disimpan');
  }

  String ajukanMagang({
    required String mahasiswaId,
    required String instansi,
    required String posisi,
  }) {
    _ensureNotBlank(instansi, 'Instansi magang');
    _ensureNotBlank(posisi, 'Posisi magang');
    if (_magang.any(
      (item) =>
          item.mahasiswaId == mahasiswaId &&
          item.status != StatusPengajuan.selesai,
    )) {
      throw StateError('Pengajuan magang aktif sudah ada');
    }
    _magang.add(
      Magang(
        id: _nextId('mag', _magang.length),
        mahasiswaId: mahasiswaId,
        instansi: instansi,
        posisi: posisi,
        dibuatPada: DateTime.now(),
      ),
    );
    return _saved('Pengajuan magang berhasil disimpan');
  }

  String ajukanKkn({
    required String mahasiswaId,
    required String lokasi,
    required String tema,
  }) {
    _ensureNotBlank(lokasi, 'Lokasi KKN');
    _ensureNotBlank(tema, 'Tema KKN');
    if (_kkn.any(
      (item) =>
          item.mahasiswaId == mahasiswaId &&
          item.status != StatusPengajuan.selesai,
    )) {
      throw StateError('Pengajuan KKN aktif sudah ada');
    }
    _kkn.add(
      Kkn(
        id: _nextId('kkn', _kkn.length),
        mahasiswaId: mahasiswaId,
        lokasi: lokasi,
        tema: tema,
        dibuatPada: DateTime.now(),
      ),
    );
    return _saved('Pengajuan KKN berhasil disimpan');
  }

  void mulaiPertemuan(String pertemuanId, String materi, {String? dosenId}) {
    // Pertemuan dimulai oleh dosen sebelum presensi bisa disimpan.
    final index = _pertemuan.indexWhere((p) => p.id == pertemuanId);
    if (index == -1) throw StateError('Pertemuan tidak ditemukan');

    final current = _pertemuan[index];
    if (dosenId != null && !isDosenMengajarKelas(dosenId, current.kelasId)) {
      throw StateError('Akses ditolak. Dosen bukan pengajar kelas ini');
    }
    if (current.status != StatusPertemuan.belumDimulai) {
      throw StateError('Pertemuan sudah dimulai sebelumnya');
    }

    _pertemuan[index] = current.copyWith(
      status: StatusPertemuan.berlangsung,
      materi: materi,
      waktuMulai: DateTime.now(),
    );
    _persistChanges();
  }

  void selesaikanPertemuan(String pertemuanId, {String? dosenId}) {
    final index = _pertemuan.indexWhere((p) => p.id == pertemuanId);
    if (index == -1) throw StateError('Pertemuan tidak ditemukan');

    final current = _pertemuan[index];
    if (dosenId != null && !isDosenMengajarKelas(dosenId, current.kelasId)) {
      throw StateError('Akses ditolak. Dosen bukan pengajar kelas ini');
    }
    if (current.status == StatusPertemuan.belumDimulai) {
      throw StateError('Pertemuan belum dimulai');
    }
    if (current.status == StatusPertemuan.selesai) {
      throw StateError('Pertemuan sudah selesai');
    }

    _pertemuan[index] = current.copyWith(status: StatusPertemuan.selesai);
    _persistChanges();
  }

  void simpanPresensi(
    String pertemuanId,
    Map<String, String> statusMap, {
    String? dosenId,
  }) {
    // Presensi disimpan per pertemuan. Data lama untuk pertemuan yang sama
    // diganti supaya edit presensi tidak menghasilkan duplikasi.
    final index = _pertemuan.indexWhere((p) => p.id == pertemuanId);
    if (index == -1) throw StateError('Pertemuan tidak ditemukan');

    final current = _pertemuan[index];
    if (dosenId != null && !isDosenMengajarKelas(dosenId, current.kelasId)) {
      throw StateError('Akses ditolak. Dosen bukan pengajar kelas ini');
    }
    if (current.status == StatusPertemuan.belumDimulai) {
      throw StateError('Pertemuan belum dimulai');
    }

    _presensi.removeWhere((p) => p.pertemuanId == pertemuanId);

    statusMap.forEach((mahasiswaId, status) {
      _presensi.add(
        Presensi(
          id: _nextId('prs', _presensi.length),
          pertemuanId: pertemuanId,
          mahasiswaId: mahasiswaId,
          statusKehadiran: status,
          waktuPresensi: DateTime.now(),
        ),
      );
    });
    _persistChanges();
  }

  String isiPresensiMahasiswa({
    required String pertemuanId,
    required String mahasiswaId,
  }) {
    final pertemuan = _pertemuan.where((item) => item.id == pertemuanId);
    if (pertemuan.isEmpty) throw StateError('Pertemuan tidak ditemukan');
    if (pertemuan.first.status != StatusPertemuan.berlangsung) {
      throw StateError('Presensi hanya dapat diisi saat pertemuan dibuka');
    }
    if (!_krs.any(
      (item) =>
          item.kelasId == pertemuan.first.kelasId &&
          item.mahasiswaId == mahasiswaId &&
          item.isValidated,
    )) {
      throw StateError('Akses ditolak. Mahasiswa tidak terdaftar di kelas');
    }
    if (_presensi.any(
      (item) =>
          item.pertemuanId == pertemuanId && item.mahasiswaId == mahasiswaId,
    )) {
      throw StateError('Presensi sudah pernah diisi');
    }
    _presensi.add(
      Presensi(
        id: _nextId('prs', _presensi.length),
        pertemuanId: pertemuanId,
        mahasiswaId: mahasiswaId,
        statusKehadiran: 'Hadir',
        waktuPresensi: DateTime.now(),
      ),
    );
    return _saved('Presensi berhasil disimpan');
  }

  String isiPresensiDosen({
    required String pertemuanId,
    required String dosenId,
    required String status,
    String catatan = '',
  }) {
    const allowed = {'Hadir', 'Izin', 'Sakit', 'Alfa'};
    if (!allowed.contains(status)) {
      throw StateError('Status presensi tidak valid');
    }
    final pertemuan = _pertemuan.where((item) => item.id == pertemuanId);
    if (pertemuan.isEmpty) throw StateError('Pertemuan tidak ditemukan');
    if (!isDosenMengajarKelas(dosenId, pertemuan.first.kelasId)) {
      throw StateError('Akses ditolak. Dosen bukan pengajar kelas ini');
    }
    if (pertemuan.first.status == StatusPertemuan.belumDimulai) {
      throw StateError('Pertemuan belum dibuka');
    }
    if (_presensiDosen.any(
      (item) => item.pertemuanId == pertemuanId && item.dosenId == dosenId,
    )) {
      throw StateError('Presensi dosen sudah pernah diisi');
    }
    _presensiDosen.add(
      PresensiDosen(
        id: _nextId('prd', _presensiDosen.length),
        pertemuanId: pertemuanId,
        dosenId: dosenId,
        statusKehadiran: status,
        waktuPresensi: DateTime.now(),
        catatan: catatan.trim(),
      ),
    );
    return _saved('Presensi dosen berhasil disimpan');
  }

  void _syncDosenPengajar(String kelasId, List<String> dosenIds) {
    _dosenPengajar.removeWhere((item) => item.idKelas == kelasId);
    for (var index = 0; index < dosenIds.length; index++) {
      _dosenPengajar.add(
        DosenPengajar(
          id: _nextId('dp', _dosenPengajar.length),
          idKelas: kelasId,
          nidnDosen: dosenIds[index],
          peranMengajar: index == 0 ? 'Dosen Utama' : 'Dosen Pendamping',
        ),
      );
    }
  }

  void _ensureRuanganAvailable({
    required String kodeRuangan,
    required int kapasitasKelas,
    required String hari,
    required String jam,
    String? ignoreKelasId,
  }) {
    final kode = kodeRuangan.trim().toUpperCase();
    final room = _ruangan.where((item) => item.kodeRuangan == kode);
    if (room.isEmpty) throw StateError('Ruangan tidak ditemukan');
    if (room.first.kapasitasRuangan < kapasitasKelas) {
      throw StateError('Kapasitas ruangan lebih kecil dari kapasitas kelas');
    }
    final bentrok = _kelas.any(
      (item) =>
          item.id != ignoreKelasId &&
          item.ruangan == kode &&
          item.hari.toLowerCase() == hari.trim().toLowerCase() &&
          _isJamBentrok(item.jam, jam),
    );
    if (bentrok) {
      throw StateError('Ruangan sudah digunakan pada jadwal tersebut');
    }
  }

  void _ensureDosenAvailable({
    required String dosenId,
    required String hari,
    required String jam,
    String? ignoreKelasId,
  }) {
    final bentrok = _kelas.any(
      (item) =>
          item.id != ignoreKelasId &&
          isDosenMengajarKelas(dosenId, item.id) &&
          item.hari.toLowerCase() == hari.trim().toLowerCase() &&
          _isJamBentrok(item.jam, jam),
    );
    if (bentrok) {
      throw StateError('Dosen pengajar memiliki jadwal bentrok');
    }
  }

  bool _isJamBentrok(String a, String b) {
    final rangeA = _parseJamRange(a);
    final rangeB = _parseJamRange(b);
    if (rangeA == null || rangeB == null) {
      return _normalizeJam(a) == _normalizeJam(b);
    }
    return rangeA.start < rangeB.end && rangeB.start < rangeA.end;
  }

  ({int start, int end})? _parseJamRange(String value) {
    final parts = value.split(RegExp(r'\s*-\s*'));
    if (parts.length != 2) return null;
    final start = _parseJam(parts[0]);
    final end = _parseJam(parts[1]);
    if (start == null || end == null || end <= start) return null;
    return (start: start, end: end);
  }

  int? _parseJam(String value) {
    final cleaned = value.trim().replaceAll('.', ':');
    final parts = cleaned.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  String _normalizeJam(String value) {
    return value.replaceAll(RegExp(r'\s+'), '').replaceAll('.', ':');
  }

  void _ensureNotBlank(String value, String label) {
    // Helper validasi sederhana agar pesan error konsisten.
    if (value.trim().isEmpty) throw StateError('$label wajib diisi');
  }

  void _ensureExists(bool exists, String label) {
    // Dipakai untuk memastikan relasi data yang dipilih benar-benar ada.
    if (!exists) throw StateError('$label tidak ditemukan');
  }

  void _ensureBobotNilaiValid({
    required double bobotTugas,
    required double bobotUts,
    required double bobotUas,
    required double bobotSoftskill,
  }) {
    final weights = [bobotTugas, bobotUts, bobotUas, bobotSoftskill];
    if (weights.any((item) => item < 0 || item > 100)) {
      throw StateError('Bobot nilai harus berada pada rentang 0-100');
    }
    final total = weights.fold<double>(0, (sum, item) => sum + item);
    if ((total - 100).abs() > 0.01) {
      throw StateError('Total bobot nilai harus 100%');
    }
  }

  String _nextId(String prefix, int length) {
    return '$prefix-${(length + 1).toString().padLeft(2, '0')}';
  }

  String _huruf(double angka) {
    if (angka >= 85) return 'A';
    if (angka >= 75) return 'B+';
    if (angka >= 65) return 'B';
    if (angka >= 55) return 'C';
    return 'D';
  }
}
