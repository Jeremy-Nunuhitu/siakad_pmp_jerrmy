import 'dart:io';

import 'package:siakad_backend_client/siakad_backend_client.dart';

Future<void> main(List<String> args) async {
  final apiUrl = args.isEmpty ? 'http://localhost:8080/' : args.first;
  final client = Client(apiUrl, connectionTimeout: const Duration(minutes: 5));

  final state = await client.siakadState.getState();
  if (state == null || state.isEmpty) {
    stderr.writeln('Backend state is empty. Run tool/seed_backend.dart first.');
    exitCode = 1;
    return;
  }

  await client.siakadState.saveState(state);
  stdout.writeln('Resynced relational SIAKAD tables from backend state.');
  stdout.writeln('state_bytes=${state.length}');
}
