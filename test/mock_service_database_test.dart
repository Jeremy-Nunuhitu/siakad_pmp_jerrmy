import 'package:flutter_test/flutter_test.dart';
import 'package:siakad_jeremy/services/mock_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('empty database is populated from the bundled seed', () async {
    final service = await MockService.create();

    expect(service.users, hasLength(7));
    expect(service.fakultas, hasLength(2));
    expect(service.prodi, hasLength(3));
    expect(service.mahasiswa, hasLength(3));
    expect(service.dosen, hasLength(3));
    expect(service.mataKuliah, hasLength(3));
    expect(service.ruangan, hasLength(3));
    expect(service.kelas, hasLength(2));
    expect(service.krs, hasLength(2));
    expect(service.nilai, hasLength(5));
    expect(service.pertemuan, hasLength(32));
    expect(service.login('rektor@siakad.com', '123456'), isNotNull);

    service.addFakultas('Fakultas Persisten', 'persisten', 'password');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final reloaded = await MockService.create();
    expect(
      reloaded.fakultas.any((item) => item.nama == 'Fakultas Persisten'),
      isTrue,
    );
  });
}
