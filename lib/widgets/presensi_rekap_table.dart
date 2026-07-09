import 'package:flutter/material.dart';

import '../models/siakad_models.dart';
import '../services/mock_service.dart';

class PresensiRekapTable extends StatelessWidget {
  const PresensiRekapTable({
    required this.title,
    required this.subtitle,
    required this.rows,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<PresensiRekapRow> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalPertemuan = rows.fold<int>(
      0,
      (sum, row) => sum + row.totalPertemuan,
    );
    final hadir = rows.fold<int>(0, (sum, row) => sum + row.hadir);
    final percent = totalPertemuan == 0 ? 0.0 : hadir / totalPertemuan;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.fact_check_outlined, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _RekapPercentBadge(value: percent),
              ],
            ),
            const SizedBox(height: 14),
            if (rows.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Belum ada data presensi semester aktif.'),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(
                      scheme.primaryContainer.withValues(alpha: 0.55),
                    ),
                    columns: const [
                      DataColumn(label: Text('Mata Kuliah')),
                      DataColumn(label: Text('Total Pertemuan'), numeric: true),
                      DataColumn(label: Text('Hadir'), numeric: true),
                      DataColumn(label: Text('Izin'), numeric: true),
                      DataColumn(label: Text('Sakit'), numeric: true),
                      DataColumn(label: Text('Alpha'), numeric: true),
                      DataColumn(label: Text('Persentase'), numeric: true),
                    ],
                    rows: [
                      for (final row in rows)
                        DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 220,
                                child: Text(
                                  row.mataKuliah,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(Text('${row.totalPertemuan}')),
                            DataCell(Text('${row.hadir}')),
                            DataCell(Text('${row.izin}')),
                            DataCell(Text('${row.sakit}')),
                            DataCell(Text('${row.alpha}')),
                            DataCell(Text(row.percentLabel)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RekapPercentBadge extends StatelessWidget {
  const _RekapPercentBadge({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = value >= 0.75
        ? Colors.green
        : value >= 0.5
        ? Colors.orange
        : scheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${(value * 100).toStringAsFixed(1)}%',
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class PresensiRekapRow {
  const PresensiRekapRow({
    required this.mataKuliah,
    required this.totalPertemuan,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpha,
  });

  final String mataKuliah;
  final int totalPertemuan;
  final int hadir;
  final int izin;
  final int sakit;
  final int alpha;

  String get percentLabel {
    if (totalPertemuan == 0) return '0,0%';
    final percent = hadir / totalPertemuan * 100;
    return '${percent.toStringAsFixed(1).replaceAll('.', ',')}%';
  }
}

List<PresensiRekapRow> buildMahasiswaPresensiRekap({
  required MockService service,
  required String mahasiswaId,
}) {
  final activeYearId = service.tahunAjaranAktif.id;
  final kelasIds = service.krs
      .where(
        (item) =>
            item.mahasiswaId == mahasiswaId &&
            item.isValidated &&
            item.tahunAjaranId == activeYearId,
      )
      .map((item) => item.kelasId)
      .toSet();

  return _buildRekapRows(
    service: service,
    kelasIds: kelasIds,
    statusFor: (pertemuan) {
      final matches = service.presensi.where(
        (item) =>
            item.mahasiswaId == mahasiswaId && item.pertemuanId == pertemuan.id,
      );
      if (matches.isEmpty) return 'Alpha';
      return matches.first.statusKehadiran;
    },
  );
}

List<PresensiRekapRow> buildDosenPresensiRekap({
  required MockService service,
  required String dosenId,
}) {
  final activeYearId = service.tahunAjaranAktif.id;
  final kelasIds = service.kelas
      .where(
        (item) =>
            item.tahunAjaranId == activeYearId &&
            service.isDosenMengajarKelas(dosenId, item.id),
      )
      .map((item) => item.id)
      .toSet();

  return _buildRekapRows(
    service: service,
    kelasIds: kelasIds,
    statusFor: (pertemuan) {
      final matches = service.presensiDosen.where(
        (item) => item.dosenId == dosenId && item.pertemuanId == pertemuan.id,
      );
      if (matches.isEmpty) return 'Alpha';
      return matches.first.statusKehadiran;
    },
  );
}

List<PresensiRekapRow> _buildRekapRows({
  required MockService service,
  required Set<String> kelasIds,
  required String Function(Pertemuan pertemuan) statusFor,
}) {
  final rows = <PresensiRekapRow>[];
  for (final kelasId in kelasIds) {
    final kelas = service.kelas.firstWhere((item) => item.id == kelasId);
    final pertemuan = service.pertemuan
        .where(
          (item) =>
              item.kelasId == kelasId &&
              item.status != StatusPertemuan.belumDimulai,
        )
        .toList();
    var hadir = 0;
    var izin = 0;
    var sakit = 0;
    var alpha = 0;
    for (final item in pertemuan) {
      switch (_normalizedStatus(statusFor(item))) {
        case 'Hadir':
          hadir++;
        case 'Izin':
          izin++;
        case 'Sakit':
          sakit++;
        case 'Alpha':
          alpha++;
      }
    }
    rows.add(
      PresensiRekapRow(
        mataKuliah: service.getMataKuliahName(kelas.mataKuliahId),
        totalPertemuan: pertemuan.length,
        hadir: hadir,
        izin: izin,
        sakit: sakit,
        alpha: alpha,
      ),
    );
  }
  rows.sort((a, b) => a.mataKuliah.compareTo(b.mataKuliah));
  return rows;
}

String _normalizedStatus(String status) {
  final value = status.trim().toLowerCase();
  if (value == 'hadir') return 'Hadir';
  if (value == 'izin' || value == 'ijin') return 'Izin';
  if (value == 'sakit') return 'Sakit';
  return 'Alpha';
}
