import 'dart:typed_data';

import 'csv_file_writer_stub.dart'
    if (dart.library.io) 'csv_file_writer_io.dart';

Future<void> writeCsvFile(String? path, Uint8List bytes) {
  return writeFileBytes(path, bytes);
}
