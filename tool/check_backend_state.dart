import 'dart:io';

import 'package:siakad_backend_client/siakad_backend_client.dart';

Future<void> main(List<String> args) async {
  final apiUrl = args.isEmpty ? 'http://localhost:8080/' : args.first;
  final client = Client(apiUrl, connectionTimeout: const Duration(minutes: 2));
  final state = await client.siakadState.getState();
  stdout.writeln('state_bytes=${state?.length ?? 0}');
}
