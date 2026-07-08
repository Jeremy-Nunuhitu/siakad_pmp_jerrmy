import 'dart:convert';

import '../generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class SiakadStateEndpoint extends Endpoint {
  static const _stateKey = 'app_state';
  static const _tablePrimaryKeys = <String, String>{
    'siakad_users': 'id',
    'fakultas': 'id',
    'prodi': 'id',
    'tahun_ajaran': 'id',
    'fase_krs': 'tahunAjaranId',
    'mahasiswa': 'nim',
    'riwayat_status_mahasiswa': 'id',
    'dosen': 'nidn',
    'mata_kuliah': 'kode',
    'ruangan': 'kodeRuangan',
    'kelas': 'id',
    'dosen_pengajar': 'id',
    'krs': 'id',
    'nilai': 'id',
    'tugas': 'id',
    'skripsi': 'id',
    'magang': 'id',
    'kkn': 'id',
    'pertemuan': 'id',
    'presensi': 'id',
    'presensi_dosen': 'id',
    'activity_log': 'id',
  };
  static final _requiredDomainTables = _tablePrimaryKeys.keys.toSet();
  static const _tableStateKeys = <String, String>{
    'siakad_users': 'users',
    'fakultas': 'fakultas',
    'prodi': 'prodi',
    'tahun_ajaran': 'tahunAjaran',
    'fase_krs': 'faseKrs',
    'mahasiswa': 'mahasiswa',
    'riwayat_status_mahasiswa': 'riwayatStatusMahasiswa',
    'dosen': 'dosen',
    'mata_kuliah': 'mataKuliah',
    'ruangan': 'ruangan',
    'kelas': 'kelas',
    'dosen_pengajar': 'dosenPengajar',
    'krs': 'krs',
    'nilai': 'nilai',
    'tugas': 'tugas',
    'skripsi': 'skripsi',
    'magang': 'magang',
    'kkn': 'kkn',
    'pertemuan': 'pertemuan',
    'presensi': 'presensi',
    'presensi_dosen': 'presensiDosen',
    'activity_log': 'activityLogs',
  };

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
    await session.db.transaction((transaction) async {
      final row = await SiakadState.db.findFirstRow(
        session,
        where: (t) => t.key.equals(_stateKey),
        transaction: transaction,
      );

      if (row == null) {
        await SiakadState.db.insertRow(
          session,
          SiakadState(key: _stateKey, value: stateJson),
          transaction: transaction,
        );
      } else {
        row.value = stateJson;
        await SiakadState.db.updateRow(
          session,
          row,
          transaction: transaction,
        );
      }

      await _syncRelationalTables(session, stateJson, transaction);
    });
  }

  Future<void> _ensureSiakadTables(Session session) async {
    final result = await session.db.unsafeQuery(
      '''
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = ANY(@tableNames)
''',
      parameters: QueryParameters.named({
        'tableNames': _requiredDomainTables.toList(),
      }),
    );
    final existingTables = result
        .map((row) => row.toColumnMap()['table_name'] as String)
        .toSet();
    final missingTables = _requiredDomainTables.difference(existingTables);
    if (missingTables.isNotEmpty) {
      throw StateError(
        'Schema SIAKAD belum siap. Jalankan migrasi Serverpod sebelum '
        'mengakses endpoint siakadState. Tabel hilang: '
        '${missingTables.join(', ')}',
      );
    }
  }

  Future<void> _syncRelationalTables(
    Session session,
    String stateJson,
    Transaction transaction,
  ) async {
    final state = jsonDecode(stateJson) as Map<String, dynamic>;

    await _deleteRowsMissingFromState(
      session,
      transaction,
      'activity_log',
      state['activityLogs'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'presensi_dosen',
      state['presensiDosen'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'presensi',
      state['presensi'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'pertemuan',
      state['pertemuan'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'kkn',
      state['kkn'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'magang',
      state['magang'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'skripsi',
      state['skripsi'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'tugas',
      state['tugas'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'nilai',
      state['nilai'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'krs',
      state['krs'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'dosen_pengajar',
      state['dosenPengajar'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'kelas',
      state['kelas'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'ruangan',
      state['ruangan'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'mata_kuliah',
      state['mataKuliah'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'dosen',
      state['dosen'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'riwayat_status_mahasiswa',
      state['riwayatStatusMahasiswa'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'mahasiswa',
      state['mahasiswa'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'fase_krs',
      state['faseKrs'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'tahun_ajaran',
      state['tahunAjaran'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'prodi',
      state['prodi'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'fakultas',
      state['fakultas'],
    );
    await _deleteRowsMissingFromState(
      session,
      transaction,
      'siakad_users',
      state['users'],
    );

    await _insertRows(session, transaction, 'siakad_users', state['users'], [
      'id',
      'username',
      'password',
      'role',
      'name',
      'scopeId',
      'tingkatPimpinan',
    ]);
    await _insertRows(session, transaction, 'fakultas', state['fakultas'], [
      'id',
      'nama',
    ]);
    await _insertRows(session, transaction, 'prodi', state['prodi'], [
      'id',
      'nama',
      'fakultasId',
    ]);
    await _insertRows(
      session,
      transaction,
      'tahun_ajaran',
      state['tahunAjaran'],
      [
        'id',
        'nama',
        'semester',
        'tanggalMulai',
        'tanggalSelesai',
        'aktif',
      ],
    );
    await _insertRows(session, transaction, 'fase_krs', state['faseKrs'], [
      'tahunAjaranId',
      'mulai',
      'berakhir',
      'aktif',
    ]);
    await _insertRows(session, transaction, 'mahasiswa', state['mahasiswa'], [
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
      transaction,
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
    await _insertRows(session, transaction, 'dosen', state['dosen'], [
      'nidn',
      'nama',
      'prodiId',
      'password',
      'email',
      'noHp',
      'alamat',
      'keahlian',
    ]);
    await _insertRows(
      session,
      transaction,
      'mata_kuliah',
      state['mataKuliah'],
      [
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
    );
    await _insertRows(session, transaction, 'ruangan', state['ruangan'], [
      'kodeRuangan',
      'namaRuangan',
      'kapasitasRuangan',
      'lokasi',
    ]);
    await _insertRows(session, transaction, 'kelas', state['kelas'], [
      'id',
      'mataKuliahId',
      'dosenId',
      'kapasitas',
      'hari',
      'jam',
      'ruangan',
      'tahunAjaranId',
    ]);
    await _insertRows(
      session,
      transaction,
      'dosen_pengajar',
      state['dosenPengajar'],
      [
        'id',
        'idKelas',
        'nidnDosen',
        'peranMengajar',
      ],
    );
    await _insertRows(session, transaction, 'krs', state['krs'], [
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
    await _insertRows(session, transaction, 'nilai', state['nilai'], [
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
    await _insertRows(session, transaction, 'tugas', state['tugas'], [
      'id',
      'kelasId',
      'judul',
      'deskripsi',
      'deadline',
    ]);
    await _insertRows(session, transaction, 'skripsi', state['skripsi'], [
      'id',
      'mahasiswaId',
      'judul',
      'topik',
      'pembimbingId',
      'dibuatPada',
      'status',
    ]);
    await _insertRows(session, transaction, 'magang', state['magang'], [
      'id',
      'mahasiswaId',
      'instansi',
      'posisi',
      'dibuatPada',
      'status',
    ]);
    await _insertRows(session, transaction, 'kkn', state['kkn'], [
      'id',
      'mahasiswaId',
      'lokasi',
      'tema',
      'dibuatPada',
      'status',
    ]);
    await _insertRows(session, transaction, 'pertemuan', state['pertemuan'], [
      'id',
      'kelasId',
      'pertemuanKe',
      'status',
      'materi',
      'waktuMulai',
    ]);
    await _insertRows(session, transaction, 'presensi', state['presensi'], [
      'id',
      'pertemuanId',
      'mahasiswaId',
      'statusKehadiran',
      'waktuPresensi',
      'catatan',
    ]);
    await _insertRows(
      session,
      transaction,
      'presensi_dosen',
      state['presensiDosen'],
      [
        'id',
        'pertemuanId',
        'dosenId',
        'statusKehadiran',
        'waktuPresensi',
        'catatan',
      ],
    );
    await _insertRows(
      session,
      transaction,
      'activity_log',
      state['activityLogs'],
      [
        'id',
        'actorId',
        'actorName',
        'role',
        'action',
        'target',
        'description',
        'createdAt',
      ],
    );
  }

  Future<void> _insertRows(
    Session session,
    Transaction transaction,
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
      if (chunk.isEmpty) continue;
      final statement = _upsertSql(tableName, jsonKeys, chunk);
      await session.db.unsafeExecute(
        statement.sql,
        transaction: transaction,
        parameters: QueryParameters.named(statement.parameters),
      );
    }
  }

  Future<void> _deleteRowsMissingFromState(
    Session session,
    Transaction transaction,
    String tableName,
    Object? source,
  ) async {
    final primaryJsonKey = _tablePrimaryKeys[tableName];
    if (primaryJsonKey == null) {
      throw StateError('Tabel "$tableName" belum terdaftar untuk sinkronisasi');
    }

    final primaryColumn = _columnName(primaryJsonKey);
    final rows = source as List<dynamic>? ?? const [];
    final ids = rows
        .map(
          (rawRow) => Map<String, dynamic>.from(rawRow as Map)[primaryJsonKey],
        )
        .whereType<Object>()
        .map((value) => '$value')
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    if (ids.isEmpty) {
      await session.db.unsafeExecute(
        'DELETE FROM $tableName',
        transaction: transaction,
      );
      return;
    }

    await session.db.unsafeExecute(
      'DELETE FROM $tableName WHERE NOT ($primaryColumn = ANY(@ids))',
      transaction: transaction,
      parameters: QueryParameters.named({'ids': ids}),
    );
  }

  _SqlStatement _upsertSql(
    String tableName,
    List<String> jsonKeys,
    List<Map<String, dynamic>> rows,
  ) {
    final primaryJsonKey = _tablePrimaryKeys[tableName];
    if (primaryJsonKey == null) {
      throw StateError('Tabel "$tableName" belum terdaftar untuk sinkronisasi');
    }

    final columns = jsonKeys.map(_columnName).toList();
    final allColumns = [...columns, 'data'];
    final parameters = <String, Object?>{};
    final values = rows.indexed
        .map((entry) {
          final (rowIndex, row) = entry;
          final rowValues = <String>[
            for (final key in jsonKeys)
              _bindValue(
                parameters,
                'r${rowIndex}_${_columnName(key)}',
                _normalizedSqlValue(row[key], key),
              ),
            '${_bindValue(parameters, 'r${rowIndex}_data', jsonEncode(row))}::jsonb',
          ];
          return '(${rowValues.join(', ')})';
        })
        .join(',\n');
    final primaryColumn = _columnName(primaryJsonKey);
    final updates = allColumns
        .where((column) => column != primaryColumn)
        .map((column) => '$column = EXCLUDED.$column')
        .join(', ');

    final sql =
        '''
INSERT INTO $tableName (${allColumns.join(', ')})
VALUES $values
ON CONFLICT ($primaryColumn) DO UPDATE SET
  $updates
''';
    return _SqlStatement(sql, parameters);
  }

  String _bindValue(
    Map<String, Object?> parameters,
    String key,
    Object? value,
  ) {
    parameters[key] = value;
    return '@$key';
  }

  Object? _normalizedSqlValue(Object? value, [String? key]) {
    if (value == null) return null;
    if (_booleanKeys.contains(key)) return _sqlBooleanValue(value);
    return value;
  }

  bool _sqlBooleanValue(Object value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = '$value'.trim().toLowerCase();
    return normalized == '1' || normalized == 'true';
  }

  Future<String> listRows(
    Session session,
    String tableName, {
    int limit = 100,
    int offset = 0,
  }) async {
    await _ensureSiakadTables(session);
    _ensureAllowedTable(tableName);
    final safeLimit = limit.clamp(1, 500);
    final safeOffset = offset < 0 ? 0 : offset;
    final result = await session.db.unsafeQuery(
      'SELECT data FROM $tableName ORDER BY ${_columnName(_tablePrimaryKeys[tableName]!)} LIMIT @limit OFFSET @offset',
      parameters: QueryParameters.named({
        'limit': safeLimit,
        'offset': safeOffset,
      }),
    );
    return jsonEncode([
      for (final row in result) _decodeJsonbValue(row.toColumnMap()['data']),
    ]);
  }

  Future<String?> getRow(
    Session session,
    String tableName,
    String id,
  ) async {
    await _ensureSiakadTables(session);
    _ensureAllowedTable(tableName);
    final primaryColumn = _columnName(_tablePrimaryKeys[tableName]!);
    final result = await session.db.unsafeQuery(
      'SELECT data FROM $tableName WHERE $primaryColumn = @id LIMIT 1',
      parameters: QueryParameters.named({'id': id}),
    );
    if (result.isEmpty) return null;
    return jsonEncode(_decodeJsonbValue(result.first.toColumnMap()['data']));
  }

  Future<void> upsertRow(
    Session session,
    String tableName,
    String rowJson,
  ) async {
    await _ensureSiakadTables(session);
    _ensureAllowedTable(tableName);
    final row = Map<String, dynamic>.from(jsonDecode(rowJson) as Map);
    final jsonKeys = _jsonKeysForTable(tableName);
    await session.db.transaction((transaction) async {
      await _upsertStateRow(session, transaction, tableName, row);
      final statement = _upsertSql(tableName, jsonKeys, [row]);
      await session.db.unsafeExecute(
        statement.sql,
        transaction: transaction,
        parameters: QueryParameters.named(statement.parameters),
      );
    });
  }

  Future<void> applyRowChanges(
    Session session,
    String upsertsJson,
    String deletesJson,
  ) async {
    await _ensureSiakadTables(session);
    final upserts = (jsonDecode(upsertsJson) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final deletes = (jsonDecode(deletesJson) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    await session.db.transaction((transaction) async {
      final state = await _loadStateMap(session, transaction);

      for (final change in upserts) {
        final tableName = change['tableName'] as String;
        _ensureAllowedTable(tableName);
        final row = Map<String, dynamic>.from(change['row'] as Map);
        _upsertStateRowInMap(state, tableName, row);
        final statement = _upsertSql(tableName, _jsonKeysForTable(tableName), [
          row,
        ]);
        await session.db.unsafeExecute(
          statement.sql,
          transaction: transaction,
          parameters: QueryParameters.named(statement.parameters),
        );
      }

      for (final change in deletes) {
        final tableName = change['tableName'] as String;
        final id = '${change['id']}';
        _ensureAllowedTable(tableName);
        _deleteStateRowInMap(state, tableName, id);
        final primaryColumn = _columnName(_tablePrimaryKeys[tableName]!);
        await session.db.unsafeExecute(
          'DELETE FROM $tableName WHERE $primaryColumn = @id',
          transaction: transaction,
          parameters: QueryParameters.named({'id': id}),
        );
      }

      await _saveStateMap(session, transaction, state);
    });
  }

  Future<void> deleteRow(
    Session session,
    String tableName,
    String id,
  ) async {
    await _ensureSiakadTables(session);
    _ensureAllowedTable(tableName);
    final primaryColumn = _columnName(_tablePrimaryKeys[tableName]!);
    await session.db.transaction((transaction) async {
      await _deleteStateRow(session, transaction, tableName, id);
      await session.db.unsafeExecute(
        'DELETE FROM $tableName WHERE $primaryColumn = @id',
        transaction: transaction,
        parameters: QueryParameters.named({'id': id}),
      );
    });
  }

  Future<Map<String, dynamic>> _loadStateMap(
    Session session,
    Transaction transaction,
  ) async {
    final row = await SiakadState.db.findFirstRow(
      session,
      where: (t) => t.key.equals(_stateKey),
      transaction: transaction,
    );
    if (row == null || row.value.isEmpty) return <String, dynamic>{};
    return Map<String, dynamic>.from(jsonDecode(row.value) as Map);
  }

  Future<void> _saveStateMap(
    Session session,
    Transaction transaction,
    Map<String, dynamic> state,
  ) async {
    final row = await SiakadState.db.findFirstRow(
      session,
      where: (t) => t.key.equals(_stateKey),
      transaction: transaction,
    );
    final stateJson = jsonEncode(state);
    if (row == null) {
      await SiakadState.db.insertRow(
        session,
        SiakadState(key: _stateKey, value: stateJson),
        transaction: transaction,
      );
    } else {
      row.value = stateJson;
      await SiakadState.db.updateRow(session, row, transaction: transaction);
    }
  }

  Future<void> _upsertStateRow(
    Session session,
    Transaction transaction,
    String tableName,
    Map<String, dynamic> row,
  ) async {
    final state = await _loadStateMap(session, transaction);
    _upsertStateRowInMap(state, tableName, row);
    await _saveStateMap(session, transaction, state);
  }

  Future<void> _deleteStateRow(
    Session session,
    Transaction transaction,
    String tableName,
    String id,
  ) async {
    final state = await _loadStateMap(session, transaction);
    _deleteStateRowInMap(state, tableName, id);
    await _saveStateMap(session, transaction, state);
  }

  void _upsertStateRowInMap(
    Map<String, dynamic> state,
    String tableName,
    Map<String, dynamic> row,
  ) {
    final stateKey = _stateKeyForTable(tableName);
    final primaryJsonKey = _tablePrimaryKeys[tableName]!;
    final rowId = '${row[primaryJsonKey]}';
    final rows = _stateRows(state, stateKey);
    final index = rows.indexWhere(
      (item) => '${item[primaryJsonKey]}' == rowId,
    );
    if (index == -1) {
      rows.add(row);
    } else {
      rows[index] = row;
    }
    state[stateKey] = rows;
  }

  void _deleteStateRowInMap(
    Map<String, dynamic> state,
    String tableName,
    String id,
  ) {
    final stateKey = _stateKeyForTable(tableName);
    final primaryJsonKey = _tablePrimaryKeys[tableName]!;
    final rows = _stateRows(state, stateKey)
      ..removeWhere((item) => '${item[primaryJsonKey]}' == id);
    state[stateKey] = rows;
  }

  List<Map<String, dynamic>> _stateRows(
    Map<String, dynamic> state,
    String stateKey,
  ) {
    return (state[stateKey] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  String _stateKeyForTable(String tableName) {
    final stateKey = _tableStateKeys[tableName];
    if (stateKey == null) {
      throw ArgumentError.value(tableName, 'tableName', 'Tabel tidak didukung');
    }
    return stateKey;
  }

  void _ensureAllowedTable(String tableName) {
    if (!_tablePrimaryKeys.containsKey(tableName)) {
      throw ArgumentError.value(tableName, 'tableName', 'Tabel tidak didukung');
    }
  }

  List<String> _jsonKeysForTable(String tableName) {
    return switch (tableName) {
      'siakad_users' => [
        'id',
        'username',
        'password',
        'role',
        'name',
        'scopeId',
        'tingkatPimpinan',
      ],
      'fakultas' => ['id', 'nama'],
      'prodi' => ['id', 'nama', 'fakultasId'],
      'tahun_ajaran' => [
        'id',
        'nama',
        'semester',
        'tanggalMulai',
        'tanggalSelesai',
        'aktif',
      ],
      'fase_krs' => ['tahunAjaranId', 'mulai', 'berakhir', 'aktif'],
      'mahasiswa' => [
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
      ],
      'riwayat_status_mahasiswa' => [
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
      'dosen' => [
        'nidn',
        'nama',
        'prodiId',
        'password',
        'email',
        'noHp',
        'alamat',
        'keahlian',
      ],
      'mata_kuliah' => [
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
      'ruangan' => [
        'kodeRuangan',
        'namaRuangan',
        'kapasitasRuangan',
        'lokasi',
      ],
      'kelas' => [
        'id',
        'mataKuliahId',
        'dosenId',
        'kapasitas',
        'hari',
        'jam',
        'ruangan',
        'tahunAjaranId',
      ],
      'dosen_pengajar' => ['id', 'idKelas', 'nidnDosen', 'peranMengajar'],
      'krs' => [
        'id',
        'mahasiswaId',
        'kelasId',
        'semester',
        'isSubmitted',
        'isValidated',
        'isRejected',
        'catatanDosenPa',
        'tahunAjaranId',
      ],
      'nilai' => [
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
      ],
      'tugas' => ['id', 'kelasId', 'judul', 'deskripsi', 'deadline'],
      'skripsi' => [
        'id',
        'mahasiswaId',
        'judul',
        'topik',
        'pembimbingId',
        'dibuatPada',
        'status',
      ],
      'magang' => [
        'id',
        'mahasiswaId',
        'instansi',
        'posisi',
        'dibuatPada',
        'status',
      ],
      'kkn' => [
        'id',
        'mahasiswaId',
        'lokasi',
        'tema',
        'dibuatPada',
        'status',
      ],
      'pertemuan' => [
        'id',
        'kelasId',
        'pertemuanKe',
        'status',
        'materi',
        'waktuMulai',
      ],
      'presensi' => [
        'id',
        'pertemuanId',
        'mahasiswaId',
        'statusKehadiran',
        'waktuPresensi',
        'catatan',
      ],
      'presensi_dosen' => [
        'id',
        'pertemuanId',
        'dosenId',
        'statusKehadiran',
        'waktuPresensi',
        'catatan',
      ],
      'activity_log' => [
        'id',
        'actorId',
        'actorName',
        'role',
        'action',
        'target',
        'description',
        'createdAt',
      ],
      _ => throw ArgumentError.value(
        tableName,
        'tableName',
        'Tabel tidak didukung',
      ),
    };
  }

  Object? _decodeJsonbValue(Object? value) {
    if (value is String) return jsonDecode(value);
    return value;
  }

  static const _booleanKeys = {
    'aktif',
    'isSubmitted',
    'isValidated',
    'isRejected',
  };

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
      'actorId' => 'actor_id',
      'actorName' => 'actor_name',
      'createdAt' => 'created_at',
      _ => key,
    };
  }
}

class _SqlStatement {
  const _SqlStatement(this.sql, this.parameters);

  final String sql;
  final Map<String, Object?> parameters;
}
