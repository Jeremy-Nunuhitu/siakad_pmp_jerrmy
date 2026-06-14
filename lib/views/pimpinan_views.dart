import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import '../widgets/app_scaffold.dart';

class KorproDashboardView extends StatelessWidget {
  const KorproDashboardView({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final prodi = service.prodi.firstWhere((item) => item.id == user.scopeId);
    final mahasiswaIds = service.mahasiswa
        .where((item) => item.prodiId == user.scopeId)
        .map((item) => item.nim)
        .toSet();
    final mataKuliahIds = service.mataKuliah
        .where((item) => item.prodiId == user.scopeId)
        .map((item) => item.kode)
        .toSet();
    final kelas = service.kelas
        .where((item) => mataKuliahIds.contains(item.mataKuliahId))
        .toList();
    final ruangKelas = kelas.map((item) => item.ruangan).toSet();
    final tahunAktif = service.tahunAjaran.firstWhere(
      (item) => item.aktif,
      orElse: () => service.tahunAjaran.last,
    );
    final points = <_IpkTahunPoint>[];
    for (final tahun in service.tahunAjaran) {
      final nilai = service.nilai
          .where(
            (item) =>
                mahasiswaIds.contains(item.mahasiswaId) &&
                item.tahunAjaranId == tahun.id,
          )
          .toList();
      if (nilai.isEmpty) continue;
      final semester = nilai
          .map((item) => item.semester)
          .reduce((a, b) => a < b ? a : b);
      final rataRata =
          nilai
              .map((item) => _bobotNilai(item.nilaiHuruf))
              .reduce((a, b) => a + b) /
          nilai.length;
      points.add(
        _IpkTahunPoint(
          label:
              '${tahun.nama.replaceAll('20', '').replaceAll('/', '/')}\n${tahun.semester.label} S$semester',
          value: rataRata,
        ),
      );
    }

    return AppScaffold(
      title: 'Dashboard Korpro',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: Text(prodi.nama),
              subtitle: Text(
                'Scope Korpro: hanya data Program Studi ${prodi.nama}\n'
                'Tahun ajaran aktif universitas: ${tahunAktif.label}',
              ),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 16),
          _StatSection(
            title: 'Ringkasan Program Studi',
            stats: [
              _Stat('Mahasiswa', mahasiswaIds.length),
              _Stat('Mata Kuliah', mataKuliahIds.length),
              _Stat('Ruang Kelas Digunakan', ruangKelas.length),
              _Stat('Kelas Kuliah', kelas.length),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Rata-rata IPK per Semester dan Tahun Ajaran',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Grafik hanya menghitung nilai mahasiswa ${prodi.nama}.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: points.isEmpty
                        ? const Center(child: Text('Belum ada data IPK'))
                        : CustomPaint(
                            painter: _IpkTahunPainter(
                              points: points,
                              primary: Theme.of(context).colorScheme.primary,
                              onSurface: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                            ),
                            child: const SizedBox.expand(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KorproJadwalView extends StatelessWidget {
  const KorproJadwalView({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final prodi = service.prodi.firstWhere((item) => item.id == user.scopeId);
    final tahunAktif = service.tahunAjaranAktif;
    final mataKuliahIds = service.mataKuliah
        .where((item) => item.prodiId == user.scopeId)
        .map((item) => item.kode)
        .toSet();
    final jadwal =
        service.kelas
            .where(
              (item) =>
                  mataKuliahIds.contains(item.mataKuliahId) &&
                  item.tahunAjaranId == tahunAktif.id,
            )
            .toList()
          ..sort((a, b) {
            final hariCompare = _urutanHari(
              a.hari,
            ).compareTo(_urutanHari(b.hari));
            return hariCompare != 0 ? hariCompare : a.jam.compareTo(b.jam);
          });

    return AppScaffold(
      title: 'Jadwal Kuliah ${prodi.nama}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(tahunAktif.label),
              subtitle: Text(
                'Jadwal semester berjalan untuk Program Studi ${prodi.nama}',
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (jadwal.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.event_busy_outlined),
                title: Text('Belum ada jadwal pada semester berjalan'),
              ),
            )
          else
            for (final item in jadwal)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text(service.getMataKuliahName(item.mataKuliahId)),
                  subtitle: Text(
                    '${item.id} - ${item.hari}, ${item.jam}\n'
                    '${service.getDosenPengajarNames(item.id)}',
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        service.getRuanganName(item.ruangan),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${service.getJumlahPesertaKelas(item.id)}/${item.kapasitas} peserta',
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class DekanDashboardView extends StatefulWidget {
  const DekanDashboardView({
    required this.user,
    required this.onOpenKrs,
    required this.onOpenPresensiMahasiswa,
    required this.onOpenPresensiDosen,
    required this.onOpenKelas,
    required this.onOpenLaporan,
    super.key,
  });

  final User user;
  final VoidCallback onOpenKrs;
  final VoidCallback onOpenPresensiMahasiswa;
  final VoidCallback onOpenPresensiDosen;
  final VoidCallback onOpenKelas;
  final VoidCallback onOpenLaporan;

  @override
  State<DekanDashboardView> createState() => _DekanDashboardViewState();
}

class _DekanDashboardViewState extends State<DekanDashboardView> {
  String? tahunAjaranId;
  SemesterAkademik? semester;
  String? prodiId;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final fakultas = service.fakultas.firstWhere(
      (item) => item.id == widget.user.scopeId,
    );
    final tahunId = tahunAjaranId ?? service.tahunAjaranAktif.id;
    final prodiFakultas = service.prodi
        .where((item) => item.fakultasId == widget.user.scopeId)
        .toList();
    final scopedProdiIds = prodiFakultas
        .where((item) => prodiId == null || item.id == prodiId)
        .map((item) => item.id)
        .toSet();
    final mahasiswa = service.mahasiswa
        .where(
          (item) =>
              scopedProdiIds.contains(item.prodiId) &&
              item.status == StatusMahasiswa.aktif,
        )
        .toList();
    final mahasiswaIds = mahasiswa.map((item) => item.nim).toSet();
    final dosen = service.dosen
        .where((item) => scopedProdiIds.contains(item.prodiId))
        .toList();
    final mataKuliah = service.mataKuliah
        .where((item) => scopedProdiIds.contains(item.prodiId))
        .toList();
    final mataKuliahIds = mataKuliah.map((item) => item.kode).toSet();
    final tahunTerpilih = service.tahunAjaran.firstWhere(
      (item) => item.id == tahunId,
    );
    final kelas = service.kelas
        .where(
          (item) =>
              mataKuliahIds.contains(item.mataKuliahId) &&
              item.tahunAjaranId == tahunId &&
              (semester == null || tahunTerpilih.semester == semester),
        )
        .toList();
    final kelasIds = kelas.map((item) => item.id).toSet();
    final krs = service.krs
        .where(
          (item) =>
              mahasiswaIds.contains(item.mahasiswaId) &&
              kelasIds.contains(item.kelasId) &&
              item.tahunAjaranId == tahunId &&
              (semester == null ||
                  service.tahunAjaran
                          .firstWhere((tahun) => tahun.id == item.tahunAjaranId)
                          .semester ==
                      semester),
        )
        .toList();
    final sudahKrs = krs.map((item) => item.mahasiswaId).toSet().length;
    final pertemuan = service.pertemuan
        .where((item) => kelasIds.contains(item.kelasId))
        .toList();
    final pertemuanIds = pertemuan.map((item) => item.id).toSet();
    final presensiMahasiswa = service.presensi
        .where((item) => pertemuanIds.contains(item.pertemuanId))
        .toList();
    final presensiDosen = service.presensiDosen
        .where((item) => pertemuanIds.contains(item.pertemuanId))
        .toList();
    final hadirMahasiswa = _countStatus(presensiMahasiswa, 'Hadir');
    final hadirDosen = _countDosenStatus(presensiDosen, 'Hadir');
    final ruangTerpakai = kelas.map((item) => item.ruangan).toSet();
    final kelasAktif = pertemuan
        .where((item) => item.status == StatusPertemuan.berlangsung)
        .map((item) => item.kelasId)
        .toSet()
        .length;
    final dosenBelumPresensi = dosen
        .where(
          (item) =>
              kelas.any(
                (kelas) => service.isDosenMengajarKelas(item.nidn, kelas.id),
              ) &&
              !presensiDosen.any((presensi) => presensi.dosenId == item.nidn),
        )
        .length;
    final mataKuliahPresensiRendah = mataKuliah.where((mk) {
      final ids = kelas
          .where((item) => item.mataKuliahId == mk.kode)
          .map((item) => item.id)
          .toSet();
      final ptmIds = pertemuan
          .where((item) => ids.contains(item.kelasId))
          .map((item) => item.id)
          .toSet();
      final items = presensiMahasiswa
          .where((item) => ptmIds.contains(item.pertemuanId))
          .toList();
      if (items.isEmpty) return false;
      return _countStatus(items, 'Hadir') / items.length < 0.75;
    }).length;

    return AppScaffold(
      title: 'Dashboard Dekan - ${fakultas.nama}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Filter<String>(
                    label: 'Tahun Akademik',
                    value: tahunId,
                    items: service.tahunAjaran
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => tahunAjaranId = value),
                  ),
                  _Filter<SemesterAkademik>(
                    label: 'Semester',
                    value: semester,
                    items: SemesterAkademik.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => semester = value),
                  ),
                  _Filter<String>(
                    label: 'Program Studi',
                    value: prodiId,
                    items: prodiFakultas
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.nama),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => prodiId = value),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      tahunAjaranId = null;
                      semester = null;
                      prodiId = null;
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Filter'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _StatSection(
            title: 'Ringkasan Akademik',
            stats: [
              _Stat('Mahasiswa Aktif', mahasiswa.length),
              _Stat('Dosen', dosen.length),
              _Stat('Mata Kuliah', mataKuliah.length),
              _Stat('Kelas Kuliah', kelas.length),
              _Stat('Ruangan', ruangTerpakai.length),
            ],
          ),
          _StatSection(
            title: 'Statistik KRS',
            stats: [
              _Stat('Sudah KRS', sudahKrs),
              _Stat('Belum KRS', (mahasiswa.length - sudahKrs).clamp(0, 99999)),
              _Stat('Disetujui', krs.where((item) => item.isValidated).length),
              _Stat(
                'Diajukan',
                krs
                    .where(
                      (item) =>
                          item.isSubmitted &&
                          !item.isValidated &&
                          !item.isRejected,
                    )
                    .length,
              ),
              _Stat('Ditolak', krs.where((item) => item.isRejected).length),
              _Stat('Draft', krs.where((item) => !item.isSubmitted).length),
            ],
          ),
          _StatSection(
            title: 'Statistik Presensi',
            stats: [
              _Stat(
                'Rata-rata Presensi Mahasiswa',
                _percentage(hadirMahasiswa, presensiMahasiswa.length),
              ),
              _Stat(
                'Rata-rata Presensi Dosen',
                _percentage(hadirDosen, presensiDosen.length),
              ),
              _Stat('Hadir', hadirMahasiswa + hadirDosen),
              _Stat(
                'Izin',
                _countStatus(presensiMahasiswa, 'Izin') +
                    _countStatus(presensiMahasiswa, 'Ijin') +
                    _countDosenStatus(presensiDosen, 'Izin'),
              ),
              _Stat(
                'Sakit',
                _countStatus(presensiMahasiswa, 'Sakit') +
                    _countDosenStatus(presensiDosen, 'Sakit'),
              ),
              _Stat(
                'Alfa',
                _countStatus(presensiMahasiswa, 'Alfa') +
                    _countStatus(presensiMahasiswa, 'Alpa') +
                    _countDosenStatus(presensiDosen, 'Alfa'),
              ),
            ],
          ),
          _StatSection(
            title: 'Statistik Kelas dan Ruangan',
            stats: [
              _Stat('Kelas Aktif', kelasAktif),
              _Stat(
                'Kelas Penuh',
                kelas.where((item) => service.isKelasPenuh(item.id)).length,
              ),
              _Stat(
                'Kelas Belum Penuh',
                kelas.where((item) => !service.isKelasPenuh(item.id)).length,
              ),
              _Stat('Ruangan Terpakai', ruangTerpakai.length),
              _Stat(
                'Ruangan Kosong',
                (service.ruangan.length - ruangTerpakai.length).clamp(0, 99999),
              ),
            ],
          ),
          _DekanCharts(
            krs: krs,
            presensiMahasiswa: presensiMahasiswa,
            presensiDosen: presensiDosen,
          ),
          _DekanWarnings(
            belumKrs: (mahasiswa.length - sudahKrs).clamp(0, 99999),
            dosenBelumPresensi: dosenBelumPresensi,
            mataKuliahPresensiRendah: mataKuliahPresensiRendah,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onOpenKrs,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Lihat Detail KRS'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onOpenPresensiMahasiswa,
                    icon: const Icon(Icons.groups_outlined),
                    label: const Text('Lihat Detail Presensi Mahasiswa'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onOpenPresensiDosen,
                    icon: const Icon(Icons.co_present_outlined),
                    label: const Text('Lihat Detail Presensi Dosen'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onOpenKelas,
                    icon: const Icon(Icons.class_outlined),
                    label: const Text('Lihat Detail Kelas Kuliah'),
                  ),
                  FilledButton.icon(
                    onPressed: widget.onOpenLaporan,
                    icon: const Icon(Icons.summarize_outlined),
                    label: const Text('Lihat Laporan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RektorDashboardView extends StatefulWidget {
  const RektorDashboardView({
    required this.user,
    required this.onOpenData,
    required this.onOpenKrs,
    required this.onOpenPresensi,
    required this.onOpenLaporan,
    super.key,
  });

  final User user;
  final VoidCallback onOpenData;
  final VoidCallback onOpenKrs;
  final VoidCallback onOpenPresensi;
  final VoidCallback onOpenLaporan;

  @override
  State<RektorDashboardView> createState() => _RektorDashboardViewState();
}

class _RektorDashboardViewState extends State<RektorDashboardView> {
  String? tahunAjaranId;
  SemesterAkademik? semester;
  String? fakultasId;
  String? prodiId;
  String? mataKuliahId;
  String? dosenId;
  KrsStatus? statusKrs;
  String? statusPresensi;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final tahunId = tahunAjaranId ?? service.tahunAjaranAktif.id;
    final tahun = service.tahunAjaran.firstWhere((item) => item.id == tahunId);
    final prodi = service.prodi.where((item) {
      return (fakultasId == null || item.fakultasId == fakultasId) &&
          (prodiId == null || item.id == prodiId);
    }).toList();
    final prodiIds = prodi.map((item) => item.id).toSet();
    final mahasiswa = service.mahasiswa
        .where((item) => prodiIds.contains(item.prodiId))
        .toList();
    final mahasiswaIds = mahasiswa.map((item) => item.nim).toSet();
    final dosen = service.dosen
        .where(
          (item) =>
              prodiIds.contains(item.prodiId) &&
              (dosenId == null || item.nidn == dosenId),
        )
        .toList();
    final mataKuliah = service.mataKuliah
        .where(
          (item) =>
              prodiIds.contains(item.prodiId) &&
              (mataKuliahId == null || item.kode == mataKuliahId),
        )
        .toList();
    final mataKuliahIds = mataKuliah.map((item) => item.kode).toSet();
    final kelas = service.kelas
        .where(
          (item) =>
              mataKuliahIds.contains(item.mataKuliahId) &&
              item.tahunAjaranId == tahunId &&
              (semester == null || tahun.semester == semester) &&
              (dosenId == null ||
                  service.isDosenMengajarKelas(dosenId!, item.id)),
        )
        .toList();
    final kelasIds = kelas.map((item) => item.id).toSet();
    final krs = service.krs
        .where(
          (item) =>
              mahasiswaIds.contains(item.mahasiswaId) &&
              kelasIds.contains(item.kelasId) &&
              item.tahunAjaranId == tahunId &&
              (statusKrs == null || item.status == statusKrs),
        )
        .toList();
    final pertemuan = service.pertemuan
        .where((item) => kelasIds.contains(item.kelasId))
        .toList();
    final pertemuanIds = pertemuan.map((item) => item.id).toSet();
    final presensiMahasiswa = service.presensi
        .where(
          (item) =>
              pertemuanIds.contains(item.pertemuanId) &&
              (statusPresensi == null ||
                  _sameStatus(item.statusKehadiran, statusPresensi!)),
        )
        .toList();
    final presensiDosen = service.presensiDosen
        .where(
          (item) =>
              pertemuanIds.contains(item.pertemuanId) &&
              (statusPresensi == null ||
                  _sameStatus(item.statusKehadiran, statusPresensi!)),
        )
        .toList();
    final hadirMahasiswa = _countStatus(presensiMahasiswa, 'Hadir');
    final hadirDosen = _countDosenStatus(presensiDosen, 'Hadir');
    final sudahKrs = krs.map((item) => item.mahasiswaId).toSet().length;
    final krsApproved = krs.where((item) => item.isValidated).length;
    final ruangTerpakai = kelas.map((item) => item.ruangan).toSet();
    final fakultasMetrics = service.fakultas
        .map((item) => _fakultasMetric(service, item.id, tahunId))
        .toList();
    final topFakultas = fakultasMetrics.isEmpty
        ? '-'
        : (fakultasMetrics.toList()
                ..sort((a, b) => b.mahasiswa.compareTo(a.mahasiswa)))
              .first
              .nama;
    final topProdi = service.prodi.isEmpty
        ? '-'
        : (service.prodi.toList()..sort(
                (a, b) => service.mahasiswa
                    .where((item) => item.prodiId == b.id)
                    .length
                    .compareTo(
                      service.mahasiswa
                          .where((item) => item.prodiId == a.id)
                          .length,
                    ),
              ))
              .first
              .nama;

    return AppScaffold(
      title: 'Dashboard Rektor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: const Text('Dashboard Rektor - Universitas SIAKAD'),
              subtitle: Text(
                'Tahun Akademik ${tahun.label}\n'
                'Tanggal ${_tanggalHariIni()} - Mode: Read Only',
              ),
              isThreeLine: true,
              trailing: const Chip(label: Text('READ ONLY')),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Filter<String>(
                    label: 'Tahun Akademik',
                    value: tahunId,
                    items: service.tahunAjaran
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => tahunAjaranId = value),
                  ),
                  _Filter<SemesterAkademik>(
                    label: 'Semester',
                    value: semester,
                    items: SemesterAkademik.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => semester = value),
                  ),
                  _Filter<String>(
                    label: 'Fakultas',
                    value: fakultasId,
                    items: service.fakultas
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.nama),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      fakultasId = value;
                      prodiId = null;
                    }),
                  ),
                  _Filter<String>(
                    label: 'Program Studi',
                    value: prodiId,
                    items: service.prodi
                        .where(
                          (item) =>
                              fakultasId == null ||
                              item.fakultasId == fakultasId,
                        )
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.nama),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => prodiId = value),
                  ),
                  _Filter<String>(
                    label: 'Jenjang Pendidikan',
                    value: 'S1',
                    items: const [
                      DropdownMenuItem(
                        value: 'S1',
                        child: Text('Sarjana (S1)'),
                      ),
                    ],
                    onChanged: (_) {},
                  ),
                  _Filter<String>(
                    label: 'Mata Kuliah',
                    value: mataKuliahId,
                    items: service.mataKuliah
                        .where((item) => prodiIds.contains(item.prodiId))
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.kode,
                            child: Text(item.nama),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => mataKuliahId = value),
                  ),
                  _Filter<String>(
                    label: 'Dosen',
                    value: dosenId,
                    items: service.dosen
                        .where((item) => prodiIds.contains(item.prodiId))
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.nidn,
                            child: Text(item.nama),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => dosenId = value),
                  ),
                  _Filter<KrsStatus>(
                    label: 'Status KRS',
                    value: statusKrs,
                    items: KrsStatus.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => statusKrs = value),
                  ),
                  _Filter<String>(
                    label: 'Status Presensi',
                    value: statusPresensi,
                    items: const [
                      DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
                      DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                      DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                      DropdownMenuItem(value: 'Alfa', child: Text('Alfa')),
                    ],
                    onChanged: (value) =>
                        setState(() => statusPresensi = value),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      tahunAjaranId = null;
                      semester = null;
                      fakultasId = null;
                      prodiId = null;
                      mataKuliahId = null;
                      dosenId = null;
                      statusKrs = null;
                      statusPresensi = null;
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Filter'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _StatSection(
            title: 'Ringkasan Universitas',
            stats: [
              _Stat(
                'Total Fakultas',
                fakultasId == null ? service.fakultas.length : 1,
              ),
              _Stat('Total Program Studi', prodi.length),
              _Stat('Total Mahasiswa', mahasiswa.length),
              _Stat(
                'Mahasiswa Aktif',
                mahasiswa
                    .where((e) => e.status == StatusMahasiswa.aktif)
                    .length,
              ),
              _Stat('Total Dosen', dosen.length),
              _Stat('Total Mata Kuliah', mataKuliah.length),
              _Stat('Total Kelas Kuliah', kelas.length),
              _Stat('Total Ruangan', service.ruangan.length),
              _Stat('Total KRS', krs.length),
              _Stat(
                'Presensi Mahasiswa',
                _percentage(hadirMahasiswa, presensiMahasiswa.length),
              ),
              _Stat(
                'Presensi Dosen',
                _percentage(hadirDosen, presensiDosen.length),
              ),
            ],
          ),
          _StatSection(
            title: 'Statistik Akademik Universitas',
            stats: [
              _Stat(
                'Mahasiswa Tidak Aktif',
                mahasiswa
                    .where((e) => e.status != StatusMahasiswa.aktif)
                    .length,
              ),
              _Stat(
                'Dosen Pengajar',
                service.dosenPengajar
                    .where((e) => dosen.any((d) => d.nidn == e.nidnDosen))
                    .length,
              ),
              _Stat('Jadwal Kuliah', kelas.length),
              _Stat(
                'Dosen PA',
                mahasiswa.map((e) => e.pembimbingAkademikId).toSet().length,
              ),
              _Stat('Prodi Mahasiswa Terbanyak', topProdi),
              _Stat('Fakultas Mahasiswa Terbanyak', topFakultas),
            ],
          ),
          _StatSection(
            title: 'Statistik KRS Universitas',
            action: TextButton(
              onPressed: widget.onOpenKrs,
              child: const Text('Lihat Detail KRS Universitas'),
            ),
            stats: [
              _Stat('Mahasiswa Mengisi KRS', sudahKrs),
              _Stat(
                'Belum Mengisi KRS',
                (mahasiswa.length - sudahKrs).clamp(0, 99999),
              ),
              _Stat('Draft', krs.where((e) => !e.isSubmitted).length),
              _Stat(
                'Diajukan',
                krs
                    .where(
                      (e) => e.isSubmitted && !e.isValidated && !e.isRejected,
                    )
                    .length,
              ),
              _Stat('Disetujui', krsApproved),
              _Stat('Ditolak', krs.where((e) => e.isRejected).length),
              _Stat(
                'Persentase Disetujui',
                _percentage(krsApproved, krs.length),
              ),
            ],
          ),
          _StatSection(
            title: 'Statistik Presensi Mahasiswa Universitas',
            action: TextButton(
              onPressed: widget.onOpenPresensi,
              child: const Text('Lihat Detail Presensi Mahasiswa'),
            ),
            stats: [
              _Stat('Total Pertemuan', pertemuan.length),
              _Stat('Total Data Presensi', presensiMahasiswa.length),
              _Stat(
                'Rata-rata Kehadiran',
                _percentage(hadirMahasiswa, presensiMahasiswa.length),
              ),
              ..._presensiCounts(
                presensiMahasiswa,
              ).entries.map((e) => _Stat(e.key, e.value)),
            ],
          ),
          _StatSection(
            title: 'Statistik Presensi Dosen Universitas',
            action: TextButton(
              onPressed: widget.onOpenPresensi,
              child: const Text('Lihat Detail Presensi Dosen'),
            ),
            stats: [
              _Stat('Total Pertemuan Dosen', pertemuan.length),
              _Stat('Total Data Presensi Dosen', presensiDosen.length),
              _Stat(
                'Rata-rata Kehadiran',
                _percentage(hadirDosen, presensiDosen.length),
              ),
              ..._presensiDosenCounts(
                presensiDosen,
              ).entries.map((e) => _Stat(e.key, e.value)),
            ],
          ),
          _StatSection(
            title: 'Statistik Kelas Kuliah dan Ruangan',
            action: TextButton(
              onPressed: widget.onOpenData,
              child: const Text('Lihat Detail Kelas dan Ruangan'),
            ),
            stats: [
              _Stat('Total Kelas Dibuka', kelas.length),
              _Stat(
                'Kelas Aktif',
                pertemuan
                    .where((e) => e.status == StatusPertemuan.berlangsung)
                    .map((e) => e.kelasId)
                    .toSet()
                    .length,
              ),
              _Stat(
                'Kelas Penuh',
                kelas.where((e) => service.isKelasPenuh(e.id)).length,
              ),
              _Stat(
                'Kelas Belum Penuh',
                kelas.where((e) => !service.isKelasPenuh(e.id)).length,
              ),
              _Stat(
                'Rata-rata Peserta',
                kelas.isEmpty
                    ? '0'
                    : (krs.length / kelas.length).toStringAsFixed(1),
              ),
              _Stat('Ruangan Terpakai', ruangTerpakai.length),
              _Stat(
                'Ruangan Belum Terpakai',
                (service.ruangan.length - ruangTerpakai.length).clamp(0, 99999),
              ),
            ],
          ),
          _RektorFakultasComparison(metrics: fakultasMetrics),
          _DekanCharts(
            krs: krs,
            presensiMahasiswa: presensiMahasiswa,
            presensiDosen: presensiDosen,
          ),
          _RektorAlerts(
            belumKrs: (mahasiswa.length - sudahKrs).clamp(0, 99999),
            menungguValidasi: krs
                .where((e) => e.isSubmitted && !e.isValidated && !e.isRejected)
                .length,
            ruanganKosong: (service.ruangan.length - ruangTerpakai.length)
                .clamp(0, 99999),
            kelasPenuh: kelas.where((e) => service.isKelasPenuh(e.id)).length,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: widget.onOpenData,
                    child: const Text('Detail Fakultas & Program Studi'),
                  ),
                  OutlinedButton(
                    onPressed: widget.onOpenKrs,
                    child: const Text('Detail KRS Universitas'),
                  ),
                  OutlinedButton(
                    onPressed: widget.onOpenPresensi,
                    child: const Text('Detail Presensi Universitas'),
                  ),
                  FilledButton.icon(
                    onPressed: widget.onOpenLaporan,
                    icon: const Icon(Icons.summarize_outlined),
                    label: const Text('Lihat Laporan Akademik'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PimpinanDashboardView extends StatefulWidget {
  const PimpinanDashboardView({
    required this.user,
    required this.onOpenPresensi,
    super.key,
  });

  final User user;
  final VoidCallback onOpenPresensi;

  @override
  State<PimpinanDashboardView> createState() => _PimpinanDashboardViewState();
}

class _PimpinanDashboardViewState extends State<PimpinanDashboardView> {
  String? prodiId;
  int? semester;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final allowedProdiIds = widget.user.tingkatPimpinan == TingkatPimpinan.dekan
        ? service.prodi
              .where((item) => item.fakultasId == widget.user.scopeId)
              .map((item) => item.id)
              .toSet()
        : service.prodi.map((item) => item.id).toSet();
    final mahasiswa = service.mahasiswa
        .where(
          (item) =>
              allowedProdiIds.contains(item.prodiId) &&
              (prodiId == null || item.prodiId == prodiId) &&
              (semester == null || item.semester == semester),
        )
        .toList();
    final mahasiswaIds = mahasiswa.map((item) => item.nim).toSet();
    final kelas = service.kelas.where((item) {
      if (prodiId == null) return true;
      final mk = service.mataKuliah.firstWhere(
        (mk) => mk.kode == item.mataKuliahId,
      );
      return allowedProdiIds.contains(mk.prodiId) &&
          (prodiId == null || mk.prodiId == prodiId);
    }).toList();
    final kelasIds = kelas.map((item) => item.id).toSet();
    final krs = service.krs
        .where(
          (item) =>
              mahasiswaIds.contains(item.mahasiswaId) &&
              kelasIds.contains(item.kelasId),
        )
        .toList();
    final pertemuan = service.pertemuan
        .where((item) => kelasIds.contains(item.kelasId))
        .toList();
    final pertemuanIds = pertemuan.map((item) => item.id).toSet();
    final presensi = service.presensi
        .where((item) => pertemuanIds.contains(item.pertemuanId))
        .toList();
    final presensiDosen = service.presensiDosen
        .where((item) => pertemuanIds.contains(item.pertemuanId))
        .toList();
    final submitted = krs.where((item) => item.isSubmitted).length;
    final approved = krs.where((item) => item.isValidated).length;
    final rejected = krs.where((item) => item.isRejected).length;
    final hadirMahasiswa = _countStatus(presensi, 'Hadir');
    final hadirDosen = _countDosenStatus(presensiDosen, 'Hadir');
    final usedRooms = kelas.map((item) => item.ruangan).toSet();

    return AppScaffold(
      title: 'Dashboard ${widget.user.tingkatPimpinan?.label ?? 'Pimpinan'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Filter<String>(
                    label: 'Program Studi',
                    value: prodiId,
                    items: service.prodi
                        .where((item) => allowedProdiIds.contains(item.id))
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.nama),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => prodiId = value),
                  ),
                  _Filter<int>(
                    label: 'Semester',
                    value: semester,
                    items: List.generate(
                      8,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('Semester ${index + 1}'),
                      ),
                    ),
                    onChanged: (value) => setState(() => semester = value),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      prodiId = null;
                      semester = null;
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Filter'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _StatSection(
            title: 'Statistik Akademik',
            stats: [
              _Stat('Program Studi', allowedProdiIds.length),
              _Stat('Mahasiswa', mahasiswa.length),
              _Stat(
                'Mahasiswa Aktif',
                mahasiswa
                    .where((item) => item.status == StatusMahasiswa.aktif)
                    .length,
              ),
              _Stat(
                'Dosen',
                service.dosen
                    .where((item) => prodiId == null || item.prodiId == prodiId)
                    .length,
              ),
              _Stat(
                'Mata Kuliah',
                service.mataKuliah
                    .where(
                      (item) =>
                          allowedProdiIds.contains(item.prodiId) &&
                          (prodiId == null || item.prodiId == prodiId),
                    )
                    .length,
              ),
              _Stat('Kelas Kuliah', kelas.length),
              _Stat('Ruangan', service.ruangan.length),
              _Stat(
                'Dosen PA',
                mahasiswa
                    .map((item) => item.pembimbingAkademikId)
                    .toSet()
                    .length,
              ),
              _Stat('Dosen Pengajar', service.dosenPengajar.length),
            ],
          ),
          _StatSection(
            title: 'Statistik KRS',
            stats: [
              _Stat(
                'Mahasiswa Mengisi KRS',
                krs.map((e) => e.mahasiswaId).toSet().length,
              ),
              _Stat('KRS Draft', krs.where((item) => !item.isSubmitted).length),
              _Stat('KRS Diajukan', submitted),
              _Stat('KRS Disetujui', approved),
              _Stat('KRS Ditolak', rejected),
              _Stat(
                'Belum Mengisi KRS',
                mahasiswa.length - krs.map((e) => e.mahasiswaId).toSet().length,
              ),
              _Stat(
                'Persentase Disetujui',
                submitted == 0
                    ? '0%'
                    : '${(approved / submitted * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
          _StatSection(
            title: 'Statistik Jadwal KRS',
            stats: [
              _Stat('Tahun Akademik Aktif', service.tahunAjaranAktif.nama),
              _Stat(
                'Semester Aktif',
                semester == null ? 'Genap' : 'Semester $semester',
              ),
              const _Stat('Status Jadwal KRS', 'Aktif'),
              const _Stat('Tanggal Mulai KRS', '01/06/2026'),
              const _Stat('Tanggal Selesai KRS', '30/06/2026'),
              _Stat(
                'Sisa Hari KRS',
                DateTime(
                  2026,
                  6,
                  30,
                ).difference(DateTime.now()).inDays.clamp(0, 999),
              ),
              _Stat('Prodi dengan Jadwal Aktif', allowedProdiIds.length),
            ],
          ),
          _StatSection(
            title: 'Statistik Presensi Mahasiswa',
            action: TextButton(
              onPressed: widget.onOpenPresensi,
              child: const Text('Lihat Detail Presensi'),
            ),
            stats: [
              _Stat('Total Pertemuan', pertemuan.length),
              _Stat('Total Presensi', presensi.length),
              _Stat(
                'Rata-rata Kehadiran',
                _percentage(hadirMahasiswa, presensi.length),
              ),
              _Stat('Hadir', hadirMahasiswa),
              _Stat(
                'Izin',
                _countStatus(presensi, 'Izin') + _countStatus(presensi, 'Ijin'),
              ),
              _Stat('Sakit', _countStatus(presensi, 'Sakit')),
              _Stat(
                'Alfa',
                _countStatus(presensi, 'Alfa') + _countStatus(presensi, 'Alpa'),
              ),
            ],
          ),
          _StatSection(
            title: 'Statistik Presensi Dosen',
            action: TextButton(
              onPressed: widget.onOpenPresensi,
              child: const Text('Lihat Detail Presensi Dosen'),
            ),
            stats: [
              _Stat('Total Pertemuan Dosen', pertemuan.length),
              _Stat('Total Presensi Dosen', presensiDosen.length),
              _Stat(
                'Rata-rata Kehadiran',
                _percentage(hadirDosen, presensiDosen.length),
              ),
              _Stat('Hadir', hadirDosen),
              _Stat('Izin', _countDosenStatus(presensiDosen, 'Izin')),
              _Stat('Sakit', _countDosenStatus(presensiDosen, 'Sakit')),
              _Stat('Alfa', _countDosenStatus(presensiDosen, 'Alfa')),
            ],
          ),
          _StatSection(
            title: 'Statistik Kelas dan Ruangan',
            stats: [
              _Stat('Total Kelas Dibuka', kelas.length),
              _Stat(
                'Kelas Aktif',
                pertemuan
                    .where((e) => e.status == StatusPertemuan.berlangsung)
                    .map((e) => e.kelasId)
                    .toSet()
                    .length,
              ),
              _Stat(
                'Kelas Penuh',
                kelas.where((item) => service.isKelasPenuh(item.id)).length,
              ),
              _Stat(
                'Kelas Belum Penuh',
                kelas.where((item) => !service.isKelasPenuh(item.id)).length,
              ),
              _Stat(
                'Rata-rata Peserta',
                kelas.isEmpty
                    ? '0'
                    : (krs.length / kelas.length).toStringAsFixed(1),
              ),
              _Stat('Ruangan Terpakai', usedRooms.length),
              _Stat(
                'Ruangan Belum Terpakai',
                service.ruangan.length - usedRooms.length,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _PimpinanDataMenu { mahasiswa, dosen, mataKuliah, kelasKuliah, ruangKelas }

extension _PimpinanDataMenuLabel on _PimpinanDataMenu {
  String get label {
    switch (this) {
      case _PimpinanDataMenu.mahasiswa:
        return 'Mahasiswa';
      case _PimpinanDataMenu.dosen:
        return 'Dosen';
      case _PimpinanDataMenu.mataKuliah:
        return 'Mata Kuliah';
      case _PimpinanDataMenu.kelasKuliah:
        return 'Kelas Kuliah';
      case _PimpinanDataMenu.ruangKelas:
        return 'Ruang Kelas';
    }
  }

  IconData get icon {
    switch (this) {
      case _PimpinanDataMenu.mahasiswa:
        return Icons.groups_outlined;
      case _PimpinanDataMenu.dosen:
        return Icons.co_present_outlined;
      case _PimpinanDataMenu.mataKuliah:
        return Icons.menu_book_outlined;
      case _PimpinanDataMenu.kelasKuliah:
        return Icons.class_outlined;
      case _PimpinanDataMenu.ruangKelas:
        return Icons.meeting_room_outlined;
    }
  }
}

class PimpinanDataView extends StatefulWidget {
  const PimpinanDataView({this.user, super.key});

  final User? user;

  @override
  State<PimpinanDataView> createState() => _PimpinanDataViewState();
}

class _PimpinanDataViewState extends State<PimpinanDataView> {
  _PimpinanDataMenu selectedMenu = _PimpinanDataMenu.mahasiswa;
  String? fakultasId;
  String? prodiId;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final allowedProdiIds = _allowedProdiIds(service, widget.user);
    final allowedProdi = service.prodi
        .where((item) => allowedProdiIds.contains(item.id))
        .toList();
    final allowedFakultasIds = allowedProdi
        .map((item) => item.fakultasId)
        .toSet();
    final allowedFakultas = service.fakultas
        .where((item) => allowedFakultasIds.contains(item.id))
        .toList();
    final filteredProdi = allowedProdi.where((item) {
      return (fakultasId == null || item.fakultasId == fakultasId) &&
          (prodiId == null || item.id == prodiId);
    }).toList();
    final filteredProdiIds = filteredProdi.map((item) => item.id).toSet();
    final mahasiswa = service.mahasiswa
        .where((item) => filteredProdiIds.contains(item.prodiId))
        .toList();
    final dosen = service.dosen
        .where((item) => filteredProdiIds.contains(item.prodiId))
        .toList();
    final mataKuliah = service.mataKuliah
        .where((item) => filteredProdiIds.contains(item.prodiId))
        .toList();
    final mataKuliahIds = mataKuliah.map((item) => item.kode).toSet();
    final kelas = service.kelas
        .where((item) => mataKuliahIds.contains(item.mataKuliahId))
        .toList();
    final hasScopedRoomFilter =
        fakultasId != null ||
        prodiId != null ||
        allowedProdiIds.length != service.prodi.length;
    final usedRoomCodes = kelas.map((item) => item.ruangan).toSet();
    final ruangan = service.ruangan
        .where(
          (item) =>
              !hasScopedRoomFilter || usedRoomCodes.contains(item.kodeRuangan),
        )
        .toList();

    final prodiById = {for (final item in service.prodi) item.id: item};
    final fakultasById = {
      for (final item in service.fakultas) item.id: item.nama,
    };
    String scopeLabel(String targetProdiId) {
      final prodi = prodiById[targetProdiId];
      if (prodi == null) return targetProdiId;
      return '${prodi.nama} - ${fakultasById[prodi.fakultasId] ?? prodi.fakultasId}';
    }

    final listChildren = switch (selectedMenu) {
      _PimpinanDataMenu.mahasiswa => mahasiswa
          .map(
            (item) => ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(item.nama),
              subtitle: Text(
                '${item.nim} - ${item.status.label}\n${scopeLabel(item.prodiId)}',
              ),
              isThreeLine: true,
            ),
          )
          .toList(),
      _PimpinanDataMenu.dosen => dosen
          .map(
            (item) => ListTile(
              leading: const Icon(Icons.co_present_outlined),
              title: Text(item.nama),
              subtitle: Text('${item.nidn}\n${scopeLabel(item.prodiId)}'),
              isThreeLine: true,
            ),
          )
          .toList(),
      _PimpinanDataMenu.mataKuliah => mataKuliah
          .map(
            (item) => ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(item.nama),
              subtitle: Text(
                '${item.kode} - ${item.sks} SKS\n${scopeLabel(item.prodiId)}',
              ),
              isThreeLine: true,
            ),
          )
          .toList(),
      _PimpinanDataMenu.kelasKuliah => kelas
          .map(
            (item) {
              final mataKuliah = service.mataKuliah.firstWhere(
                (mk) => mk.kode == item.mataKuliahId,
              );
              return ListTile(
                leading: const Icon(Icons.class_outlined),
                title: Text('${mataKuliah.nama} - ${item.id}'),
                subtitle: Text(
                  '${item.hari}, ${item.jam} - ${service.getRuanganName(item.ruangan)}\n'
                  '${scopeLabel(mataKuliah.prodiId)}',
                ),
                isThreeLine: true,
              );
            },
          )
          .toList(),
      _PimpinanDataMenu.ruangKelas => ruangan
          .map(
            (item) => ListTile(
              leading: const Icon(Icons.meeting_room_outlined),
              title: Text(item.namaRuangan),
              subtitle: Text(
                '${item.kodeRuangan} - ${item.lokasi}\n'
                'Kapasitas ${item.kapasitasRuangan} orang',
              ),
              isThreeLine: true,
            ),
          )
          .toList(),
    };

    return AppScaffold(
      title: 'Data Universitas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ReadOnlyNotice(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Submenu Data Universitas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _PimpinanDataMenu.values
                        .map(
                          (menu) => ChoiceChip(
                            selected: selectedMenu == menu,
                            avatar: Icon(menu.icon, size: 18),
                            label: Text(menu.label),
                            onSelected: (_) => setState(() {
                              selectedMenu = menu;
                            }),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Filter<String>(
                    label: 'Fakultas',
                    value: fakultasId,
                    items: allowedFakultas
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.nama),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      fakultasId = value;
                      prodiId = null;
                    }),
                  ),
                  _Filter<String>(
                    label: 'Program Studi',
                    value: prodiId,
                    items: allowedProdi
                        .where(
                          (item) =>
                              fakultasId == null ||
                              item.fakultasId == fakultasId,
                        )
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.nama),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => prodiId = value),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      fakultasId = null;
                      prodiId = null;
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Filter'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PimpinanDataList(
            title: selectedMenu.label,
            count: listChildren.length,
            children: listChildren,
          ),
        ],
      ),
    );
  }
}

class PimpinanKrsView extends StatelessWidget {
  const PimpinanKrsView({this.user, super.key});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final allowedProdiIds = _allowedProdiIds(service, user);
    final allowedMahasiswaIds = service.mahasiswa
        .where((item) => allowedProdiIds.contains(item.prodiId))
        .map((item) => item.nim)
        .toSet();
    final krs = service.krs
        .where((item) => allowedMahasiswaIds.contains(item.mahasiswaId))
        .toList();
    return AppScaffold(
      title: 'Monitoring KRS',
      child: Column(
        children: [
          const _ReadOnlyNotice(),
          const SizedBox(height: 12),
          for (final item in krs)
            Card(
              child: ListTile(
                title: Text(service.getMahasiswaName(item.mahasiswaId)),
                subtitle: Text(
                  '${service.getMataKuliahName(service.kelas.firstWhere((k) => k.id == item.kelasId).mataKuliahId)} - Semester ${item.semester}',
                ),
                trailing: Chip(label: Text(_krsStatus(item))),
              ),
            ),
        ],
      ),
    );
  }
}

class PimpinanPresensiView extends StatefulWidget {
  const PimpinanPresensiView({this.user, super.key});

  final User? user;

  @override
  State<PimpinanPresensiView> createState() => _PimpinanPresensiViewState();
}

class _PimpinanPresensiViewState extends State<PimpinanPresensiView> {
  String? status;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final allowedProdiIds = _allowedProdiIds(service, widget.user);
    final mataKuliahIds = service.mataKuliah
        .where((item) => allowedProdiIds.contains(item.prodiId))
        .map((item) => item.kode)
        .toSet();
    final kelasIds = service.kelas
        .where((item) => mataKuliahIds.contains(item.mataKuliahId))
        .map((item) => item.id)
        .toSet();
    final pertemuanIds = service.pertemuan
        .where((item) => kelasIds.contains(item.kelasId))
        .map((item) => item.id)
        .toSet();
    final mahasiswa = service.presensi
        .where(
          (item) =>
              pertemuanIds.contains(item.pertemuanId) &&
              (status == null || _sameStatus(item.statusKehadiran, status!)),
        )
        .toList();
    final dosen = service.presensiDosen
        .where(
          (item) =>
              pertemuanIds.contains(item.pertemuanId) &&
              (status == null || _sameStatus(item.statusKehadiran, status!)),
        )
        .toList();
    return AppScaffold(
      title: 'Monitoring Presensi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ReadOnlyNotice(),
          const SizedBox(height: 12),
          _Filter<String>(
            label: 'Status Presensi',
            value: status,
            items: const [
              DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
              DropdownMenuItem(value: 'Izin', child: Text('Izin')),
              DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
              DropdownMenuItem(value: 'Alfa', child: Text('Alfa')),
            ],
            onChanged: (value) => setState(() => status = value),
          ),
          const SizedBox(height: 16),
          _DataSection(
            title: 'Rekap Presensi Mahasiswa',
            children: mahasiswa.map((item) {
              final pertemuan = service.pertemuan.firstWhere(
                (p) => p.id == item.pertemuanId,
              );
              final kelas = service.kelas.firstWhere(
                (k) => k.id == pertemuan.kelasId,
              );
              return ListTile(
                leading: Icon(
                  Icons.circle,
                  size: 14,
                  color: _statusColor(item.statusKehadiran),
                ),
                title: Text(service.getMahasiswaName(item.mahasiswaId)),
                subtitle: Text(
                  '${service.getMataKuliahName(kelas.mataKuliahId)} - Pertemuan ${pertemuan.pertemuanKe}',
                ),
                trailing: Text(item.statusKehadiran),
              );
            }).toList(),
          ),
          _DataSection(
            title: 'Rekap Presensi Dosen',
            children: dosen.map((item) {
              final pertemuan = service.pertemuan.firstWhere(
                (p) => p.id == item.pertemuanId,
              );
              final kelas = service.kelas.firstWhere(
                (k) => k.id == pertemuan.kelasId,
              );
              return ListTile(
                leading: Icon(
                  Icons.circle,
                  size: 14,
                  color: _statusColor(item.statusKehadiran),
                ),
                title: Text(service.getDosenName(item.dosenId)),
                subtitle: Text(
                  '${service.getMataKuliahName(kelas.mataKuliahId)} - Pertemuan ${pertemuan.pertemuanKe}',
                ),
                trailing: Text(item.statusKehadiran),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class PimpinanLaporanView extends StatelessWidget {
  const PimpinanLaporanView({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final prodiIds = user.tingkatPimpinan == TingkatPimpinan.dekan
        ? service.prodi
              .where((item) => item.fakultasId == user.scopeId)
              .map((item) => item.id)
              .toSet()
        : service.prodi.map((item) => item.id).toSet();
    final mahasiswa = service.mahasiswa
        .where((item) => prodiIds.contains(item.prodiId))
        .toList();
    final mataKuliahIds = service.mataKuliah
        .where((item) => prodiIds.contains(item.prodiId))
        .map((item) => item.kode)
        .toSet();
    final kelas = service.kelas
        .where((item) => mataKuliahIds.contains(item.mataKuliahId))
        .toList();
    final kelasIds = kelas.map((item) => item.id).toSet();
    final krs = service.krs
        .where((item) => kelasIds.contains(item.kelasId))
        .toList();
    final pertemuanIds = service.pertemuan
        .where((item) => kelasIds.contains(item.kelasId))
        .map((item) => item.id)
        .toSet();
    final presensi = service.presensi
        .where((item) => pertemuanIds.contains(item.pertemuanId))
        .toList();
    final presensiDosen = service.presensiDosen
        .where((item) => pertemuanIds.contains(item.pertemuanId))
        .toList();
    final metrics = service.fakultas
        .where(
          (item) =>
              user.tingkatPimpinan != TingkatPimpinan.dekan ||
              item.id == user.scopeId,
        )
        .map(
          (item) =>
              _fakultasMetric(service, item.id, service.tahunAjaranAktif.id),
        )
        .toList();
    return AppScaffold(
      title: user.tingkatPimpinan == TingkatPimpinan.rektor
          ? 'Laporan Akademik Rektor'
          : 'Laporan Fakultas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ReadOnlyNotice(),
          const SizedBox(height: 12),
          _StatSection(
            title: 'Ringkasan Laporan',
            stats: [
              _Stat('Program Studi', prodiIds.length),
              _Stat('Mahasiswa', mahasiswa.length),
              _Stat('Kelas Kuliah', kelas.length),
              _Stat('Tahun Akademik Aktif', service.tahunAjaranAktif.label),
            ],
          ),
          _StatSection(
            title: 'Rekap KRS',
            stats: [
              _Stat('Total KRS', krs.length),
              _Stat('Draft', krs.where((item) => !item.isSubmitted).length),
              _Stat(
                'Diajukan',
                krs
                    .where(
                      (item) =>
                          item.isSubmitted &&
                          !item.isValidated &&
                          !item.isRejected,
                    )
                    .length,
              ),
              _Stat('Disetujui', krs.where((item) => item.isValidated).length),
              _Stat('Ditolak', krs.where((item) => item.isRejected).length),
            ],
          ),
          _StatSection(
            title: 'Rekap Presensi',
            stats: [
              _Stat('Presensi Mahasiswa', presensi.length),
              _Stat(
                'Kehadiran Mahasiswa',
                _percentage(_countStatus(presensi, 'Hadir'), presensi.length),
              ),
              _Stat('Presensi Dosen', presensiDosen.length),
              _Stat(
                'Kehadiran Dosen',
                _percentage(
                  _countDosenStatus(presensiDosen, 'Hadir'),
                  presensiDosen.length,
                ),
              ),
            ],
          ),
          _StatSection(
            title: 'Rekap Kelas dan Ruangan',
            stats: [
              _Stat('Kelas Kuliah', kelas.length),
              _Stat(
                'Kelas Penuh',
                kelas.where((item) => service.isKelasPenuh(item.id)).length,
              ),
              _Stat(
                'Ruangan Terpakai',
                kelas.map((item) => item.ruangan).toSet().length,
              ),
              _Stat('Total Ruangan', service.ruangan.length),
            ],
          ),
          _RektorFakultasComparison(metrics: metrics),
        ],
      ),
    );
  }
}

class _ReadOnlyNotice extends StatelessWidget {
  const _ReadOnlyNotice();

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.visibility_outlined),
      title: const Text('Mode read only'),
      subtitle: const Text(
        'Pimpinan hanya dapat melihat data tanpa mengubahnya.',
      ),
    ),
  );
}

class _DataSection extends StatelessWidget {
  const _DataSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    child: ExpansionTile(
      key: PageStorageKey<String>('pimpinan-data-section-$title'),
      initiallyExpanded: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: children.isEmpty
          ? const [ListTile(title: Text('Belum ada data'))]
          : children,
    ),
  );
}

class _PimpinanDataList extends StatelessWidget {
  const _PimpinanDataList({
    required this.title,
    required this.count,
    required this.children,
  });

  final String title;
  final int count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              'Data $title',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Chip(label: Text('$count data')),
          ),
          const Divider(height: 1),
          if (children.isEmpty)
            const ListTile(title: Text('Belum ada data untuk filter ini'))
          else
            ...children,
        ],
      ),
    ),
  );
}

class _StatSection extends StatelessWidget {
  const _StatSection({required this.title, required this.stats, this.action});
  final String title;
  final List<_Stat> stats;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 900
                  ? (constraints.maxWidth - 36) / 4
                  : constraints.maxWidth >= 520
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: stats
                    .map(
                      (item) => SizedBox(
                        width: width,
                        child: _StatCard(stat: item),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});
  final _Stat stat;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${stat.value}',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(stat.label),
      ],
    ),
  );
}

class _Filter<T> extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 230,
    height: 60,
    child: DropdownButtonHideUnderline(
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        itemHeight: 48,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
        ),
        selectedItemBuilder: (context) => items
            .map(
              (item) => Align(
                alignment: Alignment.centerLeft,
                child: DefaultTextStyle.merge(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: item.child,
                ),
              ),
            )
            .toList(),
        items: items,
        onChanged: onChanged,
      ),
    ),
  );
}

class _Stat {
  const _Stat(this.label, this.value);
  final String label;
  final Object value;
}

int _countStatus(List<Presensi> items, String status) =>
    items.where((item) => item.statusKehadiran == status).length;
int _countDosenStatus(List<PresensiDosen> items, String status) =>
    items.where((item) => item.statusKehadiran == status).length;
String _percentage(int value, int total) =>
    total == 0 ? '0%' : '${(value / total * 100).toStringAsFixed(0)}%';
String _krsStatus(KRS item) => item.isRejected
    ? 'Ditolak'
    : item.isValidated
    ? 'Disetujui'
    : item.isSubmitted
    ? 'Diajukan'
    : 'Draft';
bool _sameStatus(String value, String expected) {
  if (expected == 'Izin') return value == 'Izin' || value == 'Ijin';
  if (expected == 'Alfa') return value == 'Alfa' || value == 'Alpa';
  return value == expected;
}

Color _statusColor(String status) {
  if (status == 'Hadir') return Colors.green;
  if (status == 'Izin' || status == 'Ijin') return Colors.amber;
  if (status == 'Sakit') return Colors.blue;
  return Colors.red;
}

class _DekanCharts extends StatelessWidget {
  const _DekanCharts({
    required this.krs,
    required this.presensiMahasiswa,
    required this.presensiDosen,
  });

  final List<KRS> krs;
  final List<Presensi> presensiMahasiswa;
  final List<PresensiDosen> presensiDosen;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Grafik Monitoring',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth >= 900
                    ? (constraints.maxWidth - 24) / 3
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: width,
                      child: _BarChartCard(
                        title: 'Grafik KRS',
                        values: {
                          'Draft': krs
                              .where((item) => !item.isSubmitted)
                              .length,
                          'Diajukan': krs
                              .where(
                                (item) =>
                                    item.isSubmitted &&
                                    !item.isValidated &&
                                    !item.isRejected,
                              )
                              .length,
                          'Setuju': krs
                              .where((item) => item.isValidated)
                              .length,
                          'Tolak': krs.where((item) => item.isRejected).length,
                        },
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _BarChartCard(
                        title: 'Grafik Presensi Mahasiswa',
                        values: _presensiCounts(presensiMahasiswa),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _BarChartCard(
                        title: 'Grafik Presensi Dosen',
                        values: _presensiDosenCounts(presensiDosen),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({required this.title, required this.values});

  final String title;
  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.values.fold<int>(
      1,
      (current, value) => value > current ? value : current,
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          for (final entry in values.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(width: 58, child: Text(entry.key)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value / maxValue,
                        minHeight: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 28,
                    child: Text('${entry.value}', textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DekanWarnings extends StatelessWidget {
  const _DekanWarnings({
    required this.belumKrs,
    required this.dosenBelumPresensi,
    required this.mataKuliahPresensiRendah,
  });

  final int belumKrs;
  final int dosenBelumPresensi;
  final int mataKuliahPresensiRendah;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Peringatan',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _WarningTile(
              icon: Icons.assignment_late_outlined,
              label: 'Mahasiswa belum KRS',
              value: belumKrs,
            ),
            _WarningTile(
              icon: Icons.person_off_outlined,
              label: 'Dosen belum presensi',
              value: dosenBelumPresensi,
            ),
            _WarningTile(
              icon: Icons.trending_down_outlined,
              label: 'Mata kuliah presensi rendah',
              value: mataKuliahPresensiRendah,
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningTile extends StatelessWidget {
  const _WarningTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: value == 0 ? Colors.green : Colors.orange),
    title: Text(label),
    trailing: Chip(label: Text('$value')),
  );
}

Map<String, int> _presensiCounts(List<Presensi> items) => {
  'Hadir': _countStatus(items, 'Hadir'),
  'Izin': _countStatus(items, 'Izin') + _countStatus(items, 'Ijin'),
  'Sakit': _countStatus(items, 'Sakit'),
  'Alfa': _countStatus(items, 'Alfa') + _countStatus(items, 'Alpa'),
};

Map<String, int> _presensiDosenCounts(List<PresensiDosen> items) => {
  'Hadir': _countDosenStatus(items, 'Hadir'),
  'Izin': _countDosenStatus(items, 'Izin'),
  'Sakit': _countDosenStatus(items, 'Sakit'),
  'Alfa': _countDosenStatus(items, 'Alfa'),
};

class _FakultasMetric {
  const _FakultasMetric({
    required this.nama,
    required this.prodi,
    required this.mahasiswa,
    required this.dosen,
    required this.kelasAktif,
    required this.krsDisetujui,
    required this.presensiMahasiswa,
    required this.presensiDosen,
    required this.ruanganTerpakai,
  });

  final String nama;
  final int prodi;
  final int mahasiswa;
  final int dosen;
  final int kelasAktif;
  final double krsDisetujui;
  final double presensiMahasiswa;
  final double presensiDosen;
  final int ruanganTerpakai;

  String get status {
    if (krsDisetujui >= 0.8 && presensiMahasiswa >= 0.75) return 'Baik';
    if (krsDisetujui < 0.5 || presensiMahasiswa < 0.5) return 'Kritis';
    return 'Perlu Perhatian';
  }
}

_FakultasMetric _fakultasMetric(
  MockService service,
  String fakultasId,
  String tahunAjaranId,
) {
  final prodiIds = service.prodi
      .where((item) => item.fakultasId == fakultasId)
      .map((item) => item.id)
      .toSet();
  final mahasiswaIds = service.mahasiswa
      .where((item) => prodiIds.contains(item.prodiId))
      .map((item) => item.nim)
      .toSet();
  final dosenIds = service.dosen
      .where((item) => prodiIds.contains(item.prodiId))
      .map((item) => item.nidn)
      .toSet();
  final mkIds = service.mataKuliah
      .where((item) => prodiIds.contains(item.prodiId))
      .map((item) => item.kode)
      .toSet();
  final kelas = service.kelas
      .where(
        (item) =>
            mkIds.contains(item.mataKuliahId) &&
            item.tahunAjaranId == tahunAjaranId,
      )
      .toList();
  final kelasIds = kelas.map((item) => item.id).toSet();
  final krs = service.krs
      .where(
        (item) =>
            mahasiswaIds.contains(item.mahasiswaId) &&
            kelasIds.contains(item.kelasId),
      )
      .toList();
  final pertemuan = service.pertemuan
      .where((item) => kelasIds.contains(item.kelasId))
      .toList();
  final pertemuanIds = pertemuan.map((item) => item.id).toSet();
  final presensi = service.presensi
      .where((item) => pertemuanIds.contains(item.pertemuanId))
      .toList();
  final presensiDosen = service.presensiDosen
      .where(
        (item) =>
            pertemuanIds.contains(item.pertemuanId) &&
            dosenIds.contains(item.dosenId),
      )
      .toList();
  return _FakultasMetric(
    nama: service.fakultas.firstWhere((item) => item.id == fakultasId).nama,
    prodi: prodiIds.length,
    mahasiswa: mahasiswaIds.length,
    dosen: dosenIds.length,
    kelasAktif: pertemuan
        .where((item) => item.status == StatusPertemuan.berlangsung)
        .map((item) => item.kelasId)
        .toSet()
        .length,
    krsDisetujui: krs.isEmpty
        ? 0
        : krs.where((item) => item.isValidated).length / krs.length,
    presensiMahasiswa: presensi.isEmpty
        ? 0
        : _countStatus(presensi, 'Hadir') / presensi.length,
    presensiDosen: presensiDosen.isEmpty
        ? 0
        : _countDosenStatus(presensiDosen, 'Hadir') / presensiDosen.length,
    ruanganTerpakai: kelas.map((item) => item.ruangan).toSet().length,
  );
}

class _RektorFakultasComparison extends StatelessWidget {
  const _RektorFakultasComparison({required this.metrics});
  final List<_FakultasMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Perbandingan Antar Fakultas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Fakultas')),
                  DataColumn(label: Text('Prodi')),
                  DataColumn(label: Text('Mahasiswa')),
                  DataColumn(label: Text('Dosen')),
                  DataColumn(label: Text('Kelas Aktif')),
                  DataColumn(label: Text('KRS Disetujui')),
                  DataColumn(label: Text('Presensi Mhs')),
                  DataColumn(label: Text('Presensi Dosen')),
                  DataColumn(label: Text('Ruangan')),
                  DataColumn(label: Text('Status')),
                ],
                rows: metrics
                    .map(
                      (item) => DataRow(
                        cells: [
                          DataCell(Text(item.nama)),
                          DataCell(Text('${item.prodi}')),
                          DataCell(Text('${item.mahasiswa}')),
                          DataCell(Text('${item.dosen}')),
                          DataCell(Text('${item.kelasAktif}')),
                          DataCell(
                            Text(
                              '${(item.krsDisetujui * 100).toStringAsFixed(0)}%',
                            ),
                          ),
                          DataCell(
                            Text(
                              '${(item.presensiMahasiswa * 100).toStringAsFixed(0)}%',
                            ),
                          ),
                          DataCell(
                            Text(
                              '${(item.presensiDosen * 100).toStringAsFixed(0)}%',
                            ),
                          ),
                          DataCell(Text('${item.ruanganTerpakai}')),
                          DataCell(Chip(label: Text(item.status))),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            _BarChartCard(
              title: 'Jumlah Mahasiswa per Fakultas',
              values: {for (final item in metrics) item.nama: item.mahasiswa},
            ),
          ],
        ),
      ),
    );
  }
}

class _RektorAlerts extends StatelessWidget {
  const _RektorAlerts({
    required this.belumKrs,
    required this.menungguValidasi,
    required this.ruanganKosong,
    required this.kelasPenuh,
  });

  final int belumKrs;
  final int menungguValidasi;
  final int ruanganKosong;
  final int kelasPenuh;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Peringatan Akademik Universitas',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _WarningTile(
            icon: Icons.assignment_late_outlined,
            label: 'Mahasiswa belum mengisi KRS',
            value: belumKrs,
          ),
          _WarningTile(
            icon: Icons.pending_actions_outlined,
            label: 'KRS masih menunggu validasi',
            value: menungguValidasi,
          ),
          _WarningTile(
            icon: Icons.meeting_room_outlined,
            label: 'Ruangan belum digunakan',
            value: ruanganKosong,
          ),
          _WarningTile(
            icon: Icons.groups_outlined,
            label: 'Kelas dengan kapasitas penuh',
            value: kelasPenuh,
          ),
        ],
      ),
    ),
  );
}

String _tanggalHariIni() {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}/${now.year}';
}

Set<String> _allowedProdiIds(MockService service, User? user) {
  if (user?.tingkatPimpinan == TingkatPimpinan.dekan) {
    return service.prodi
        .where((item) => item.fakultasId == user!.scopeId)
        .map((item) => item.id)
        .toSet();
  }
  if (user?.tingkatPimpinan == TingkatPimpinan.korpro) {
    return {user!.scopeId};
  }
  return service.prodi.map((item) => item.id).toSet();
}

class _IpkTahunPoint {
  const _IpkTahunPoint({required this.label, required this.value});
  final String label;
  final double value;
}

class _IpkTahunPainter extends CustomPainter {
  const _IpkTahunPainter({
    required this.points,
    required this.primary,
    required this.onSurface,
  });

  final List<_IpkTahunPoint> points;
  final Color primary;
  final Color onSurface;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 36.0;
    const top = 12.0;
    const bottom = 54.0;
    const right = 12.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final grid = Paint()
      ..color = onSurface.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    final line = Paint()
      ..color = primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = primary;

    for (var index = 0; index <= 4; index++) {
      final y = chart.bottom - (index / 4) * chart.height;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
      _drawChartText(canvas, '$index.0', Offset(2, y - 7), onSurface, 10);
    }

    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1
          ? chart.center.dx
          : chart.left + (index / (points.length - 1)) * chart.width;
      final y = chart.bottom - (points[index].value / 4) * chart.height;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 5, dot);
      _drawChartText(
        canvas,
        points[index].value.toStringAsFixed(2),
        Offset(x - 13, y - 24),
        primary,
        11,
      );
      _drawChartText(
        canvas,
        points[index].label,
        Offset(x - 34, chart.bottom + 10),
        onSurface,
        9,
        width: 68,
        center: true,
      );
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _IpkTahunPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.primary != primary ||
      oldDelegate.onSurface != onSurface;
}

void _drawChartText(
  Canvas canvas,
  String text,
  Offset offset,
  Color color,
  double size, {
  double? width,
  bool center = false,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: size),
    ),
    textDirection: TextDirection.ltr,
    textAlign: center ? TextAlign.center : TextAlign.left,
  )..layout(maxWidth: width ?? double.infinity);
  painter.paint(canvas, offset);
}

double _bobotNilai(String nilai) {
  switch (nilai.toUpperCase()) {
    case 'A':
      return 4;
    case 'B+':
      return 3.5;
    case 'B':
      return 3;
    case 'C+':
      return 2.5;
    case 'C':
      return 2;
    case 'D':
      return 1;
    default:
      return 0;
  }
}

int _urutanHari(String hari) {
  const urutan = {
    'Senin': 1,
    'Selasa': 2,
    'Rabu': 3,
    'Kamis': 4,
    'Jumat': 5,
    'Sabtu': 6,
    'Minggu': 7,
  };
  return urutan[hari] ?? 8;
}
