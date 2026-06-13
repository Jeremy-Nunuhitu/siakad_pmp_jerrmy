import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as p;
// ignore: implementation_imports
import 'package:sqlite3/src/ffi/load_library.dart' as sqlite_loader;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database?> openMockDatabase(String databaseName) async {
  _configureSqliteLibrary();
  sqfliteFfiInit();
  final dir = _databaseDirectory();
  await dir.create(recursive: true);
  return databaseFactoryFfi.openDatabase(p.join(dir.path, databaseName));
}

void _configureSqliteLibrary() {
  if (!Platform.isWindows) return;

  sqlite_loader.open.overrideFor(
    sqlite_loader.OperatingSystem.windows,
    _openWindowsSqlite,
  );
}

DynamicLibrary _openWindowsSqlite() {
  for (final path in _windowsSqliteCandidates()) {
    if (File(path).existsSync()) {
      return DynamicLibrary.open(path);
    }
  }
  return DynamicLibrary.open('sqlite3.dll');
}

List<String> _windowsSqliteCandidates() {
  final executableDir = p.dirname(Platform.resolvedExecutable);
  final currentDir = Directory.current.path;
  return [
    p.join(executableDir, 'sqlite3.dll'),
    p.join(currentDir, 'sqlite3.dll'),
    p.join(
      currentDir,
      'build',
      'windows',
      'x64',
      'runner',
      'Debug',
      'sqlite3.dll',
    ),
    p.join(
      currentDir,
      'build',
      'windows',
      'x64',
      'runner',
      'Release',
      'sqlite3.dll',
    ),
    p.join(currentDir, 'build', 'native_assets', 'windows', 'sqlite3.dll'),
  ];
}

Directory _databaseDirectory() {
  if (Platform.isWindows) {
    final base =
        Platform.environment['APPDATA'] ??
        Platform.environment['LOCALAPPDATA'] ??
        Directory.current.path;
    return Directory(p.join(base, 'siakad_jeremy'));
  }
  if (Platform.isMacOS) {
    final home = Platform.environment['HOME'] ?? Directory.current.path;
    return Directory(
      p.join(home, 'Library', 'Application Support', 'siakad_jeremy'),
    );
  }
  if (Platform.isLinux) {
    final base =
        Platform.environment['XDG_DATA_HOME'] ??
        p.join(
          Platform.environment['HOME'] ?? Directory.current.path,
          '.local',
          'share',
        );
    return Directory(p.join(base, 'siakad_jeremy'));
  }
  return Directory(p.join(Directory.systemTemp.path, 'siakad_jeremy'));
}
