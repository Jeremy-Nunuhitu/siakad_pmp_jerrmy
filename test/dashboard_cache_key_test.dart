import 'package:flutter_test/flutter_test.dart';
import 'package:siakad_jeremy/models/siakad_models.dart';
import 'package:siakad_jeremy/views/pimpinan_views.dart';

void main() {
  test('dashboard cache key changes when revision or filters change', () {
    const base = DashboardCacheKey(
      revision: 1,
      tahunAjaranId: 'TA-1',
      semester: SemesterAkademik.ganjil,
      fakultasId: 'F-1',
      prodiId: 'P-1',
      statusKrs: KrsStatus.disetujui,
      statusPresensi: 'Hadir',
    );

    const same = DashboardCacheKey(
      revision: 1,
      tahunAjaranId: 'TA-1',
      semester: SemesterAkademik.ganjil,
      fakultasId: 'F-1',
      prodiId: 'P-1',
      statusKrs: KrsStatus.disetujui,
      statusPresensi: 'Hadir',
    );

    const newRevision = DashboardCacheKey(
      revision: 2,
      tahunAjaranId: 'TA-1',
      semester: SemesterAkademik.ganjil,
      fakultasId: 'F-1',
      prodiId: 'P-1',
      statusKrs: KrsStatus.disetujui,
      statusPresensi: 'Hadir',
    );

    const newFilter = DashboardCacheKey(
      revision: 1,
      tahunAjaranId: 'TA-1',
      semester: SemesterAkademik.genap,
      fakultasId: 'F-1',
      prodiId: 'P-1',
      statusKrs: KrsStatus.disetujui,
      statusPresensi: 'Hadir',
    );

    expect(base, same);
    expect(base.hashCode, same.hashCode);
    expect(base, isNot(newRevision));
    expect(base, isNot(newFilter));
  });
}
