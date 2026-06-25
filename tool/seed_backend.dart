import 'dart:convert';
import 'dart:io';

import 'package:siakad_backend_client/siakad_backend_client.dart';

const _defaultApiUrl = 'http://localhost:8080/';

Future<void> main(List<String> args) async {
  final apiUrl = args.isEmpty ? _defaultApiUrl : args.first;
  final client = Client(apiUrl, connectionTimeout: const Duration(minutes: 3));
  final seedFile = File('assets/database/siakad_seed.json');
  final state = jsonDecode(await seedFile.readAsString()) as Map<String, dynamic>;

  state.putIfAbsent('pertemuan', () => <Map<String, Object?>>[]);
  final pertemuan = state['pertemuan'] as List<dynamic>;
  final existingPertemuanIds = pertemuan
      .map((item) => (item as Map<String, dynamic>)['id'] as String?)
      .whereType<String>()
      .toSet();

  for (final rawKelas in state['kelas'] as List<dynamic>? ?? const []) {
    final kelas = rawKelas as Map<String, dynamic>;
    final kelasId = kelas['id'] as String;
    for (var pertemuanKe = 1; pertemuanKe <= 16; pertemuanKe++) {
      final id = 'ptm-$kelasId-$pertemuanKe';
      if (existingPertemuanIds.add(id)) {
        pertemuan.add({
          'id': id,
          'kelasId': kelasId,
          'pertemuanKe': pertemuanKe,
          'status': 'belumDimulai',
        });
      }
    }
  }

  await client.siakadState.saveState(jsonEncode(state));
  stdout.writeln('Seeded SIAKAD state to $apiUrl');
}
