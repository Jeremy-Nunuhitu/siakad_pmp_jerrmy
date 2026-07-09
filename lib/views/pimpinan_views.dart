import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import '../widgets/app_scaffold.dart';

part 'pimpinan/dashboard_snapshots.dart';
part 'pimpinan/rektor_dashboard_widgets.dart';

class KorproDashboardView extends StatefulWidget {
  const KorproDashboardView({required this.user, super.key});

  final User user;

  @override
  State<KorproDashboardView> createState() => _KorproDashboardViewState();
}

class _KorproDashboardViewState extends State<KorproDashboardView> {
  DashboardCacheKey? _cachedKey;
  _KorproDashboardSnapshot? _cachedSnapshot;

  _KorproDashboardSnapshot _snapshotFor(MockService service) {
    final tahunAktif = service.tahunAjaran.firstWhere(
      (item) => item.aktif,
      orElse: () => service.tahunAjaran.last,
    );
    final key = DashboardCacheKey(
      revision: service.dataRevision,
      tahunAjaranId: tahunAktif.id,
      prodiId: widget.user.scopeId,
    );
    if (_cachedKey == key && _cachedSnapshot != null) {
      return _cachedSnapshot!;
    }
    final snapshot = _KorproDashboardSnapshot.build(
      service: service,
      prodiId: widget.user.scopeId,
    );
    _cachedKey = key;
    _cachedSnapshot = snapshot;
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
    final snapshot = _snapshotFor(service);
    final prodi = snapshot.prodi;
    final mahasiswa = snapshot.mahasiswa;
    final mataKuliahIds = snapshot.mataKuliahIds;
    final ruangKelas = snapshot.ruangKelas;
    final tahunAktif = snapshot.tahunAktif;
    final kelasAktif = snapshot.kelasAktif;
    final kelasMetrics = snapshot.kelasMetrics;
    final krsRate = snapshot.krsRate;
    final activeStudents = snapshot.activeStudents;
    final avgIpk = snapshot.avgIpk;
    final avgPresensi = snapshot.avgPresensi;
    final avgSks = snapshot.avgSks;
    final riskStudents = snapshot.riskStudents;
    final completedMeetings = snapshot.completedMeetings;
    final totalMeetingSlots = snapshot.totalMeetingSlots;
    final meetingProgress = snapshot.meetingProgress;
    final healthScore = snapshot.healthScore;
    final rankedStudents = snapshot.rankedStudents;
    final rankedClasses = snapshot.rankedClasses;
    final points = snapshot.points;

    return AppScaffold(
      title: 'Dashboard Korpro',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KorproCommandHero(
            prodiName: prodi.nama,
            tahunLabel: tahunAktif.label,
            healthScore: healthScore,
            mahasiswa: mahasiswa.length,
            kelasAktif: kelasAktif.length,
            riskStudents: riskStudents,
          ),
          const SizedBox(height: 14),
          _KorproDashboardKpiGrid(
            activeStudents: activeStudents,
            totalStudents: mahasiswa.length,
            avgIpk: avgIpk,
            avgPresensi: avgPresensi,
            krsRate: krsRate,
            meetingProgress: meetingProgress,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final academyPanel = _KorproAcademicPulse(
                points: points,
                avgIpk: avgIpk,
                avgSks: avgSks,
                mataKuliah: mataKuliahIds.length,
                ruangKelas: ruangKelas.length,
              );
              final operationPanel = _KorproOperationalPulse(
                kelasMetrics: kelasMetrics,
                rankedClasses: rankedClasses,
                completedMeetings: completedMeetings,
                totalMeetingSlots: totalMeetingSlots,
              );
              if (constraints.maxWidth < 940) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    academyPanel,
                    const SizedBox(height: 14),
                    operationPanel,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: academyPanel),
                  const SizedBox(width: 14),
                  Expanded(flex: 2, child: operationPanel),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _KorproDashboardInsightPanel(
            students: rankedStudents.take(5).toList(),
            classes: rankedClasses.take(5).toList(),
          ),
        ],
      ),
    );
  }
}

class _KorproCommandHero extends StatelessWidget {
  const _KorproCommandHero({
    required this.prodiName,
    required this.tahunLabel,
    required this.healthScore,
    required this.mahasiswa,
    required this.kelasAktif,
    required this.riskStudents,
  });

  final String prodiName;
  final String tahunLabel;
  final double healthScore;
  final int mahasiswa;
  final int kelasAktif;
  final int riskStudents;

  @override
  Widget build(BuildContext context) {
    final score = healthScore.clamp(0, 100);
    final color = _dashboardScoreColor(score / 100);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.18),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Program Study Command Center',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prodiName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tahun ajaran aktif: $tahunLabel',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _KorproHeroChip(
                        icon: Icons.groups_rounded,
                        label: '$mahasiswa mahasiswa',
                      ),
                      _KorproHeroChip(
                        icon: Icons.class_rounded,
                        label: '$kelasAktif kelas aktif',
                      ),
                      _KorproHeroChip(
                        icon: riskStudents == 0
                            ? Icons.verified_outlined
                            : Icons.warning_amber_rounded,
                        label: '$riskStudents perlu atensi',
                      ),
                    ],
                  ),
                ],
              );
              final scoreWidget = Tooltip(
                message:
                    'Health score gabungan dari presensi, IPK, KRS, dan progress pertemuan.',
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score / 100),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => SizedBox(
                    width: 150,
                    height: 150,
                    child: CustomPaint(
                      painter: _KorproGaugePainter(
                        value: value,
                        color: color,
                        trackColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              (value * 100).toStringAsFixed(0),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: color,
                                  ),
                            ),
                            const Text(
                              'health',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
              if (constraints.maxWidth < 680) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 18),
                    Center(child: scoreWidget),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 18),
                  scoreWidget,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _KorproHeroChip extends StatelessWidget {
  const _KorproHeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 18),
    label: Text(label),
    visualDensity: VisualDensity.compact,
  );
}

class _KorproDashboardKpiGrid extends StatelessWidget {
  const _KorproDashboardKpiGrid({
    required this.activeStudents,
    required this.totalStudents,
    required this.avgIpk,
    required this.avgPresensi,
    required this.krsRate,
    required this.meetingProgress,
  });

  final int activeStudents;
  final int totalStudents;
  final double avgIpk;
  final double avgPresensi;
  final double krsRate;
  final double meetingProgress;

  @override
  Widget build(BuildContext context) {
    final activeRate = totalStudents == 0
        ? 0.0
        : activeStudents / totalStudents;
    final items = [
      _KorproDashboardKpi(
        label: 'Mahasiswa Aktif',
        value: '$activeStudents/$totalStudents',
        progress: activeRate,
        icon: Icons.verified_user_outlined,
        color: _attendanceRateColor(activeRate),
      ),
      _KorproDashboardKpi(
        label: 'Rata-rata IPK',
        value: avgIpk.toStringAsFixed(2),
        progress: (avgIpk / 4).clamp(0.0, 1.0),
        icon: Icons.trending_up_rounded,
        color: _academicColor(avgIpk),
      ),
      _KorproDashboardKpi(
        label: 'Rata-rata Presensi',
        value: '${(avgPresensi * 100).toStringAsFixed(0)}%',
        progress: avgPresensi,
        icon: Icons.how_to_reg_rounded,
        color: _attendanceRateColor(avgPresensi),
      ),
      _KorproDashboardKpi(
        label: 'KRS Disetujui',
        value: '${(krsRate * 100).toStringAsFixed(0)}%',
        progress: krsRate,
        icon: Icons.fact_check_outlined,
        color: _attendanceRateColor(krsRate),
      ),
      _KorproDashboardKpi(
        label: 'Progress Pertemuan',
        value: '${(meetingProgress * 100).toStringAsFixed(0)}%',
        progress: meetingProgress,
        icon: Icons.event_available_rounded,
        color: _attendanceRateColor(meetingProgress),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1120
            ? 5
            : constraints.maxWidth >= 760
            ? 3
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 12)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var index = 0; index < items.length; index++)
              SizedBox(
                width: width,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 320 + index * 75),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(0, 14 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  ),
                  child: _KorproDashboardKpiCard(kpi: items[index]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KorproDashboardKpi {
  const _KorproDashboardKpi({
    required this.label,
    required this.value,
    required this.progress,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final IconData icon;
  final Color color;
}

class _KorproDashboardKpiCard extends StatelessWidget {
  const _KorproDashboardKpiCard({required this.kpi});

  final _KorproDashboardKpi kpi;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(kpi.icon, color: kpi.color),
              const Spacer(),
              Text(
                kpi.value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: kpi.color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(kpi.label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: kpi.progress.clamp(0, 1)),
            duration: const Duration(milliseconds: 740),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: kpi.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    ),
  );
}

class _KorproAcademicPulse extends StatelessWidget {
  const _KorproAcademicPulse({
    required this.points,
    required this.avgIpk,
    required this.avgSks,
    required this.mataKuliah,
    required this.ruangKelas,
  });

  final List<_IpkTahunPoint> points;
  final double avgIpk;
  final double avgSks;
  final int mataKuliah;
  final int ruangKelas;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Academic Pulse',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Tren IPK dan kapasitas akademik prodi.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _KorproPulseChip(
                label: 'Avg IPK',
                value: avgIpk.toStringAsFixed(2),
                color: _academicColor(avgIpk),
              ),
              _KorproPulseChip(
                label: 'Avg SKS',
                value: avgSks.toStringAsFixed(1),
                color: Theme.of(context).colorScheme.primary,
              ),
              _KorproPulseChip(
                label: 'Mata Kuliah',
                value: '$mataKuliah',
                color: Colors.blue,
              ),
              _KorproPulseChip(
                label: 'Ruang',
                value: '$ruangKelas',
                color: Colors.deepPurple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: points.isEmpty
                ? const Center(child: Text('Belum ada data IPK'))
                : CustomPaint(
                    painter: _IpkTahunPainter(
                      points: points,
                      primary: Theme.of(context).colorScheme.primary,
                      onSurface: Theme.of(context).colorScheme.onSurface,
                    ),
                    child: const SizedBox.expand(),
                  ),
          ),
        ],
      ),
    ),
  );
}

class _KorproPulseChip extends StatelessWidget {
  const _KorproPulseChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 118,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.18)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _KorproOperationalPulse extends StatelessWidget {
  const _KorproOperationalPulse({
    required this.kelasMetrics,
    required this.rankedClasses,
    required this.completedMeetings,
    required this.totalMeetingSlots,
  });

  final List<_KorproKelasAttendanceMetric> kelasMetrics;
  final List<_KorproKelasAttendanceMetric> rankedClasses;
  final int completedMeetings;
  final int totalMeetingSlots;

  @override
  Widget build(BuildContext context) {
    final progress = totalMeetingSlots == 0
        ? 0.0
        : completedMeetings / totalMeetingSlots;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Operational Pulse',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Keterisian pertemuan dan kelas dengan presensi terendah.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            Center(
              child: _KorproAttendanceGauge(
                label: 'Pertemuan',
                rate: progress,
                total: completedMeetings,
              ),
            ),
            const Divider(height: 28),
            if (rankedClasses.isEmpty)
              const ListTile(title: Text('Belum ada data kelas aktif'))
            else
              for (final item in rankedClasses.take(4))
                _KorproDashboardClassTile(metric: item),
          ],
        ),
      ),
    );
  }
}

class _KorproDashboardClassTile extends StatelessWidget {
  const _KorproDashboardClassTile({required this.metric});

  final _KorproKelasAttendanceMetric metric;

  @override
  Widget build(BuildContext context) {
    final color = _attendanceRateColor(metric.mahasiswaRate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Tooltip(
        message: '${metric.hadirMahasiswa}/${metric.totalMahasiswa} data hadir',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    metric.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${(metric.mahasiswaRate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: metric.mahasiswaRate.clamp(0, 1),
              minHeight: 8,
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _KorproDashboardInsightPanel extends StatelessWidget {
  const _KorproDashboardInsightPanel({
    required this.students,
    required this.classes,
  });

  final List<_KorproMahasiswaMetric> students;
  final List<_KorproKelasAttendanceMetric> classes;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final studentPanel = _KorproInsightColumn(
            title: 'Mahasiswa Prioritas',
            emptyText: 'Tidak ada mahasiswa prioritas.',
            children: [
              for (final item in students)
                _KorproInsightTile(
                  icon: Icons.person_search_rounded,
                  title: item.mahasiswa.nama,
                  subtitle:
                      '${item.riskLabel} - IPK ${item.ipk.toStringAsFixed(2)} - Presensi ${(item.presensiRate * 100).toStringAsFixed(0)}%',
                  color: _studentRiskColor(item.riskLevel),
                ),
            ],
          );
          final classPanel = _KorproInsightColumn(
            title: 'Kelas yang Perlu Diikuti',
            emptyText: 'Belum ada kelas dengan data presensi.',
            children: [
              for (final item in classes)
                _KorproInsightTile(
                  icon: Icons.class_outlined,
                  title: item.nama,
                  subtitle:
                      '${(item.mahasiswaRate * 100).toStringAsFixed(0)}% kehadiran mahasiswa',
                  color: _attendanceRateColor(item.mahasiswaRate),
                ),
            ],
          );
          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [studentPanel, const SizedBox(height: 16), classPanel],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: studentPanel),
              const SizedBox(width: 18),
              Expanded(child: classPanel),
            ],
          );
        },
      ),
    ),
  );
}

class _KorproInsightColumn extends StatelessWidget {
  const _KorproInsightColumn({
    required this.title,
    required this.emptyText,
    required this.children,
  });

  final String title;
  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      if (children.isEmpty) Text(emptyText) else ...children,
    ],
  );
}

class _KorproInsightTile extends StatelessWidget {
  const _KorproInsightTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: color),
    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
  );
}

Color _dashboardScoreColor(double value) {
  if (value >= 0.82) return Colors.green;
  if (value >= 0.66) return Colors.amber.shade700;
  return Colors.red;
}

class KorproJadwalView extends StatefulWidget {
  const KorproJadwalView({required this.user, super.key});

  final User user;

  @override
  State<KorproJadwalView> createState() => _KorproJadwalViewState();
}

class _KorproJadwalViewState extends State<KorproJadwalView> {
  final searchController = TextEditingController();
  String? tahunAjaranId;
  String? hari;
  String query = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
    final prodi = service.prodi.firstWhere(
      (item) => item.id == widget.user.scopeId,
    );
    final selectedTahunId = tahunAjaranId ?? service.tahunAjaranAktif.id;
    final selectedTahun = service.tahunAjaran.firstWhere(
      (item) => item.id == selectedTahunId,
    );
    final mataKuliahIds = service.mataKuliah
        .where((item) => item.prodiId == widget.user.scopeId)
        .map((item) => item.kode)
        .toSet();
    final semuaJadwal =
        service.kelas
            .where(
              (item) =>
                  mataKuliahIds.contains(item.mataKuliahId) &&
                  item.tahunAjaranId == selectedTahunId,
            )
            .map((item) => _korproScheduleMetric(service, item))
            .toList()
          ..sort((a, b) {
            final hariCompare = _urutanHari(
              a.hari,
            ).compareTo(_urutanHari(b.hari));
            return hariCompare != 0 ? hariCompare : a.jam.compareTo(b.jam);
          });
    final jadwal = semuaJadwal.where((item) {
      final lower = query.toLowerCase();
      final matchesQuery =
          lower.isEmpty ||
          item.mataKuliah.toLowerCase().contains(lower) ||
          item.kelasId.toLowerCase().contains(lower) ||
          item.dosen.toLowerCase().contains(lower) ||
          item.ruangan.toLowerCase().contains(lower);
      final matchesHari = hari == null || item.hari == hari;
      return matchesQuery && matchesHari;
    }).toList();
    final hariCounts = {
      for (final item in _hariAkademik)
        item: semuaJadwal.where((kelas) => kelas.hari == item).length,
    };
    final roomCount = semuaJadwal
        .map((item) => item.ruanganKode)
        .toSet()
        .length;
    final lecturerCount = semuaJadwal
        .expand((item) => item.dosenIds)
        .toSet()
        .length;
    final fullClasses = semuaJadwal.where((item) => item.isFull).length;
    final conflicts = _korproScheduleConflicts(semuaJadwal);

    return AppScaffold(
      title: 'Jadwal Kuliah ${prodi.nama}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KorproScheduleHero(
            prodiName: prodi.nama,
            tahunLabel: selectedTahun.label,
            totalKelas: semuaJadwal.length,
            ruang: roomCount,
            dosen: lecturerCount,
            conflicts: conflicts.length,
          ),
          const SizedBox(height: 14),
          _KorproScheduleControlPanel(
            controller: searchController,
            query: query,
            tahunAjaranId: selectedTahunId,
            hari: hari,
            tahunAjaran: service.tahunAjaran,
            onQueryChanged: (value) => setState(() => query = value),
            onTahunChanged: (value) => setState(() => tahunAjaranId = value),
            onHariChanged: (value) => setState(() => hari = value),
            onReset: () => setState(() {
              query = '';
              hari = null;
              tahunAjaranId = null;
              searchController.clear();
            }),
          ),
          const SizedBox(height: 14),
          _KorproScheduleAnalytics(
            hariCounts: hariCounts,
            totalKelas: semuaJadwal.length,
            fullClasses: fullClasses,
            conflicts: conflicts,
          ),
          const SizedBox(height: 14),
          if (jadwal.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.event_busy_outlined),
                title: Text('Belum ada jadwal sesuai filter'),
              ),
            )
          else
            _KorproScheduleTimeline(metrics: jadwal),
        ],
      ),
    );
  }
}

const _hariAkademik = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

class _KorproScheduleMetric {
  const _KorproScheduleMetric({
    required this.kelasId,
    required this.mataKuliah,
    required this.sks,
    required this.hari,
    required this.jam,
    required this.ruangan,
    required this.ruanganKode,
    required this.dosen,
    required this.dosenIds,
    required this.peserta,
    required this.kapasitas,
    required this.completedMeetings,
  });

  final String kelasId;
  final String mataKuliah;
  final int sks;
  final String hari;
  final String jam;
  final String ruangan;
  final String ruanganKode;
  final String dosen;
  final Set<String> dosenIds;
  final int peserta;
  final int kapasitas;
  final int completedMeetings;

  double get occupancy => kapasitas == 0 ? 0 : peserta / kapasitas;
  double get meetingProgress => completedMeetings / 16;
  bool get isFull => peserta >= kapasitas;
}

_KorproScheduleMetric _korproScheduleMetric(MockService service, Kelas kelas) {
  final mataKuliah = service.mataKuliah.firstWhere(
    (item) => item.kode == kelas.mataKuliahId,
  );
  final pengajar = service.getDosenPengajarKelas(kelas.id);
  final completedMeetings = service.pertemuan
      .where(
        (item) =>
            item.kelasId == kelas.id && item.status == StatusPertemuan.selesai,
      )
      .length;
  return _KorproScheduleMetric(
    kelasId: kelas.id,
    mataKuliah: mataKuliah.nama,
    sks: mataKuliah.sks,
    hari: kelas.hari,
    jam: kelas.jam,
    ruangan: service.getRuanganName(kelas.ruangan),
    ruanganKode: kelas.ruangan,
    dosen: pengajar
        .map(
          (item) =>
              '${service.getDosenName(item.nidnDosen)} (${item.peranMengajar})',
        )
        .join(', '),
    dosenIds: pengajar.map((item) => item.nidnDosen).toSet(),
    peserta: service.getJumlahPesertaKelas(kelas.id),
    kapasitas: kelas.kapasitas,
    completedMeetings: completedMeetings,
  );
}

List<String> _korproScheduleConflicts(List<_KorproScheduleMetric> metrics) {
  final conflicts = <String>[];
  for (var i = 0; i < metrics.length; i++) {
    for (var j = i + 1; j < metrics.length; j++) {
      final a = metrics[i];
      final b = metrics[j];
      if (a.hari != b.hari || a.jam != b.jam) continue;
      if (a.ruanganKode == b.ruanganKode) {
        conflicts.add(
          '${a.hari} ${a.jam}: ${a.ruangan} dipakai ${a.kelasId} dan ${b.kelasId}',
        );
      }
      if (a.dosenIds.intersection(b.dosenIds).isNotEmpty) {
        conflicts.add(
          '${a.hari} ${a.jam}: dosen bentrok pada ${a.kelasId} dan ${b.kelasId}',
        );
      }
    }
  }
  return conflicts;
}

class _KorproScheduleHero extends StatelessWidget {
  const _KorproScheduleHero({
    required this.prodiName,
    required this.tahunLabel,
    required this.totalKelas,
    required this.ruang,
    required this.dosen,
    required this.conflicts,
  });

  final String prodiName;
  final String tahunLabel;
  final int totalKelas;
  final int ruang;
  final int dosen;
  final int conflicts;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Control Room',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text('$prodiName - $tahunLabel'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _KorproHeroChip(
                icon: Icons.class_rounded,
                label: '$totalKelas kelas',
              ),
              _KorproHeroChip(
                icon: Icons.meeting_room_rounded,
                label: '$ruang ruang',
              ),
              _KorproHeroChip(
                icon: Icons.co_present_rounded,
                label: '$dosen dosen',
              ),
              _KorproHeroChip(
                icon: conflicts == 0
                    ? Icons.verified_outlined
                    : Icons.warning_amber_rounded,
                label: '$conflicts potensi bentrok',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _KorproScheduleControlPanel extends StatelessWidget {
  const _KorproScheduleControlPanel({
    required this.controller,
    required this.query,
    required this.tahunAjaranId,
    required this.hari,
    required this.tahunAjaran,
    required this.onQueryChanged,
    required this.onTahunChanged,
    required this.onHariChanged,
    required this.onReset,
  });

  final TextEditingController controller;
  final String query;
  final String tahunAjaranId;
  final String? hari;
  final List<TahunAjaran> tahunAjaran;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String?> onTahunChanged;
  final ValueChanged<String?> onHariChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width >= 900
                ? 320
                : double.infinity,
            child: TextField(
              controller: controller,
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                labelText: 'Cari mata kuliah, kelas, dosen, ruang',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          controller.clear();
                          onQueryChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          _Filter<String>(
            label: 'Tahun Ajaran',
            value: tahunAjaranId,
            items: tahunAjaran
                .map(
                  (item) =>
                      DropdownMenuItem(value: item.id, child: Text(item.label)),
                )
                .toList(),
            onChanged: onTahunChanged,
          ),
          _Filter<String>(
            label: 'Hari',
            value: hari,
            items: _hariAkademik
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onHariChanged,
          ),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset'),
          ),
        ],
      ),
    ),
  );
}

class _KorproScheduleAnalytics extends StatelessWidget {
  const _KorproScheduleAnalytics({
    required this.hariCounts,
    required this.totalKelas,
    required this.fullClasses,
    required this.conflicts,
  });

  final Map<String, int> hariCounts;
  final int totalKelas;
  final int fullClasses;
  final List<String> conflicts;

  @override
  Widget build(BuildContext context) {
    final maxValue = hariCounts.values.fold<int>(1, (a, b) => b > a ? b : a);
    return LayoutBuilder(
      builder: (context, constraints) {
        final panels = [
          _KorproScheduleLoadCard(hariCounts: hariCounts, maxValue: maxValue),
          _KorproScheduleRiskCard(
            totalKelas: totalKelas,
            fullClasses: fullClasses,
            conflicts: conflicts,
          ),
        ];
        if (constraints.maxWidth < 850) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [panels[0], const SizedBox(height: 14), panels[1]],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: panels[0]),
            const SizedBox(width: 14),
            Expanded(child: panels[1]),
          ],
        );
      },
    );
  }
}

class _KorproScheduleLoadCard extends StatelessWidget {
  const _KorproScheduleLoadCard({
    required this.hariCounts,
    required this.maxValue,
  });

  final Map<String, int> hariCounts;
  final int maxValue;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Distribusi Beban Hari',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final entry in hariCounts.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Tooltip(
                message: '${entry.key}: ${entry.value} kelas',
                child: Row(
                  children: [
                    SizedBox(width: 58, child: Text(entry.key)),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: entry.value / maxValue),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) =>
                            LinearProgressIndicator(
                              value: value,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${entry.value}'),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _KorproScheduleRiskCard extends StatelessWidget {
  const _KorproScheduleRiskCard({
    required this.totalKelas,
    required this.fullClasses,
    required this.conflicts,
  });

  final int totalKelas;
  final int fullClasses;
  final List<String> conflicts;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Radar Jadwal',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _WarningTile(
            icon: Icons.groups_outlined,
            label: 'Kelas penuh',
            value: fullClasses,
          ),
          _WarningTile(
            icon: conflicts.isEmpty
                ? Icons.verified_outlined
                : Icons.warning_amber_rounded,
            label: 'Potensi bentrok',
            value: conflicts.length,
          ),
          _WarningTile(
            icon: Icons.class_outlined,
            label: 'Total kelas terjadwal',
            value: totalKelas,
          ),
          if (conflicts.isNotEmpty) ...[
            const Divider(height: 18),
            for (final item in conflicts.take(3))
              Text(item, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    ),
  );
}

class _KorproScheduleTimeline extends StatelessWidget {
  const _KorproScheduleTimeline({required this.metrics});

  final List<_KorproScheduleMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final grouped = {
      for (final day in _hariAkademik)
        day: metrics.where((item) => item.hari == day).toList(),
    }..removeWhere((key, value) => value.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in grouped.entries)
          _KorproScheduleDaySection(day: entry.key, metrics: entry.value),
      ],
    );
  }
}

class _KorproScheduleDaySection extends StatelessWidget {
  const _KorproScheduleDaySection({required this.day, required this.metrics});

  final String day;
  final List<_KorproScheduleMetric> metrics;

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
              Icon(
                Icons.calendar_today_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(label: Text('${metrics.length} kelas')),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < metrics.length; index++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 260 + index * 60),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Transform.translate(
                offset: Offset(18 * (1 - value), 0),
                child: Opacity(opacity: value, child: child),
              ),
              child: _KorproScheduleClassCard(metric: metrics[index]),
            ),
        ],
      ),
    ),
  );
}

class _KorproScheduleClassCard extends StatefulWidget {
  const _KorproScheduleClassCard({required this.metric});

  final _KorproScheduleMetric metric;

  @override
  State<_KorproScheduleClassCard> createState() =>
      _KorproScheduleClassCardState();
}

class _KorproScheduleClassCardState extends State<_KorproScheduleClassCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final metric = widget.metric;
    final occupancyColor = metric.isFull
        ? Colors.red
        : _attendanceRateColor(metric.occupancy);
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hovered
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 18),
                      const SizedBox(height: 2),
                      Text(
                        metric.jam,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.mataKuliah,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${metric.kelasId} - ${metric.sks} SKS - ${metric.dosen}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message:
                      '${metric.peserta}/${metric.kapasitas} peserta di ${metric.ruangan}',
                  child: Chip(
                    avatar: Icon(
                      Icons.meeting_room_outlined,
                      color: occupancyColor,
                    ),
                    label: Text(metric.ruanganKode),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _KorproMetricProgress(
              label: 'Keterisian kelas',
              value: metric.occupancy.clamp(0, 1),
              color: occupancyColor,
              tooltip: '${metric.peserta}/${metric.kapasitas} peserta',
            ),
            const SizedBox(height: 10),
            _KorproMetricProgress(
              label: 'Progress pertemuan',
              value: metric.meetingProgress.clamp(0, 1),
              color: Theme.of(context).colorScheme.primary,
              tooltip: '${metric.completedMeetings}/16 pertemuan selesai',
            ),
          ],
        ),
      ),
    );
  }
}

enum _KorproDosenSort { nama, sks, kelas, presensi, bimbingan }

extension _KorproDosenSortLabel on _KorproDosenSort {
  String get label {
    switch (this) {
      case _KorproDosenSort.nama:
        return 'Nama';
      case _KorproDosenSort.sks:
        return 'SKS';
      case _KorproDosenSort.kelas:
        return 'Kelas';
      case _KorproDosenSort.presensi:
        return 'Presensi';
      case _KorproDosenSort.bimbingan:
        return 'Bimbingan';
    }
  }
}

class KorproDosenView extends StatefulWidget {
  const KorproDosenView({required this.user, super.key});

  final User user;

  @override
  State<KorproDosenView> createState() => _KorproDosenViewState();
}

class _KorproDosenViewState extends State<KorproDosenView> {
  final searchController = TextEditingController();
  String query = '';
  _KorproDosenSort sort = _KorproDosenSort.nama;
  bool onlyWithLoad = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
    final prodi = service.prodi.firstWhere(
      (item) => item.id == widget.user.scopeId,
    );
    final allMetrics = service.dosen
        .where((item) => item.prodiId == widget.user.scopeId)
        .map((item) => _korproDosenMetric(service, item, widget.user.scopeId))
        .toList();
    final filtered = allMetrics.where((item) {
      final lower = query.toLowerCase();
      final matchesQuery =
          lower.isEmpty ||
          item.dosen.nama.toLowerCase().contains(lower) ||
          item.dosen.nidn.toLowerCase().contains(lower) ||
          item.dosen.email.toLowerCase().contains(lower) ||
          item.dosen.keahlian.toLowerCase().contains(lower);
      final matchesLoad = !onlyWithLoad || item.kelas.isNotEmpty;
      return matchesQuery && matchesLoad;
    }).toList();
    _sortKorproDosen(filtered, sort);

    return AppScaffold(
      title: 'Dosen ${prodi.nama}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KorproDosenHero(
            prodiName: prodi.nama,
            metrics: allMetrics,
            shownCount: filtered.length,
          ),
          const SizedBox(height: 14),
          _KorproDosenControlPanel(
            controller: searchController,
            query: query,
            sort: sort,
            onlyWithLoad: onlyWithLoad,
            onQueryChanged: (value) => setState(() => query = value),
            onSortChanged: (value) => setState(() => sort = value),
            onOnlyWithLoadChanged: (value) =>
                setState(() => onlyWithLoad = value),
            onReset: () => setState(() {
              query = '';
              sort = _KorproDosenSort.nama;
              onlyWithLoad = false;
              searchController.clear();
            }),
          ),
          const SizedBox(height: 14),
          _KorproDosenLoadDistribution(metrics: allMetrics),
          const SizedBox(height: 14),
          _KorproDosenGrid(
            metrics: filtered,
            onSelected: (metric) =>
                _showKorproDosenDetail(context, service, metric),
          ),
        ],
      ),
    );
  }
}

class _KorproDosenHero extends StatelessWidget {
  const _KorproDosenHero({
    required this.prodiName,
    required this.metrics,
    required this.shownCount,
  });

  final String prodiName;
  final List<_KorproDosenMetric> metrics;
  final int shownCount;

  @override
  Widget build(BuildContext context) {
    final totalSks = metrics.fold<int>(0, (sum, item) => sum + item.totalSks);
    final avgSks = metrics.isEmpty ? 0.0 : totalSks / metrics.length;
    final activeLecturers = metrics
        .where((item) => item.kelas.isNotEmpty)
        .length;
    final avgPresensi = metrics.isEmpty
        ? 0.0
        : metrics.fold<double>(0, (sum, item) => sum + item.presensiRate) /
              metrics.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lecturer Command Center',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              '$prodiName - $shownCount dari ${metrics.length} dosen tampil',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 850
                    ? 4
                    : constraints.maxWidth >= 520
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - ((columns - 1) * 12)) / columns;
                final items = [
                  (
                    'Total Dosen',
                    '${metrics.length}',
                    Icons.co_present_rounded,
                    Theme.of(context).colorScheme.primary,
                  ),
                  (
                    'Aktif Mengajar',
                    '$activeLecturers',
                    Icons.school_rounded,
                    Colors.green,
                  ),
                  (
                    'Rata-rata SKS',
                    avgSks.toStringAsFixed(1),
                    Icons.menu_book_rounded,
                    Colors.deepPurple,
                  ),
                  (
                    'Presensi Dosen',
                    '${(avgPresensi * 100).toStringAsFixed(0)}%',
                    Icons.how_to_reg_rounded,
                    _attendanceRateColor(avgPresensi),
                  ),
                ];
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var index = 0; index < items.length; index++)
                      SizedBox(
                        width: width,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 320 + index * 80),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) =>
                              Transform.translate(
                                offset: Offset(0, 14 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              ),
                          child: _KorproMahasiswaKpiCard(
                            label: items[index].$1,
                            value: items[index].$2,
                            icon: items[index].$3,
                            color: items[index].$4,
                          ),
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

class _KorproDosenControlPanel extends StatelessWidget {
  const _KorproDosenControlPanel({
    required this.controller,
    required this.query,
    required this.sort,
    required this.onlyWithLoad,
    required this.onQueryChanged,
    required this.onSortChanged,
    required this.onOnlyWithLoadChanged,
    required this.onReset,
  });

  final TextEditingController controller;
  final String query;
  final _KorproDosenSort sort;
  final bool onlyWithLoad;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_KorproDosenSort> onSortChanged;
  final ValueChanged<bool> onOnlyWithLoadChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width >= 900
                ? 340
                : double.infinity,
            child: TextField(
              controller: controller,
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                labelText: 'Cari nama, NIDN, email, atau keahlian',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          controller.clear();
                          onQueryChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          _Filter<_KorproDosenSort>(
            label: 'Urutkan',
            value: sort,
            items: _KorproDosenSort.values
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onSortChanged(value);
            },
          ),
          FilterChip(
            selected: onlyWithLoad,
            label: const Text('Sedang mengajar'),
            avatar: const Icon(Icons.school_outlined),
            onSelected: onOnlyWithLoadChanged,
          ),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset'),
          ),
        ],
      ),
    ),
  );
}

class _KorproDosenLoadDistribution extends StatelessWidget {
  const _KorproDosenLoadDistribution({required this.metrics});

  final List<_KorproDosenMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final maxSks = metrics.fold<int>(
      1,
      (current, item) => item.totalSks > current ? item.totalSks : current,
    );
    final ranked = metrics.toList()
      ..sort((a, b) => b.totalSks.compareTo(a.totalSks));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Distribusi Beban Mengajar',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (ranked.isEmpty)
              const Text('Belum ada data dosen')
            else
              for (final item in ranked.take(6))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Tooltip(
                    message:
                        '${item.dosen.nama}: ${item.totalSks} SKS, ${item.kelas.length} kelas',
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            item.dosen.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: item.totalSks / maxSks),
                            duration: const Duration(milliseconds: 650),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) =>
                                LinearProgressIndicator(
                                  value: value,
                                  minHeight: 9,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${item.totalSks} SKS'),
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

class _KorproDosenGrid extends StatelessWidget {
  const _KorproDosenGrid({required this.metrics, required this.onSelected});

  final List<_KorproDosenMetric> metrics;
  final ValueChanged<_KorproDosenMetric> onSelected;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.search_off_rounded),
          title: Text('Tidak ada dosen sesuai filter'),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1120
            ? 3
            : constraints.maxWidth >= 720
            ? 2
            : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 14)) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (var index = 0; index < metrics.length; index++)
              SizedBox(
                width: width,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(metrics[index].dosen.nidn),
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 260 + (index % 8) * 45),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(0, 16 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  ),
                  child: _KorproDosenCard(
                    metric: metrics[index],
                    onTap: () => onSelected(metrics[index]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KorproDosenCard extends StatefulWidget {
  const _KorproDosenCard({required this.metric, required this.onTap});

  final _KorproDosenMetric metric;
  final VoidCallback onTap;

  @override
  State<_KorproDosenCard> createState() => _KorproDosenCardState();
}

class _KorproDosenCardState extends State<_KorproDosenCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final metric = widget.metric;
    final dosen = metric.dosen;
    final loadColor = _lecturerLoadColor(metric.totalSks);
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: hovered ? 1.015 : 1,
        duration: const Duration(milliseconds: 150),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: loadColor.withValues(alpha: 0.18),
                        child: Text(
                          dosen.nama.substring(0, 1),
                          style: TextStyle(
                            color: loadColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dosen.nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              dosen.nidn,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Chip(label: Text('${metric.totalSks} SKS')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (dosen.keahlian.isNotEmpty)
                    Text(
                      dosen.keahlian,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _KorproMiniMetric(
                        label: 'Kelas',
                        value: '${metric.kelas.length}',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _KorproMiniMetric(
                        label: 'Tugas',
                        value: '${metric.tugas.length}',
                        color: Colors.deepPurple,
                      ),
                      _KorproMiniMetric(
                        label: 'PA',
                        value: '${metric.mahasiswaPa}',
                        color: Colors.teal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _KorproMetricProgress(
                    label: 'Presensi dosen',
                    value: metric.presensiRate,
                    color: _attendanceRateColor(metric.presensiRate),
                    tooltip:
                        '${metric.presensiHadir}/${metric.presensiTotal} hadir',
                  ),
                  const SizedBox(height: 10),
                  _KorproMetricProgress(
                    label: 'Beban SKS',
                    value: (metric.totalSks / 24).clamp(0, 1),
                    color: loadColor,
                    tooltip: '${metric.totalSks} SKS semester berjalan',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.insights_rounded, color: loadColor, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          metric.loadLabel,
                          style: TextStyle(
                            color: loadColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KorproDosenMetric {
  const _KorproDosenMetric({
    required this.dosen,
    required this.kelas,
    required this.tugas,
    required this.skripsi,
    required this.mahasiswaPa,
    required this.totalSks,
    required this.presensiHadir,
    required this.presensiTotal,
  });

  final Dosen dosen;
  final List<Kelas> kelas;
  final List<Tugas> tugas;
  final List<Skripsi> skripsi;
  final int mahasiswaPa;
  final int totalSks;
  final int presensiHadir;
  final int presensiTotal;

  double get presensiRate =>
      presensiTotal == 0 ? 0 : presensiHadir / presensiTotal;

  String get loadLabel {
    if (totalSks == 0) return 'Belum mengajar';
    if (totalSks <= 12) return 'Beban ringan';
    if (totalSks <= 20) return 'Beban ideal';
    return 'Beban tinggi';
  }
}

_KorproDosenMetric _korproDosenMetric(
  MockService service,
  Dosen dosen,
  String prodiId,
) {
  final mataKuliahIds = service.mataKuliah
      .where((item) => item.prodiId == prodiId)
      .map((item) => item.kode)
      .toSet();
  final kelas = service.kelas
      .where(
        (item) =>
            mataKuliahIds.contains(item.mataKuliahId) &&
            service.isDosenMengajarKelas(dosen.nidn, item.id),
      )
      .toList();
  final kelasIds = kelas.map((item) => item.id).toSet();
  final tugas = service.tugas
      .where((item) => kelasIds.contains(item.kelasId))
      .toList();
  final skripsi = service.skripsi
      .where((item) => item.pembimbingId == dosen.nidn)
      .toList();
  final mahasiswaPa = service.mahasiswa
      .where((item) => item.pembimbingAkademikId == dosen.nidn)
      .length;
  var totalSks = 0;
  for (final item in kelas) {
    final mk = service.mataKuliah.firstWhere(
      (mk) => mk.kode == item.mataKuliahId,
    );
    totalSks += mk.sks;
  }
  final pertemuanIds = service.pertemuan
      .where((item) => kelasIds.contains(item.kelasId))
      .map((item) => item.id)
      .toSet();
  final presensi = service.presensiDosen
      .where(
        (item) =>
            item.dosenId == dosen.nidn &&
            pertemuanIds.contains(item.pertemuanId),
      )
      .toList();
  return _KorproDosenMetric(
    dosen: dosen,
    kelas: kelas,
    tugas: tugas,
    skripsi: skripsi,
    mahasiswaPa: mahasiswaPa,
    totalSks: totalSks,
    presensiHadir: _countDosenStatus(presensi, 'Hadir'),
    presensiTotal: presensi.length,
  );
}

void _sortKorproDosen(List<_KorproDosenMetric> metrics, _KorproDosenSort sort) {
  metrics.sort((a, b) {
    switch (sort) {
      case _KorproDosenSort.nama:
        return a.dosen.nama.compareTo(b.dosen.nama);
      case _KorproDosenSort.sks:
        return b.totalSks.compareTo(a.totalSks);
      case _KorproDosenSort.kelas:
        return b.kelas.length.compareTo(a.kelas.length);
      case _KorproDosenSort.presensi:
        return b.presensiRate.compareTo(a.presensiRate);
      case _KorproDosenSort.bimbingan:
        return b.skripsi.length.compareTo(a.skripsi.length);
    }
  });
}

void _showKorproDosenDetail(
  BuildContext context,
  MockService service,
  _KorproDosenMetric metric,
) {
  final dosen = metric.dosen;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.74,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text(dosen.nama.substring(0, 1))),
            title: Text(
              dosen.nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${dosen.nidn} - ${metric.loadLabel}'),
            trailing: Chip(label: Text('${metric.totalSks} SKS')),
          ),
          const SizedBox(height: 8),
          _KorproDetailRow(
            label: 'Keahlian',
            value: dosen.keahlian.isEmpty ? '-' : dosen.keahlian,
          ),
          _KorproDetailRow(
            label: 'Email',
            value: dosen.email.isEmpty ? '-' : dosen.email,
          ),
          _KorproDetailRow(
            label: 'No HP',
            value: dosen.noHp.isEmpty ? '-' : dosen.noHp,
          ),
          _KorproDetailRow(
            label: 'Alamat',
            value: dosen.alamat.isEmpty ? '-' : dosen.alamat,
          ),
          const Divider(height: 28),
          _KorproMetricProgress(
            label: 'Presensi dosen',
            value: metric.presensiRate,
            color: _attendanceRateColor(metric.presensiRate),
            tooltip: '${metric.presensiHadir}/${metric.presensiTotal} hadir',
          ),
          const SizedBox(height: 14),
          _KorproDetailRow(
            label: 'Kelas diajar',
            value: '${metric.kelas.length}',
          ),
          _KorproDetailRow(
            label: 'Tugas aktif',
            value: '${metric.tugas.length}',
          ),
          _KorproDetailRow(
            label: 'Mahasiswa PA',
            value: '${metric.mahasiswaPa}',
          ),
          _KorproDetailRow(
            label: 'Bimbingan skripsi',
            value: '${metric.skripsi.length}',
          ),
          const Divider(height: 28),
          Text(
            'Kelas yang Diajar',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (metric.kelas.isEmpty)
            const Text('Belum ada kelas yang diajar.')
          else
            for (final kelas in metric.kelas)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.class_outlined),
                title: Text(service.getMataKuliahName(kelas.mataKuliahId)),
                subtitle: Text(
                  '${kelas.hari}, ${kelas.jam} - ${service.getRuanganName(kelas.ruangan)}',
                ),
                trailing: Text(
                  '${service.getJumlahPesertaKelas(kelas.id)}/${kelas.kapasitas}',
                ),
              ),
          const Divider(height: 28),
          Text(
            'Bimbingan Skripsi',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (metric.skripsi.isEmpty)
            const Text('Belum ada bimbingan skripsi aktif.')
          else
            for (final item in metric.skripsi)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.school_outlined),
                title: Text(item.judul),
                subtitle: Text(
                  '${service.getMahasiswaName(item.mahasiswaId)} - ${item.status.label}',
                ),
              ),
        ],
      ),
    ),
  );
}

Color _lecturerLoadColor(int sks) {
  if (sks == 0) return Colors.grey;
  if (sks <= 12) return Colors.blue;
  if (sks <= 20) return Colors.green;
  return Colors.orange;
}

enum _KorproMahasiswaSort { nama, semester, ipk, presensi, sks }

extension _KorproMahasiswaSortLabel on _KorproMahasiswaSort {
  String get label {
    switch (this) {
      case _KorproMahasiswaSort.nama:
        return 'Nama';
      case _KorproMahasiswaSort.semester:
        return 'Semester';
      case _KorproMahasiswaSort.ipk:
        return 'IPK';
      case _KorproMahasiswaSort.presensi:
        return 'Presensi';
      case _KorproMahasiswaSort.sks:
        return 'SKS KRS';
    }
  }
}

class KorproMahasiswaView extends StatefulWidget {
  const KorproMahasiswaView({required this.user, super.key});

  final User user;

  @override
  State<KorproMahasiswaView> createState() => _KorproMahasiswaViewState();
}

class _KorproMahasiswaViewState extends State<KorproMahasiswaView> {
  static const _pageSize = 10;

  final searchController = TextEditingController();
  String query = '';
  StatusMahasiswa? status;
  int? semester;
  _KorproMahasiswaSort sort = _KorproMahasiswaSort.nama;
  int page = 0;
  MockService? _cachedService;
  String? _cachedProdiId;
  int? _cachedRevision;
  List<_KorproMahasiswaMetric> _cachedMetrics = const [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<_KorproMahasiswaMetric> _metricsFor(MockService service) {
    if (_cachedService == service &&
        _cachedProdiId == widget.user.scopeId &&
        _cachedRevision == service.dataRevision) {
      return _cachedMetrics;
    }
    _cachedService = service;
    _cachedProdiId = widget.user.scopeId;
    _cachedRevision = service.dataRevision;
    _cachedMetrics = service.mahasiswa
        .where((item) => item.prodiId == widget.user.scopeId)
        .map((item) => _korproMahasiswaMetric(service, item))
        .toList(growable: false);
    return _cachedMetrics;
  }

  void _resetPage() {
    page = 0;
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
    final prodi = service.prodi.firstWhere(
      (item) => item.id == widget.user.scopeId,
    );
    final allMetrics = _metricsFor(service);
    final semesters = allMetrics.map((item) => item.mahasiswa.semester).toSet()
      ..removeWhere((item) => item <= 0);
    final filtered = allMetrics.where((item) {
      final lower = query.toLowerCase();
      final matchesQuery =
          lower.isEmpty ||
          item.mahasiswa.nama.toLowerCase().contains(lower) ||
          item.mahasiswa.nim.toLowerCase().contains(lower) ||
          item.mahasiswa.email.toLowerCase().contains(lower);
      final matchesStatus = status == null || item.mahasiswa.status == status;
      final matchesSemester =
          semester == null || item.mahasiswa.semester == semester;
      return matchesQuery && matchesStatus && matchesSemester;
    }).toList();
    _sortKorproMahasiswa(filtered, sort);
    final totalPages = filtered.isEmpty
        ? 1
        : ((filtered.length - 1) ~/ _pageSize) + 1;
    final currentPage = page.clamp(0, totalPages - 1);
    if (currentPage != page) {
      page = currentPage;
    }
    final visibleMetrics = filtered
        .skip(currentPage * _pageSize)
        .take(_pageSize)
        .toList(growable: false);

    return AppScaffold(
      title: 'Mahasiswa ${prodi.nama}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KorproMahasiswaHero(
            prodiName: prodi.nama,
            metrics: allMetrics,
            shownCount: filtered.length,
          ),
          const SizedBox(height: 14),
          _KorproMahasiswaControlPanel(
            controller: searchController,
            query: query,
            status: status,
            semester: semester,
            sort: sort,
            semesters: semesters.toList()..sort(),
            onQueryChanged: (value) => setState(() {
              query = value;
              _resetPage();
            }),
            onStatusChanged: (value) => setState(() {
              status = value;
              _resetPage();
            }),
            onSemesterChanged: (value) => setState(() {
              semester = value;
              _resetPage();
            }),
            onSortChanged: (value) => setState(() {
              sort = value;
              _resetPage();
            }),
            onReset: () => setState(() {
              query = '';
              status = null;
              semester = null;
              sort = _KorproMahasiswaSort.nama;
              _resetPage();
              searchController.clear();
            }),
          ),
          const SizedBox(height: 14),
          _KorproMahasiswaStatusStrip(metrics: allMetrics),
          const SizedBox(height: 14),
          _KorproPaginationBar(
            page: currentPage,
            pageSize: _pageSize,
            totalItems: filtered.length,
            onPrevious: currentPage == 0
                ? null
                : () => setState(() => page = currentPage - 1),
            onNext: currentPage >= totalPages - 1
                ? null
                : () => setState(() => page = currentPage + 1),
          ),
          const SizedBox(height: 14),
          _KorproMahasiswaGrid(
            metrics: visibleMetrics,
            onSelected: (metric) =>
                _showKorproMahasiswaDetail(context, service, metric),
          ),
        ],
      ),
    );
  }
}

class _KorproMahasiswaHero extends StatelessWidget {
  const _KorproMahasiswaHero({
    required this.prodiName,
    required this.metrics,
    required this.shownCount,
  });

  final String prodiName;
  final List<_KorproMahasiswaMetric> metrics;
  final int shownCount;

  @override
  Widget build(BuildContext context) {
    final active = metrics
        .where((item) => item.mahasiswa.status == StatusMahasiswa.aktif)
        .length;
    final avgIpk = metrics.isEmpty
        ? 0.0
        : metrics.fold<double>(0, (total, item) => total + item.ipk) /
              metrics.length;
    final riskCount = metrics.where((item) => item.riskLevel > 0).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Command Center',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              '$prodiName - $shownCount dari ${metrics.length} mahasiswa tampil',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 850
                    ? 4
                    : constraints.maxWidth >= 520
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - ((columns - 1) * 12)) / columns;
                final items = [
                  (
                    'Total Mahasiswa',
                    '${metrics.length}',
                    Icons.groups_rounded,
                    Theme.of(context).colorScheme.primary,
                  ),
                  (
                    'Aktif',
                    '$active',
                    Icons.verified_user_outlined,
                    Colors.green,
                  ),
                  (
                    'Rata-rata IPK',
                    avgIpk.toStringAsFixed(2),
                    Icons.trending_up_rounded,
                    _academicColor(avgIpk),
                  ),
                  (
                    'Perlu Atensi',
                    '$riskCount',
                    Icons.priority_high_rounded,
                    riskCount == 0 ? Colors.green : Colors.orange,
                  ),
                ];
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var index = 0; index < items.length; index++)
                      SizedBox(
                        width: width,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 320 + index * 80),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) =>
                              Transform.translate(
                                offset: Offset(0, 14 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              ),
                          child: _KorproMahasiswaKpiCard(
                            label: items[index].$1,
                            value: items[index].$2,
                            icon: items[index].$3,
                            color: items[index].$4,
                          ),
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

class _KorproMahasiswaKpiCard extends StatelessWidget {
  const _KorproMahasiswaKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.18)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class _KorproMahasiswaControlPanel extends StatelessWidget {
  const _KorproMahasiswaControlPanel({
    required this.controller,
    required this.query,
    required this.status,
    required this.semester,
    required this.sort,
    required this.semesters,
    required this.onQueryChanged,
    required this.onStatusChanged,
    required this.onSemesterChanged,
    required this.onSortChanged,
    required this.onReset,
  });

  final TextEditingController controller;
  final String query;
  final StatusMahasiswa? status;
  final int? semester;
  final _KorproMahasiswaSort sort;
  final List<int> semesters;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<StatusMahasiswa?> onStatusChanged;
  final ValueChanged<int?> onSemesterChanged;
  final ValueChanged<_KorproMahasiswaSort> onSortChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final search = SizedBox(
            width: constraints.maxWidth >= 900 ? 320 : double.infinity,
            child: TextField(
              controller: controller,
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                labelText: 'Cari nama, NIM, atau email',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          controller.clear();
                          onQueryChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          );
          final controls = [
            _Filter<StatusMahasiswa>(
              label: 'Status',
              value: status,
              items: StatusMahasiswa.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(),
              onChanged: onStatusChanged,
            ),
            _Filter<int>(
              label: 'Semester',
              value: semester,
              items: semesters
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text('Semester $item'),
                    ),
                  )
                  .toList(),
              onChanged: onSemesterChanged,
            ),
            _Filter<_KorproMahasiswaSort>(
              label: 'Urutkan',
              value: sort,
              items: _KorproMahasiswaSort.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onSortChanged(value);
              },
            ),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset'),
            ),
          ];

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [search, ...controls],
          );
        },
      ),
    ),
  );
}

class _KorproMahasiswaStatusStrip extends StatelessWidget {
  const _KorproMahasiswaStatusStrip({required this.metrics});

  final List<_KorproMahasiswaMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final counts = {
      for (final item in StatusMahasiswa.values)
        item: metrics.where((metric) => metric.mahasiswa.status == item).length,
    };
    final maxValue = counts.values.fold<int>(
      1,
      (current, value) => value > current ? value : current,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Komposisi Status Mahasiswa',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final entry in counts.entries)
                  SizedBox(
                    width: 190,
                    child: Tooltip(
                      message: '${entry.key.label}: ${entry.value} mahasiswa',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(entry.key.label)),
                              Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: entry.value / maxValue),
                            duration: const Duration(milliseconds: 620),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) =>
                                LinearProgressIndicator(
                                  value: value,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                  color: _studentStatusColor(entry.key),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KorproPaginationBar extends StatelessWidget {
  const _KorproPaginationBar({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final start = totalItems == 0 ? 0 : page * pageSize + 1;
    final end = (page * pageSize + pageSize).clamp(0, totalItems);
    final totalPages = totalItems == 0 ? 1 : ((totalItems - 1) ~/ pageSize) + 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Menampilkan $start-$end dari $totalItems mahasiswa',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              'Halaman ${page + 1}/$totalPages',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              tooltip: 'Sebelumnya',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            const SizedBox(width: 6),
            IconButton.filledTonal(
              tooltip: 'Berikutnya',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _KorproMahasiswaGrid extends StatelessWidget {
  const _KorproMahasiswaGrid({required this.metrics, required this.onSelected});

  final List<_KorproMahasiswaMetric> metrics;
  final ValueChanged<_KorproMahasiswaMetric> onSelected;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.search_off_rounded),
          title: Text('Tidak ada mahasiswa sesuai filter'),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1120
            ? 3
            : constraints.maxWidth >= 720
            ? 2
            : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 14)) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (var index = 0; index < metrics.length; index++)
              SizedBox(
                width: width,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(metrics[index].mahasiswa.nim),
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 260 + (index % 8) * 45),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(0, 16 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  ),
                  child: _KorproMahasiswaCard(
                    metric: metrics[index],
                    onTap: () => onSelected(metrics[index]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KorproMahasiswaCard extends StatefulWidget {
  const _KorproMahasiswaCard({required this.metric, required this.onTap});

  final _KorproMahasiswaMetric metric;
  final VoidCallback onTap;

  @override
  State<_KorproMahasiswaCard> createState() => _KorproMahasiswaCardState();
}

class _KorproMahasiswaCardState extends State<_KorproMahasiswaCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final metric = widget.metric;
    final mahasiswa = metric.mahasiswa;
    final riskColor = _studentRiskColor(metric.riskLevel);
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: hovered ? 1.015 : 1,
        duration: const Duration(milliseconds: 150),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _studentStatusColor(
                          mahasiswa.status,
                        ).withValues(alpha: 0.18),
                        child: Text(
                          mahasiswa.nama.substring(0, 1),
                          style: TextStyle(
                            color: _studentStatusColor(mahasiswa.status),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mahasiswa.nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${mahasiswa.nim} - Semester ${mahasiswa.semester}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(mahasiswa.status.label),
                        backgroundColor: _studentStatusColor(
                          mahasiswa.status,
                        ).withValues(alpha: 0.13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _KorproMiniMetric(
                        label: 'IPK',
                        value: metric.ipk.toStringAsFixed(2),
                        color: _academicColor(metric.ipk),
                      ),
                      _KorproMiniMetric(
                        label: 'SKS',
                        value: '${metric.sksDisetujui}',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _KorproMiniMetric(
                        label: 'KRS',
                        value: metric.krsStatus,
                        color: metric.krsApproved > 0
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _KorproMetricProgress(
                    label: 'Presensi',
                    value: metric.presensiRate,
                    color: _attendanceRateColor(metric.presensiRate),
                    tooltip:
                        '${metric.presensiHadir}/${metric.presensiTotal} hadir',
                  ),
                  const SizedBox(height: 10),
                  _KorproMetricProgress(
                    label: 'Progress akademik',
                    value: (metric.sksDisetujui / 24).clamp(0, 1),
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: '${metric.sksDisetujui} SKS disetujui',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        metric.riskLevel == 0
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_rounded,
                        color: riskColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          metric.riskLabel,
                          style: TextStyle(
                            color: riskColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KorproMiniMetric extends StatelessWidget {
  const _KorproMiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ),
  );
}

class _KorproMetricProgress extends StatelessWidget {
  const _KorproMetricProgress({
    required this.label,
    required this.value,
    required this.color,
    required this.tooltip,
  });

  final String label;
  final double value;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 720),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) => LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _KorproMahasiswaMetric {
  const _KorproMahasiswaMetric({
    required this.mahasiswa,
    required this.ipk,
    required this.sksDisetujui,
    required this.krsApproved,
    required this.krsTotal,
    required this.presensiHadir,
    required this.presensiTotal,
  });

  final Mahasiswa mahasiswa;
  final double ipk;
  final int sksDisetujui;
  final int krsApproved;
  final int krsTotal;
  final int presensiHadir;
  final int presensiTotal;

  double get presensiRate =>
      presensiTotal == 0 ? 0 : presensiHadir / presensiTotal;

  String get krsStatus {
    if (krsApproved > 0) return '$krsApproved/$krsTotal';
    if (krsTotal > 0) return 'Proses';
    return 'Kosong';
  }

  int get riskLevel {
    if (mahasiswa.status != StatusMahasiswa.aktif) return 2;
    if (presensiTotal > 0 && presensiRate < 0.70) return 2;
    if (ipk > 0 && ipk < 2.75) return 2;
    if (krsApproved == 0) return 1;
    if (presensiTotal > 0 && presensiRate < 0.80) return 1;
    return 0;
  }

  String get riskLabel {
    if (riskLevel == 0) return 'Stabil';
    if (riskLevel == 1) return 'Pantau';
    return 'Prioritas';
  }
}

_KorproMahasiswaMetric _korproMahasiswaMetric(
  MockService service,
  Mahasiswa mahasiswa,
) {
  final krs = service.getKrsMahasiswa(mahasiswa.nim);
  final approvedKrs = krs.where((item) => item.isValidated).toList();
  var sks = 0;
  for (final item in approvedKrs) {
    final kelas = service.getKelasById(item.kelasId);
    final mataKuliah = kelas == null
        ? null
        : service.getMataKuliahByKode(kelas.mataKuliahId);
    sks += mataKuliah?.sks ?? 0;
  }
  final nilai = service.getNilaiMahasiswa(mahasiswa.nim);
  final ipk = nilai.isEmpty
      ? 0.0
      : nilai
                .map((item) => _bobotNilai(item.nilaiHuruf))
                .reduce((a, b) => a + b) /
            nilai.length;
  final presensi = service.getPresensiMahasiswa(mahasiswa.nim);
  return _KorproMahasiswaMetric(
    mahasiswa: mahasiswa,
    ipk: ipk,
    sksDisetujui: sks,
    krsApproved: approvedKrs.length,
    krsTotal: krs.length,
    presensiHadir: _countStatus(presensi, 'Hadir'),
    presensiTotal: presensi.length,
  );
}

void _sortKorproMahasiswa(
  List<_KorproMahasiswaMetric> metrics,
  _KorproMahasiswaSort sort,
) {
  metrics.sort((a, b) {
    switch (sort) {
      case _KorproMahasiswaSort.nama:
        return a.mahasiswa.nama.compareTo(b.mahasiswa.nama);
      case _KorproMahasiswaSort.semester:
        return b.mahasiswa.semester.compareTo(a.mahasiswa.semester);
      case _KorproMahasiswaSort.ipk:
        return b.ipk.compareTo(a.ipk);
      case _KorproMahasiswaSort.presensi:
        return b.presensiRate.compareTo(a.presensiRate);
      case _KorproMahasiswaSort.sks:
        return b.sksDisetujui.compareTo(a.sksDisetujui);
    }
  });
}

void _showKorproMahasiswaDetail(
  BuildContext context,
  MockService service,
  _KorproMahasiswaMetric metric,
) {
  final mahasiswa = metric.mahasiswa;
  final dosenPa = service.getDosenName(mahasiswa.pembimbingAkademikId);
  final riwayat = service.getRiwayatStatusMahasiswa(mahasiswa.nim);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text(mahasiswa.nama.substring(0, 1))),
            title: Text(
              mahasiswa.nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${mahasiswa.nim} - ${mahasiswa.status.label}'),
            trailing: Chip(label: Text(metric.riskLabel)),
          ),
          const SizedBox(height: 8),
          _KorproDetailRow(label: 'Semester', value: '${mahasiswa.semester}'),
          _KorproDetailRow(
            label: 'Jenis Kelamin',
            value: mahasiswa.jenisKelamin,
          ),
          _KorproDetailRow(label: 'Dosen PA', value: dosenPa),
          _KorproDetailRow(
            label: 'Email',
            value: mahasiswa.email.isEmpty ? '-' : mahasiswa.email,
          ),
          _KorproDetailRow(
            label: 'No HP',
            value: mahasiswa.noHp.isEmpty ? '-' : mahasiswa.noHp,
          ),
          _KorproDetailRow(
            label: 'Alamat',
            value: mahasiswa.alamat.isEmpty ? '-' : mahasiswa.alamat,
          ),
          const Divider(height: 28),
          _KorproMetricProgress(
            label: 'Presensi',
            value: metric.presensiRate,
            color: _attendanceRateColor(metric.presensiRate),
            tooltip: '${metric.presensiHadir}/${metric.presensiTotal} hadir',
          ),
          const SizedBox(height: 14),
          _KorproDetailRow(label: 'IPK', value: metric.ipk.toStringAsFixed(2)),
          _KorproDetailRow(
            label: 'SKS KRS disetujui',
            value: '${metric.sksDisetujui}',
          ),
          _KorproDetailRow(label: 'Status KRS', value: metric.krsStatus),
          const Divider(height: 28),
          Text(
            'Riwayat Status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (riwayat.isEmpty)
            const Text('Belum ada riwayat perubahan status.')
          else
            for (final item in riwayat)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history_rounded),
                title: Text(
                  '${item.statusSebelumnya.label} -> ${item.statusBaru.label}',
                ),
                subtitle: Text(item.namaBukti),
              ),
        ],
      ),
    ),
  );
}

class _KorproDetailRow extends StatelessWidget {
  const _KorproDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

Color _studentStatusColor(StatusMahasiswa status) {
  switch (status) {
    case StatusMahasiswa.aktif:
      return Colors.green;
    case StatusMahasiswa.cuti:
      return Colors.amber.shade700;
    case StatusMahasiswa.nonaktif:
      return Colors.orange;
    case StatusMahasiswa.lulus:
      return Colors.blue;
    case StatusMahasiswa.dropOut:
      return Colors.red;
  }
}

Color _studentRiskColor(int riskLevel) {
  if (riskLevel == 0) return Colors.green;
  if (riskLevel == 1) return Colors.orange;
  return Colors.red;
}

Color _academicColor(double ipk) {
  if (ipk >= 3.5) return Colors.green;
  if (ipk >= 2.75) return Colors.amber.shade700;
  if (ipk == 0) return Colors.grey;
  return Colors.red;
}

class KorproPresensiOverviewView extends StatefulWidget {
  const KorproPresensiOverviewView({required this.user, super.key});

  final User user;

  @override
  State<KorproPresensiOverviewView> createState() =>
      _KorproPresensiOverviewViewState();
}

class _KorproPresensiOverviewViewState
    extends State<KorproPresensiOverviewView> {
  String? tahunAjaranId;

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
    final prodi = service.prodi.firstWhere(
      (item) => item.id == widget.user.scopeId,
    );
    final selectedTahunId = tahunAjaranId ?? service.tahunAjaranAktif.id;
    final selectedTahun = service.tahunAjaran.firstWhere(
      (item) => item.id == selectedTahunId,
    );
    final kelasMetrics = _korproKelasAttendanceMetrics(
      service,
      widget.user.scopeId,
      selectedTahunId,
    );
    final kelasIds = kelasMetrics.map((item) => item.kelasId).toSet();
    final pertemuanIds = service.pertemuan
        .where((item) => kelasIds.contains(item.kelasId))
        .map((item) => item.id)
        .toSet();
    final presensiMahasiswa = service.presensi
        .where((item) => pertemuanIds.contains(item.pertemuanId))
        .toList();
    final presensiDosen = service.presensiDosen
        .where((item) => pertemuanIds.contains(item.pertemuanId))
        .toList();
    final hadirMahasiswa = _countStatus(presensiMahasiswa, 'Hadir');
    final hadirDosen = _countDosenStatus(presensiDosen, 'Hadir');
    final mahasiswaRate = presensiMahasiswa.isEmpty
        ? 0.0
        : hadirMahasiswa / presensiMahasiswa.length;
    final dosenRate = presensiDosen.isEmpty
        ? 0.0
        : hadirDosen / presensiDosen.length;
    final completedMeetings = kelasMetrics.fold<int>(
      0,
      (total, item) => total + item.meetings.where((m) => m.hasData).length,
    );
    final needsAttention = kelasMetrics
        .where((item) => item.totalMahasiswa > 0 && item.mahasiswaRate < 0.75)
        .length;
    final distribution = _PresensiChartMetric(
      id: prodi.id,
      nama: prodi.nama,
      prodiCount: 1,
      mahasiswa: _presensiCounts(presensiMahasiswa),
      dosen: _presensiDosenCounts(presensiDosen),
    );

    return AppScaffold(
      title: 'Overview Presensi ${prodi.nama}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final heading = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Intelligence',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${prodi.nama} - ${selectedTahun.label}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ringkasan presensi, pola pertemuan, dan kelas yang membutuhkan perhatian.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                  final filter = _Filter<String>(
                    label: 'Tahun Ajaran',
                    value: selectedTahunId,
                    items: service.tahunAjaran
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => tahunAjaranId = value),
                  );
                  if (constraints.maxWidth < 680) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [heading, const SizedBox(height: 14), filter],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: heading),
                      const SizedBox(width: 16),
                      filter,
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          _KorproAttendanceKpiGrid(
            mahasiswaRate: mahasiswaRate,
            dosenRate: dosenRate,
            completedMeetings: completedMeetings,
            needsAttention: needsAttention,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 880;
              final gaugePanel = _KorproAttendanceGaugePanel(
                mahasiswaRate: mahasiswaRate,
                dosenRate: dosenRate,
                mahasiswaTotal: presensiMahasiswa.length,
                dosenTotal: presensiDosen.length,
              );
              final distributionPanel = _KorproDistributionPanel(
                metric: distribution,
              );
              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    gaugePanel,
                    const SizedBox(height: 14),
                    distributionPanel,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: gaugePanel),
                  const SizedBox(width: 14),
                  Expanded(flex: 2, child: distributionPanel),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _KorproAttendanceHeatmap(
            kelasMetrics: kelasMetrics,
            tahunLabel: selectedTahun.label,
          ),
          const SizedBox(height: 14),
          _KorproAttentionList(kelasMetrics: kelasMetrics),
        ],
      ),
    );
  }
}

class _KorproAttendanceKpiGrid extends StatelessWidget {
  const _KorproAttendanceKpiGrid({
    required this.mahasiswaRate,
    required this.dosenRate,
    required this.completedMeetings,
    required this.needsAttention,
  });

  final double mahasiswaRate;
  final double dosenRate;
  final int completedMeetings;
  final int needsAttention;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Kehadiran Mahasiswa',
        '${(mahasiswaRate * 100).toStringAsFixed(1)}%',
        Icons.groups_rounded,
        _attendanceRateColor(mahasiswaRate),
      ),
      (
        'Kehadiran Dosen',
        '${(dosenRate * 100).toStringAsFixed(1)}%',
        Icons.co_present_rounded,
        _attendanceRateColor(dosenRate),
      ),
      (
        'Pertemuan Terekam',
        '$completedMeetings',
        Icons.fact_check_rounded,
        Theme.of(context).colorScheme.primary,
      ),
      (
        'Perlu Perhatian',
        '$needsAttention kelas',
        Icons.warning_amber_rounded,
        needsAttention == 0 ? Colors.green : Colors.orange,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 12)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var index = 0; index < items.length; index++)
              SizedBox(
                width: width,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 350 + (index * 90)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(0, 16 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  ),
                  child: _KorproAttendanceKpiCard(
                    label: items[index].$1,
                    value: items[index].$2,
                    icon: items[index].$3,
                    color: items[index].$4,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KorproAttendanceKpiCard extends StatelessWidget {
  const _KorproAttendanceKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _KorproAttendanceGaugePanel extends StatelessWidget {
  const _KorproAttendanceGaugePanel({
    required this.mahasiswaRate,
    required this.dosenRate,
    required this.mahasiswaTotal,
    required this.dosenTotal,
  });

  final double mahasiswaRate;
  final double dosenRate;
  final int mahasiswaTotal;
  final int dosenTotal;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Attendance Health',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Persentase hadir dari seluruh data presensi.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _KorproAttendanceGauge(
                  label: 'Mahasiswa',
                  rate: mahasiswaRate,
                  total: mahasiswaTotal,
                ),
              ),
              Expanded(
                child: _KorproAttendanceGauge(
                  label: 'Dosen',
                  rate: dosenRate,
                  total: dosenTotal,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _KorproAttendanceGauge extends StatelessWidget {
  const _KorproAttendanceGauge({
    required this.label,
    required this.rate,
    required this.total,
  });

  final String label;
  final double rate;
  final int total;

  @override
  Widget build(BuildContext context) {
    final color = _attendanceRateColor(rate);
    return Tooltip(
      message:
          '$label\n${(rate * 100).toStringAsFixed(1)}% hadir dari $total data',
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: rate),
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => SizedBox(
              width: 128,
              height: 128,
              child: CustomPaint(
                painter: _KorproGaugePainter(
                  value: value,
                  color: color,
                  trackColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('$total data', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _KorproGaugePainter extends CustomPainter {
  const _KorproGaugePainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(8), -1.5708, 6.28318, false, track);
    canvas.drawArc(
      rect.deflate(8),
      -1.5708,
      6.28318 * value.clamp(0, 1),
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _KorproGaugePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}

class _KorproDistributionPanel extends StatelessWidget {
  const _KorproDistributionPanel({required this.metric});

  final _PresensiChartMetric metric;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _PresensiSmallMultipleChart(
        metric: metric,
        showDrillDown: false,
        onTap: () {},
      ),
    ],
  );
}

class _KorproAttendanceHeatmap extends StatelessWidget {
  const _KorproAttendanceHeatmap({
    required this.kelasMetrics,
    required this.tahunLabel,
  });

  final List<_KorproKelasAttendanceMetric> kelasMetrics;
  final String tahunLabel;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Heatmap Kehadiran per Pertemuan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$tahunLabel - arahkan pointer ke kotak untuk melihat detail.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          if (kelasMetrics.isEmpty)
            const ListTile(title: Text('Belum ada kelas pada tahun ajaran ini'))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 210),
                      for (var number = 1; number <= 16; number++)
                        SizedBox(
                          width: 38,
                          child: Text(
                            '$number',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (final metric in kelasMetrics)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 210,
                            child: Text(
                              metric.nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          for (final meeting in metric.meetings)
                            _KorproHeatmapCell(
                              kelasName: metric.nama,
                              meeting: meeting,
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  const _KorproHeatmapLegend(),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _KorproHeatmapCell extends StatefulWidget {
  const _KorproHeatmapCell({required this.kelasName, required this.meeting});

  final String kelasName;
  final _KorproMeetingAttendance meeting;

  @override
  State<_KorproHeatmapCell> createState() => _KorproHeatmapCellState();
}

class _KorproHeatmapCellState extends State<_KorproHeatmapCell> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final meeting = widget.meeting;
    final color = meeting.hasData
        ? _attendanceRateColor(meeting.rate)
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    return Tooltip(
      waitDuration: const Duration(milliseconds: 150),
      message:
          '${widget.kelasName}\n'
          'Pertemuan ${meeting.number}\n'
          '${meeting.hasData ? '${meeting.hadir}/${meeting.total} hadir (${(meeting.rate * 100).toStringAsFixed(1)}%)' : 'Belum ada data'}',
      child: MouseRegion(
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          transform: Matrix4.diagonal3Values(
            hovered ? 1.12 : 1,
            hovered ? 1.12 : 1,
            1,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: meeting.hasData ? 0.86 : 0.55),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: hovered
                  ? color
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

class _KorproHeatmapLegend extends StatelessWidget {
  const _KorproHeatmapLegend();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text('Rendah', style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(width: 6),
      for (final rate in const [0.4, 0.6, 0.8, 1.0])
        Container(
          width: 22,
          height: 10,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            color: _attendanceRateColor(rate),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      const SizedBox(width: 3),
      Text('Baik', style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _KorproAttentionList extends StatelessWidget {
  const _KorproAttentionList({required this.kelasMetrics});

  final List<_KorproKelasAttendanceMetric> kelasMetrics;

  @override
  Widget build(BuildContext context) {
    final ranked =
        kelasMetrics.where((item) => item.totalMahasiswa > 0).toList()
          ..sort((a, b) => a.mahasiswaRate.compareTo(b.mahasiswaRate));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Kelas yang Perlu Perhatian',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Diurutkan berdasarkan tingkat kehadiran mahasiswa terendah.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (ranked.isEmpty)
              const ListTile(title: Text('Belum ada data presensi kelas'))
            else
              for (final item in ranked.take(5))
                _KorproAttentionTile(metric: item),
          ],
        ),
      ),
    );
  }
}

class _KorproAttentionTile extends StatelessWidget {
  const _KorproAttentionTile({required this.metric});

  final _KorproKelasAttendanceMetric metric;

  @override
  Widget build(BuildContext context) {
    final color = _attendanceRateColor(metric.mahasiswaRate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Tooltip(
        message:
            '${metric.hadirMahasiswa}/${metric.totalMahasiswa} data mahasiswa hadir',
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.class_outlined, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          metric.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${(metric.mahasiswaRate * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: metric.mahasiswaRate),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KorproKelasAttendanceMetric {
  const _KorproKelasAttendanceMetric({
    required this.kelasId,
    required this.nama,
    required this.meetings,
    required this.hadirMahasiswa,
    required this.totalMahasiswa,
  });

  final String kelasId;
  final String nama;
  final List<_KorproMeetingAttendance> meetings;
  final int hadirMahasiswa;
  final int totalMahasiswa;

  double get mahasiswaRate =>
      totalMahasiswa == 0 ? 0 : hadirMahasiswa / totalMahasiswa;
}

class _KorproMeetingAttendance {
  const _KorproMeetingAttendance({
    required this.number,
    required this.hadir,
    required this.total,
  });

  final int number;
  final int hadir;
  final int total;

  bool get hasData => total > 0;
  double get rate => total == 0 ? 0 : hadir / total;
}

List<_KorproKelasAttendanceMetric> _korproKelasAttendanceMetrics(
  MockService service,
  String prodiId,
  String tahunAjaranId,
) {
  final mataKuliahIds = service.mataKuliah
      .where((item) => item.prodiId == prodiId)
      .map((item) => item.kode)
      .toSet();
  final kelas = service.kelas
      .where(
        (item) =>
            mataKuliahIds.contains(item.mataKuliahId) &&
            item.tahunAjaranId == tahunAjaranId,
      )
      .toList();

  return kelas.map((item) {
    final meetings = <_KorproMeetingAttendance>[];
    var hadirTotal = 0;
    var presensiTotal = 0;
    final pertemuanByNumber = {
      for (final pertemuan in service.getPertemuanKelas(item.id))
        pertemuan.pertemuanKe: pertemuan,
    };
    for (var number = 1; number <= 16; number++) {
      final meeting = pertemuanByNumber[number];
      final attendance = meeting == null
          ? const <Presensi>[]
          : service.getPresensiPertemuan(meeting.id);
      final hadir = _countStatus(attendance, 'Hadir');
      hadirTotal += hadir;
      presensiTotal += attendance.length;
      meetings.add(
        _KorproMeetingAttendance(
          number: number,
          hadir: hadir,
          total: attendance.length,
        ),
      );
    }
    return _KorproKelasAttendanceMetric(
      kelasId: item.id,
      nama: '${service.getMataKuliahName(item.mataKuliahId)} - ${item.id}',
      meetings: meetings,
      hadirMahasiswa: hadirTotal,
      totalMahasiswa: presensiTotal,
    );
  }).toList();
}

Color _attendanceRateColor(double rate) {
  if (rate >= 0.85) return Colors.green;
  if (rate >= 0.70) return Colors.amber.shade700;
  return Colors.red;
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
  DashboardCacheKey? _cachedKey;
  _DekanDashboardSnapshot? _cachedSnapshot;

  _DekanDashboardSnapshot _snapshotFor(MockService service, String tahunId) {
    final key = DashboardCacheKey(
      revision: service.dataRevision,
      tahunAjaranId: tahunId,
      semester: semester,
      fakultasId: widget.user.scopeId,
      prodiId: prodiId,
    );
    if (_cachedKey == key && _cachedSnapshot != null) {
      return _cachedSnapshot!;
    }
    final snapshot = _DekanDashboardSnapshot.build(
      service: service,
      fakultasId: widget.user.scopeId,
      tahunId: tahunId,
      semester: semester,
      prodiId: prodiId,
    );
    _cachedKey = key;
    _cachedSnapshot = snapshot;
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
    final tahunId = tahunAjaranId ?? service.tahunAjaranAktif.id;
    final snapshot = _snapshotFor(service, tahunId);
    final fakultas = snapshot.fakultas;
    final prodiFakultas = snapshot.prodiFakultas;
    final mahasiswa = snapshot.mahasiswa;
    final dosen = snapshot.dosen;
    final mataKuliah = snapshot.mataKuliah;
    final kelas = snapshot.kelas;
    final krs = snapshot.krs;
    final sudahKrs = snapshot.sudahKrs;
    final presensiMahasiswa = snapshot.presensiMahasiswa;
    final presensiDosen = snapshot.presensiDosen;
    final hadirMahasiswa = snapshot.hadirMahasiswa;
    final hadirDosen = snapshot.hadirDosen;
    final ruangTerpakai = snapshot.ruangTerpakai;
    final kelasAktif = snapshot.kelasAktif;
    final dosenBelumPresensi = snapshot.dosenBelumPresensi;
    final mataKuliahPresensiRendah = snapshot.mataKuliahPresensiRendah;

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
  DashboardCacheKey? _cachedKey;
  _RektorDashboardSnapshot? _cachedSnapshot;

  _RektorDashboardSnapshot _snapshotFor(MockService service, String tahunId) {
    final key = DashboardCacheKey(
      revision: service.dataRevision,
      tahunAjaranId: tahunId,
      semester: semester,
      fakultasId: fakultasId,
      prodiId: prodiId,
      mataKuliahId: mataKuliahId,
      dosenId: dosenId,
      statusKrs: statusKrs,
      statusPresensi: statusPresensi,
    );
    if (_cachedKey == key && _cachedSnapshot != null) {
      return _cachedSnapshot!;
    }
    final snapshot = _RektorDashboardSnapshot.build(
      service: service,
      tahunId: tahunId,
      semester: semester,
      fakultasId: fakultasId,
      prodiId: prodiId,
      mataKuliahId: mataKuliahId,
      dosenId: dosenId,
      statusKrs: statusKrs,
      statusPresensi: statusPresensi,
    );
    _cachedKey = key;
    _cachedSnapshot = snapshot;
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
    final tahunId = tahunAjaranId ?? service.tahunAjaranAktif.id;
    final snapshot = _snapshotFor(service, tahunId);
    final tahun = snapshot.tahun;
    final prodi = snapshot.prodi;
    final prodiIds = snapshot.prodiIds;
    final mahasiswa = snapshot.mahasiswa;
    final dosen = snapshot.dosen;
    final mataKuliah = snapshot.mataKuliah;
    final kelas = snapshot.kelas;
    final krs = snapshot.krs;
    final pertemuan = snapshot.pertemuan;
    final presensiMahasiswa = snapshot.presensiMahasiswa;
    final presensiDosen = snapshot.presensiDosen;
    final hadirMahasiswa = snapshot.hadirMahasiswa;
    final hadirDosen = snapshot.hadirDosen;
    final sudahKrs = snapshot.sudahKrs;
    final krsApproved = snapshot.krsApproved;
    final ruangTerpakai = snapshot.ruangTerpakai;
    final fakultasMetrics = snapshot.fakultasMetrics;
    final krsApprovalRate = snapshot.krsApprovalRate;
    final presensiMahasiswaRate = snapshot.presensiMahasiswaRate;
    final presensiDosenRate = snapshot.presensiDosenRate;
    final ruangTerpakaiRate = snapshot.ruangTerpakaiRate;
    final campusHealth = snapshot.campusHealth;
    final waitingKrs = snapshot.waitingKrs;
    final unusedRooms = snapshot.unusedRooms;
    final fullClasses = snapshot.fullClasses;

    return AppScaffold(
      title: 'Dashboard Rektor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RektorCommandHero(
            tahun: tahun.label,
            tanggal: _tanggalHariIni(),
            campusHealth: campusHealth,
            totalMahasiswa: mahasiswa.length,
            totalDosen: dosen.length,
            topFakultas: snapshot.topFakultas,
            topProdi: snapshot.topProdi,
            activeFilters: snapshot.activeFilters,
          ),
          const SizedBox(height: 14),
          _RektorFilterPanel(
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
                          fakultasId == null || item.fakultasId == fakultasId,
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
                  DropdownMenuItem(value: 'S1', child: Text('Sarjana (S1)')),
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
                onChanged: (value) => setState(() => statusPresensi = value),
              ),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
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
                  label: const Text('Reset'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RektorExecutiveGrid(
            items: [
              _RektorExecutiveMetric(
                title: 'Kesehatan Kampus',
                value: campusHealth.toStringAsFixed(0),
                suffix: '%',
                icon: Icons.monitor_heart_outlined,
                color: _dashboardScoreColor(campusHealth / 100),
                progress: campusHealth / 100,
                note: 'Skor gabungan KRS, presensi, kelas, dan ruangan',
              ),
              _RektorExecutiveMetric(
                title: 'KRS Disetujui',
                value: (krsApprovalRate * 100).toStringAsFixed(0),
                suffix: '%',
                icon: Icons.fact_check_outlined,
                color: const Color(0xFF0B57D0),
                progress: krsApprovalRate,
                note: '$krsApproved dari ${krs.length} KRS',
              ),
              _RektorExecutiveMetric(
                title: 'Presensi Mahasiswa',
                value: (presensiMahasiswaRate * 100).toStringAsFixed(0),
                suffix: '%',
                icon: Icons.groups_2_outlined,
                color: const Color(0xFF00897B),
                progress: presensiMahasiswaRate,
                note: '${presensiMahasiswa.length} rekaman presensi',
              ),
              _RektorExecutiveMetric(
                title: 'Presensi Dosen',
                value: (presensiDosenRate * 100).toStringAsFixed(0),
                suffix: '%',
                icon: Icons.co_present_outlined,
                color: const Color(0xFF7B1FA2),
                progress: presensiDosenRate,
                note: '${presensiDosen.length} rekaman presensi dosen',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RektorSnapshotStrip(
            stats: [
              _Stat(
                'Fakultas',
                fakultasId == null ? service.fakultas.length : 1,
              ),
              _Stat('Program Studi', prodi.length),
              _Stat('Mahasiswa', mahasiswa.length),
              _Stat(
                'Aktif',
                mahasiswa
                    .where((e) => e.status == StatusMahasiswa.aktif)
                    .length,
              ),
              _Stat('Dosen', dosen.length),
              _Stat('Mata Kuliah', mataKuliah.length),
              _Stat('Kelas', kelas.length),
              _Stat('Ruangan', service.ruangan.length),
            ],
          ),
          const SizedBox(height: 14),
          _RektorActionDock(
            onOpenData: widget.onOpenData,
            onOpenKrs: widget.onOpenKrs,
            onOpenPresensi: widget.onOpenPresensi,
            onOpenLaporan: widget.onOpenLaporan,
          ),
          const SizedBox(height: 14),
          _RektorInsightPanel(
            campusHealth: campusHealth,
            krsApprovalRate: krsApprovalRate,
            presensiMahasiswaRate: presensiMahasiswaRate,
            presensiDosenRate: presensiDosenRate,
            ruangTerpakaiRate: ruangTerpakaiRate,
            waitingKrs: waitingKrs,
            unusedRooms: unusedRooms,
            fullClasses: fullClasses,
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
              _Stat('Prodi Mahasiswa Terbanyak', snapshot.topProdi),
              _Stat('Fakultas Mahasiswa Terbanyak', snapshot.topFakultas),
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
            menungguValidasi: waitingKrs,
            ruanganKosong: unusedRooms,
            kelasPenuh: fullClasses,
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
    final service = context.read<MockService>();
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
  static const _mahasiswaPageSize = 10;

  _PimpinanDataMenu selectedMenu = _PimpinanDataMenu.mahasiswa;
  String? fakultasId;
  String? prodiId;
  int _mahasiswaPage = 0;

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
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
    final mahasiswaCount = service.mahasiswa
        .where((item) => filteredProdiIds.contains(item.prodiId))
        .length;
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
      _PimpinanDataMenu.mahasiswa => const <Widget>[],
      _PimpinanDataMenu.dosen =>
        dosen
            .map(
              (item) => ListTile(
                leading: const Icon(Icons.co_present_outlined),
                title: Text(item.nama),
                subtitle: Text('${item.nidn}\n${scopeLabel(item.prodiId)}'),
                isThreeLine: true,
              ),
            )
            .toList(),
      _PimpinanDataMenu.mataKuliah =>
        mataKuliah
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
      _PimpinanDataMenu.kelasKuliah => kelas.map((item) {
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
      }).toList(),
      _PimpinanDataMenu.ruangKelas =>
        ruangan
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
                              _mahasiswaPage = 0;
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
                      _mahasiswaPage = 0;
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
                    onChanged: (value) => setState(() {
                      prodiId = value;
                      _mahasiswaPage = 0;
                    }),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      fakultasId = null;
                      prodiId = null;
                      _mahasiswaPage = 0;
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Filter'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (selectedMenu == _PimpinanDataMenu.mahasiswa)
            _PagedPimpinanMahasiswaList(
              service: service,
              page: _mahasiswaPage,
              pageSize: _mahasiswaPageSize,
              count: mahasiswaCount,
              prodiIds: filteredProdiIds,
              scopeLabel: scopeLabel,
              onPrevious: () => setState(() => _mahasiswaPage--),
              onNext: () => setState(() => _mahasiswaPage++),
            )
          else
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

class PimpinanKrsView extends StatefulWidget {
  const PimpinanKrsView({this.user, super.key});

  final User? user;

  @override
  State<PimpinanKrsView> createState() => _PimpinanKrsViewState();
}

class _PimpinanKrsViewState extends State<PimpinanKrsView> {
  static const _pageSize = 10;

  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
    final allowedProdiIds = _allowedProdiIds(service, widget.user);
    return AppScaffold(
      title: 'Monitoring KRS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ReadOnlyNotice(),
          const SizedBox(height: 12),
          FutureBuilder<PagedKrsResult>(
            future: service.fetchKrsPage(
              page: _page,
              pageSize: _pageSize,
              prodiIds: allowedProdiIds,
            ),
            builder: (context, snapshot) {
              final result = snapshot.data;
              final items = result?.items ?? const <PagedKrsItem>[];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text('Memuat 10 data KRS...'),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text('Gagal memuat data KRS'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }
              if (items.isEmpty) {
                return const Card(
                  child: ListTile(title: Text('Belum ada data KRS')),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in items)
                    Card(
                      child: ListTile(
                        title: Text(item.mahasiswaName),
                        subtitle: Text(
                          '${item.mataKuliahName} - Semester ${item.krs.semester}',
                        ),
                        trailing: Chip(label: Text(_krsStatus(item.krs))),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 96),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Halaman ${_page + 1} - ${items.length} dari maks. $_pageSize data',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Halaman sebelumnya',
                          onPressed: result?.hasPrevious == true
                              ? () => setState(() => _page--)
                              : null,
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        IconButton(
                          tooltip: 'Halaman berikutnya',
                          onPressed: result?.hasNext == true
                              ? () => setState(() => _page++)
                              : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
  String? selectedFakultasId;

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
    final allowedProdiIds = _allowedProdiIds(service, widget.user);
    final fakultas = service.fakultas.where((item) {
      return service.prodi.any(
        (prodi) =>
            prodi.fakultasId == item.id && allowedProdiIds.contains(prodi.id),
      );
    }).toList();
    Fakultas? selectedFakultas;
    for (final item in fakultas) {
      if (item.id == selectedFakultasId) selectedFakultas = item;
    }
    final metrics = selectedFakultas == null
        ? fakultas.map((item) {
            final prodiIds = service.prodi
                .where(
                  (prodi) =>
                      prodi.fakultasId == item.id &&
                      allowedProdiIds.contains(prodi.id),
                )
                .map((prodi) => prodi.id)
                .toSet();
            return _presensiChartMetric(
              service: service,
              id: item.id,
              nama: item.nama,
              prodiIds: prodiIds,
            );
          }).toList()
        : service.prodi
              .where(
                (item) =>
                    item.fakultasId == selectedFakultas!.id &&
                    allowedProdiIds.contains(item.id),
              )
              .map(
                (item) => _presensiChartMetric(
                  service: service,
                  id: item.id,
                  nama: item.nama,
                  prodiIds: {item.id},
                ),
              )
              .toList();

    return AppScaffold(
      title: 'Monitoring Presensi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ReadOnlyNotice(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _PresensiChartHeader(
                title: selectedFakultas == null
                    ? 'Presensi per Fakultas'
                    : 'Presensi Prodi - ${selectedFakultas.nama}',
                description: selectedFakultas == null
                    ? 'Klik grafik fakultas untuk melihat rincian setiap program studi.'
                    : 'Arahkan pointer ke kolom untuk melihat detail data presensi.',
                showBack: selectedFakultas != null,
                onBack: () => setState(() => selectedFakultasId = null),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _PresensiSmallMultipleGrid(
              key: ValueKey(selectedFakultas?.id ?? 'fakultas'),
              metrics: metrics,
              showDrillDown: selectedFakultas == null,
              onSelected: (metric) {
                if (selectedFakultas != null) return;
                setState(() => selectedFakultasId = metric.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}

const _presensiStatuses = ['Hadir', 'Izin', 'Sakit', 'Alfa'];
const _presensiMahasiswaColor = Color(0xFF0B57D0);
const _presensiDosenColor = Color(0xFFFFA000);

class _PresensiChartMetric {
  const _PresensiChartMetric({
    required this.id,
    required this.nama,
    required this.prodiCount,
    required this.mahasiswa,
    required this.dosen,
  });

  final String id;
  final String nama;
  final int prodiCount;
  final Map<String, int> mahasiswa;
  final Map<String, int> dosen;

  int get totalMahasiswa =>
      mahasiswa.values.fold(0, (total, value) => total + value);
  int get totalDosen => dosen.values.fold(0, (total, value) => total + value);
}

_PresensiChartMetric _presensiChartMetric({
  required MockService service,
  required String id,
  required String nama,
  required Set<String> prodiIds,
}) {
  final mataKuliahProdi = {
    for (final item in service.mataKuliah) item.kode: item.prodiId,
  };
  final kelasProdi = <String, String>{};
  for (final item in service.kelas) {
    final prodiId = mataKuliahProdi[item.mataKuliahId];
    if (prodiId != null && prodiIds.contains(prodiId)) {
      kelasProdi[item.id] = prodiId;
    }
  }
  final pertemuanIds = service.pertemuan
      .where((item) => kelasProdi.containsKey(item.kelasId))
      .map((item) => item.id)
      .toSet();
  final mahasiswa = {for (final status in _presensiStatuses) status: 0};
  final dosen = {for (final status in _presensiStatuses) status: 0};

  for (final item in service.presensi) {
    if (!pertemuanIds.contains(item.pertemuanId)) continue;
    final status = _normalizedPresensiStatus(item.statusKehadiran);
    if (status != null) mahasiswa[status] = mahasiswa[status]! + 1;
  }
  for (final item in service.presensiDosen) {
    if (!pertemuanIds.contains(item.pertemuanId)) continue;
    final status = _normalizedPresensiStatus(item.statusKehadiran);
    if (status != null) dosen[status] = dosen[status]! + 1;
  }

  return _PresensiChartMetric(
    id: id,
    nama: nama,
    prodiCount: prodiIds.length,
    mahasiswa: mahasiswa,
    dosen: dosen,
  );
}

String? _normalizedPresensiStatus(String status) {
  if (status == 'Hadir') return 'Hadir';
  if (status == 'Izin' || status == 'Ijin') return 'Izin';
  if (status == 'Sakit') return 'Sakit';
  if (status == 'Alfa' || status == 'Alpa') return 'Alfa';
  return null;
}

class _PresensiSmallMultipleGrid extends StatelessWidget {
  const _PresensiSmallMultipleGrid({
    required this.metrics,
    required this.showDrillDown,
    required this.onSelected,
    super.key,
  });

  final List<_PresensiChartMetric> metrics;
  final bool showDrillDown;
  final ValueChanged<_PresensiChartMetric> onSelected;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.bar_chart_rounded),
          title: Text('Belum ada data presensi'),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 650
            ? 2
            : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 14)) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: _PresensiSmallMultipleChart(
                  metric: metric,
                  showDrillDown: showDrillDown,
                  onTap: () => onSelected(metric),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PresensiSmallMultipleChart extends StatelessWidget {
  const _PresensiSmallMultipleChart({
    required this.metric,
    required this.showDrillDown,
    required this.onTap,
  });

  final _PresensiChartMetric metric;
  final bool showDrillDown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = [
      ...metric.mahasiswa.values,
      ...metric.dosen.values,
    ].fold<int>(1, (current, value) => value > current ? value : current);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: showDrillDown ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metric.nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          showDrillDown
                              ? '${metric.prodiCount} prodi - ${metric.totalMahasiswa + metric.totalDosen} data'
                              : '${metric.totalMahasiswa + metric.totalDosen} data presensi',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (showDrillDown)
                    Icon(Icons.open_in_new_rounded, color: scheme.primary),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 210,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final status in _presensiStatuses)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: _AnimatedPresensiBar(
                                        label: 'Mahasiswa',
                                        status: status,
                                        unitName: metric.nama,
                                        value: metric.mahasiswa[status]!,
                                        total: metric.totalMahasiswa,
                                        maxValue: maxValue,
                                        color: _presensiMahasiswaColor,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: _AnimatedPresensiBar(
                                        label: 'Dosen',
                                        status: status,
                                        unitName: metric.nama,
                                        value: metric.dosen[status]!,
                                        total: metric.totalDosen,
                                        maxValue: maxValue,
                                        color: _presensiDosenColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                status,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedPresensiBar extends StatefulWidget {
  const _AnimatedPresensiBar({
    required this.label,
    required this.status,
    required this.unitName,
    required this.value,
    required this.total,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final String status;
  final String unitName;
  final int value;
  final int total;
  final int maxValue;
  final Color color;

  @override
  State<_AnimatedPresensiBar> createState() => _AnimatedPresensiBarState();
}

class _AnimatedPresensiBarState extends State<_AnimatedPresensiBar> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final percentage = widget.total == 0
        ? 0
        : widget.value / widget.total * 100;
    return Tooltip(
      waitDuration: const Duration(milliseconds: 180),
      message:
          '${widget.unitName}\n'
          '${widget.label} - ${widget.status}\n'
          '${widget.value} data (${percentage.toStringAsFixed(1)}%)',
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final target = widget.value / widget.maxValue;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: target),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: value == 0
                      ? 4
                      : (constraints.maxHeight * value).clamp(
                          4,
                          constraints.maxHeight,
                        ),
                  decoration: BoxDecoration(
                    color: hovered
                        ? widget.color
                        : widget.color.withValues(alpha: 0.78),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                    boxShadow: hovered
                        ? [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.30),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PresensiChartHeader extends StatelessWidget {
  const _PresensiChartHeader({
    required this.title,
    required this.description,
    required this.showBack,
    required this.onBack,
  });

  final String title;
  final String description;
  final bool showBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final heading = Row(
      children: [
        if (showBack) ...[
          IconButton.filledTonal(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Kembali ke fakultas',
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: 12),
              const _PresensiChartLegend(),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: heading),
            const SizedBox(width: 16),
            const _PresensiChartLegend(),
          ],
        );
      },
    );
  }
}

class _PresensiChartLegend extends StatelessWidget {
  const _PresensiChartLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: const [
        _PresensiLegendItem(label: 'Mahasiswa', color: _presensiMahasiswaColor),
        _PresensiLegendItem(label: 'Dosen', color: _presensiDosenColor),
      ],
    );
  }
}

class _PresensiLegendItem extends StatelessWidget {
  const _PresensiLegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}

class PimpinanLaporanView extends StatelessWidget {
  const PimpinanLaporanView({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final service = context.read<MockService>();
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

class _PagedPimpinanMahasiswaList extends StatelessWidget {
  const _PagedPimpinanMahasiswaList({
    required this.service,
    required this.page,
    required this.pageSize,
    required this.count,
    required this.prodiIds,
    required this.scopeLabel,
    required this.onPrevious,
    required this.onNext,
  });

  final MockService service;
  final int page;
  final int pageSize;
  final int count;
  final Set<String> prodiIds;
  final String Function(String prodiId) scopeLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PagedMahasiswaResult>(
      future: service.fetchMahasiswaPage(
        page: page,
        pageSize: pageSize,
        prodiIds: prodiIds,
      ),
      builder: (context, snapshot) {
        final result = snapshot.data;
        final children = result?.items ?? const <Mahasiswa>[];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: const Text(
                    'Data Mahasiswa',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Chip(label: Text('$count data')),
                ),
                const Divider(height: 1),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text('Memuat 10 data mahasiswa...'),
                  )
                else if (snapshot.hasError)
                  ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text('Gagal memuat data mahasiswa'),
                    subtitle: Text('${snapshot.error}'),
                  )
                else if (children.isEmpty)
                  const ListTile(title: Text('Belum ada data untuk filter ini'))
                else ...[
                  for (final item in children)
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(item.nama),
                      subtitle: Text(
                        '${item.nim} - ${item.status.label}\n'
                        '${scopeLabel(item.prodiId)}',
                      ),
                      isThreeLine: true,
                    ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Halaman ${page + 1} - ${children.length} dari maks. $pageSize data',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Halaman sebelumnya',
                          onPressed: result?.hasPrevious == true
                              ? onPrevious
                              : null,
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        IconButton(
                          tooltip: 'Halaman berikutnya',
                          onPressed: result?.hasNext == true ? onNext : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
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

  double get healthScore =>
      (krsDisetujui * 0.34) +
      (presensiMahasiswa * 0.36) +
      (presensiDosen * 0.30);

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
  final prodiIds = service
      .prodiByFakultasId(fakultasId)
      .map((item) => item.id)
      .toSet();
  final mahasiswaIds = service
      .mahasiswaByProdiIds(prodiIds)
      .map((item) => item.nim)
      .toSet();
  final dosenIds = service
      .dosenByProdiIds(prodiIds)
      .map((item) => item.nidn)
      .toSet();
  final mkIds = service
      .mataKuliahByProdiIds(prodiIds)
      .map((item) => item.kode)
      .toSet();
  final kelas = service
      .kelasByTahunAjaran(tahunAjaranId)
      .where((item) => mkIds.contains(item.mataKuliahId))
      .toList();
  final kelasIds = kelas.map((item) => item.id).toSet();
  final krs = service
      .krsByKelasIds(kelasIds)
      .where((item) => mahasiswaIds.contains(item.mahasiswaId))
      .toList();
  final pertemuan = service.pertemuanByKelasIds(kelasIds);
  final pertemuanIds = pertemuan.map((item) => item.id).toSet();
  final presensi = service.presensiByPertemuanIds(pertemuanIds);
  final presensiDosen = service
      .presensiDosenByPertemuanIds(pertemuanIds)
      .where((item) => dosenIds.contains(item.dosenId))
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
    final sorted = metrics.toList()
      ..sort((a, b) => b.healthScore.compareTo(a.healthScore));
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.insights_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Perbandingan Antar Fakultas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
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
                  children: sorted
                      .take(3)
                      .map(
                        (item) => SizedBox(
                          width: width,
                          child: _RektorFacultyPulse(metric: item),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primaryContainer,
                ),
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
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
                rows: sorted
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
                          DataCell(
                            Chip(
                              avatar: Icon(
                                item.status == 'Baik'
                                    ? Icons.check_circle_outline
                                    : item.status == 'Kritis'
                                    ? Icons.warning_amber_outlined
                                    : Icons.info_outline,
                                size: 18,
                              ),
                              label: Text(item.status),
                            ),
                          ),
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

class _RektorFacultyPulse extends StatelessWidget {
  const _RektorFacultyPulse({required this.metric});
  final _FakultasMetric metric;

  @override
  Widget build(BuildContext context) {
    final color = _dashboardScoreColor(metric.healthScore);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Chip(
                label: Text(
                  '${(metric.healthScore * 100).toStringAsFixed(0)}%',
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RektorSignalBar(label: 'KRS', value: metric.krsDisetujui),
          _RektorSignalBar(
            label: 'Presensi Mhs',
            value: metric.presensiMahasiswa,
          ),
          _RektorSignalBar(
            label: 'Presensi Dosen',
            value: metric.presensiDosen,
          ),
        ],
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
    color: Theme.of(context).colorScheme.surface,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.notification_important_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Peringatan Akademik Universitas',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 900
                  ? (constraints.maxWidth - 30) / 4
                  : constraints.maxWidth >= 560
                  ? (constraints.maxWidth - 10) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _RektorAlertCard(
                    icon: Icons.assignment_late_outlined,
                    label: 'Belum KRS',
                    value: belumKrs,
                    width: width,
                  ),
                  _RektorAlertCard(
                    icon: Icons.pending_actions_outlined,
                    label: 'Menunggu Validasi',
                    value: menungguValidasi,
                    width: width,
                  ),
                  _RektorAlertCard(
                    icon: Icons.meeting_room_outlined,
                    label: 'Ruangan Kosong',
                    value: ruanganKosong,
                    width: width,
                  ),
                  _RektorAlertCard(
                    icon: Icons.groups_outlined,
                    label: 'Kelas Penuh',
                    value: kelasPenuh,
                    width: width,
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

class _RektorAlertCard extends StatelessWidget {
  const _RektorAlertCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.width,
  });

  final IconData icon;
  final String label;
  final int value;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color = value == 0 ? Colors.green : Colors.orange;
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
