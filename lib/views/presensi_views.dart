import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import '../utils/app_helpers.dart';
import '../widgets/app_scaffold.dart';

class MahasiswaPresensiView extends StatefulWidget {
  const MahasiswaPresensiView({required this.mahasiswaId, super.key});

  final String mahasiswaId;

  @override
  State<MahasiswaPresensiView> createState() => _MahasiswaPresensiViewState();
}

class _MahasiswaPresensiViewState extends State<MahasiswaPresensiView> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final kelasIds = service.krs
        .where(
          (item) => item.mahasiswaId == widget.mahasiswaId && item.isValidated,
        )
        .map((item) => item.kelasId)
        .toSet();
    final pertemuan =
        service.pertemuan
            .where((item) => kelasIds.contains(item.kelasId))
            .toList()
          ..sort((a, b) => b.pertemuanKe.compareTo(a.pertemuanKe));
    final riwayat = service.presensi
        .where((item) => item.mahasiswaId == widget.mahasiswaId)
        .toList();

    return AppScaffold(
      title: 'Presensi Mahasiswa',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PersentaseKehadiran(
            kelasIds: kelasIds,
            mahasiswaId: widget.mahasiswaId,
            service: service,
          ),
          const SizedBox(height: 16),
          Text(
            'Pertemuan Aktif',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...pertemuan
              .where((item) => item.status == StatusPertemuan.berlangsung)
              .map((item) => _activeTile(context, service, item)),
          if (!pertemuan.any(
            (item) => item.status == StatusPertemuan.berlangsung,
          ))
            const Card(
              child: ListTile(
                leading: Icon(Icons.event_busy_outlined),
                title: Text('Tidak ada pertemuan yang sedang dibuka'),
              ),
            ),
          const SizedBox(height: 18),
          Text(
            'Riwayat Presensi',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (riwayat.isEmpty)
            const Card(child: ListTile(title: Text('Belum ada riwayat')))
          else
            for (final item in riwayat.reversed) _historyTile(service, item),
        ],
      ),
    );
  }

  Widget _activeTile(
    BuildContext context,
    MockService service,
    Pertemuan item,
  ) {
    final kelas = service.kelas.firstWhere((k) => k.id == item.kelasId);
    final existing = service.presensi.any(
      (p) => p.pertemuanId == item.id && p.mahasiswaId == widget.mahasiswaId,
    );
    return Card(
      child: ListTile(
        leading: const Icon(Icons.how_to_reg_outlined),
        title: Text(service.getMataKuliahName(kelas.mataKuliahId)),
        subtitle: Text(
          'Pertemuan ${item.pertemuanKe} - ${item.materi ?? 'Tanpa materi'}',
        ),
        trailing: FilledButton(
          onPressed: existing
              ? null
              : () {
                  try {
                    final message = service.isiPresensiMahasiswa(
                      pertemuanId: item.id,
                      mahasiswaId: widget.mahasiswaId,
                    );
                    setState(() {});
                    showAppMessage(context, message);
                  } catch (error) {
                    showAppMessage(context, error.toString());
                  }
                },
          child: Text(existing ? 'Sudah Hadir' : 'Hadir'),
        ),
      ),
    );
  }

  Widget _historyTile(MockService service, Presensi item) {
    final pertemuan = service.pertemuan.firstWhere(
      (p) => p.id == item.pertemuanId,
    );
    final kelas = service.kelas.firstWhere((k) => k.id == pertemuan.kelasId);
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.circle,
          size: 14,
          color: _statusColor(item.statusKehadiran),
        ),
        title: Text(service.getMataKuliahName(kelas.mataKuliahId)),
        subtitle: Text(
          'Pertemuan ${pertemuan.pertemuanKe}'
          '${item.waktuPresensi == null ? '' : ' - ${_date(item.waktuPresensi!)}'}',
        ),
        trailing: Text(item.statusKehadiran),
      ),
    );
  }
}

class _PersentaseKehadiran extends StatelessWidget {
  const _PersentaseKehadiran({
    required this.kelasIds,
    required this.mahasiswaId,
    required this.service,
  });

  final Set<String> kelasIds;
  final String mahasiswaId;
  final MockService service;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Persentase Kehadiran',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final kelasId in kelasIds) _progress(context, kelasId),
          ],
        ),
      ),
    );
  }

  Widget _progress(BuildContext context, String kelasId) {
    final kelas = service.kelas.firstWhere((item) => item.id == kelasId);
    final pertemuanIds = service.pertemuan
        .where(
          (item) =>
              item.kelasId == kelasId &&
              item.status != StatusPertemuan.belumDimulai,
        )
        .map((item) => item.id)
        .toSet();
    final hadir = service.presensi
        .where(
          (item) =>
              item.mahasiswaId == mahasiswaId &&
              pertemuanIds.contains(item.pertemuanId) &&
              item.statusKehadiran == 'Hadir',
        )
        .length;
    final value = pertemuanIds.isEmpty ? 0.0 : hadir / pertemuanIds.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(service.getMataKuliahName(kelas.mataKuliahId)),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: value),
          Text(
            '$hadir/${pertemuanIds.length} hadir (${(value * 100).toStringAsFixed(0)}%)',
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} '
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

Color _statusColor(String status) {
  if (status == 'Hadir') return Colors.green;
  if (status == 'Izin' || status == 'Ijin') return Colors.amber;
  if (status == 'Sakit') return Colors.blue;
  return Colors.red;
}
