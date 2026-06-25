import 'package:flutter_test/flutter_test.dart';
import 'package:siakad_jeremy/models/siakad_models.dart';

void main() {
  test('role labels remain stable for login routing', () {
    expect(Role.mahasiswa.label, 'Mahasiswa');
    expect(Role.dosen.label, 'Dosen');
    expect(Role.adminUniversitas.label, 'Admin Universitas');
  });
}
