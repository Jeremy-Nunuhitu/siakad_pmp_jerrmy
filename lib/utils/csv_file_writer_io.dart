import 'dart:io';
import 'dart:typed_data';

Future<void> writeFileBytes(String? path, Uint8List bytes) async {
  if (path == null) return;
  await File(path).writeAsBytes(bytes);
}
