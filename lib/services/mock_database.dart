import 'package:sqflite_common/sqlite_api.dart';

import 'mock_database_stub.dart'
    if (dart.library.ffi) 'mock_database_ffi.dart'
    as implementation;

Future<Database?> openMockDatabase(String databaseName) {
  return implementation.openMockDatabase(databaseName);
}
