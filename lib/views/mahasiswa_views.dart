import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import '../utils/app_assets.dart';
import '../services/pdf_service.dart';
import '../utils/app_helpers.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/krs_viewmodel.dart';
import '../viewmodels/mahasiswa_viewmodel.dart';
import '../viewmodels/nilai_viewmodel.dart';
import '../widgets/animated_entrance.dart';
import '../widgets/app_scaffold.dart';

class MahasiswaDashboardView extends StatelessWidget {
  const MahasiswaDashboardView({
    required this.user,
    required this.onOpenKrs,
    required this.onOpenJadwal,
    required this.onOpenNilai,
    required this.onOpenKegiatan,
    super.key,
  });

  final User user;
  final VoidCallback onOpenKrs;
  final VoidCallback onOpenJadwal;
  final VoidCallback onOpenNilai;
  final VoidCallback onOpenKegiatan;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final themeVm = context.watch<ThemeViewModel>();
    final mahasiswa = service.mahasiswa.firstWhere(
      (item) => item.nim == user.scopeId,
    );
    final prodi = service.prodi.firstWhere(
      (item) => item.id == mahasiswa.prodiId,
    );
    final fakultas = service.fakultas.firstWhere(
      (item) => item.id == prodi.fakultasId,
    );
    final krs = service.krs
        .where((item) => item.mahasiswaId == user.scopeId)
        .toList();
    final kelasDiambil = [
      for (final item in krs)
        service.kelas.firstWhere((kelas) => kelas.id == item.kelasId),
    ];
    final nilai = service.nilai
        .where((item) => item.mahasiswaId == user.scopeId)
        .toList();
    final ipkTrend = _buildIpkTrend(nilai, service);
    final tugas =
        service.tugas
            .where(
              (item) => kelasDiambil.any((kelas) => kelas.id == item.kelasId),
            )
            .toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));

    final totalSks = kelasDiambil.fold<int>(0, (sum, kelas) {
      final mk = service.mataKuliah.firstWhere(
        (item) => item.kode == kelas.mataKuliahId,
      );
      return sum + mk.sks;
    });
    final rataNilai = nilai.isEmpty
        ? 0.0
        : nilai.fold<double>(0, (sum, item) => sum + item.nilaiAngka) /
              nilai.length;
    final ipk = nilai.isEmpty
        ? 0.0
        : nilai.fold<double>(0, (sum, item) {
                return sum + _gradePoint(item.nilaiHuruf);
              }) /
              nilai.length;
    final kelasTersedia = service.kelas.where((kelas) {
      final mk = service.mataKuliah.firstWhere(
        (item) => item.kode == kelas.mataKuliahId,
      );
      final sudahDiambil = krs.any((item) => item.kelasId == kelas.id);
      return mk.prodiId == mahasiswa.prodiId &&
          !sudahDiambil &&
          !service.isKelasPenuh(kelas.id);
    }).length;

    final jadwalHariIni = _todayClasses(kelasDiambil);
    final nextClass = jadwalHariIni.isNotEmpty
        ? jadwalHariIni.first
        : (kelasDiambil.isNotEmpty ? kelasDiambil.first : null);
    final presensiMahasiswa = service.presensi
        .where((item) => item.mahasiswaId == user.scopeId)
        .toList();
    final hadir = presensiMahasiswa
        .where((item) => item.statusKehadiran.toLowerCase() == 'hadir')
        .length;
    final presensiLabel = presensiMahasiswa.isEmpty
        ? '-'
        : '${((hadir / presensiMahasiswa.length) * 100).toStringAsFixed(0)}%';

    return AppScaffold(
      title: 'Dashboard',
      actions: [
        IconButton(
          onPressed: () => themeVm.toggleTheme(),
          icon: Icon(
            themeVm.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
          tooltip: 'Toggle Theme',
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StudentHeroCard(
            name: user.name,
            nim: mahasiswa.nim,
            prodi: prodi.nama,
            fakultas: fakultas.nama,
            nextClass: nextClass == null
                ? null
                : _ClassSummary(
                    title: service.getMataKuliahName(nextClass.mataKuliahId),
                    time: '${nextClass.hari}, ${nextClass.jam}',
                    room: service.getRuanganName(nextClass.ruangan),
                  ),
          ),
          const SizedBox(height: 16),
          const _DashboardImageBanner(
            imagePath: AppAssets.graduation,
            icon: Icons.workspace_premium_rounded,
            title: 'Target akademik tetap terlihat',
            subtitle:
                'Pantau KRS, jadwal, nilai, dan kegiatan dari satu dashboard.',
          ),
          const SizedBox(height: 16),
          _ResponsiveStatsGrid(
            stats: [
              _DashboardStat(
                icon: Icons.menu_book_rounded,
                label: 'SKS Diambil',
                value: '$totalSks',
                helper: '${krs.length} kelas aktif',
              ),
              _DashboardStat(
                icon: Icons.grade_rounded,
                label: 'IPK Sementara',
                value: nilai.isEmpty ? '-' : ipk.toStringAsFixed(2),
                helper: nilai.isEmpty
                    ? 'Belum ada nilai'
                    : 'Rata-rata ${rataNilai.toStringAsFixed(0)}',
              ),
              _DashboardStat(
                icon: Icons.task_alt_rounded,
                label: 'Tugas Aktif',
                value: '${tugas.length}',
                helper: tugas.isEmpty
                    ? 'Tidak ada tugas'
                    : _deadlineText(tugas.first.deadline),
              ),
              _DashboardStat(
                icon: Icons.fact_check_rounded,
                label: 'Presensi',
                value: presensiLabel,
                helper: presensiMahasiswa.isEmpty
                    ? 'Belum terekam'
                    : '$hadir/${presensiMahasiswa.length} hadir',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _QuickActionGrid(
            actions: [
              _DashboardQuickAction(
                icon: Icons.playlist_add_check_rounded,
                title: 'Kelola KRS',
                subtitle: kelasTersedia == 0
                    ? 'Lihat kelas yang sudah diambil'
                    : '$kelasTersedia kelas masih tersedia',
                onTap: onOpenKrs,
              ),
              _DashboardQuickAction(
                icon: Icons.calendar_month_rounded,
                title: 'Jadwal',
                subtitle: jadwalHariIni.isEmpty
                    ? 'Tidak ada kelas hari ini'
                    : '${jadwalHariIni.length} kelas hari ini',
                onTap: onOpenJadwal,
              ),
              _DashboardQuickAction(
                icon: Icons.bar_chart_rounded,
                title: 'Nilai',
                subtitle: nilai.isEmpty
                    ? 'Belum ada nilai masuk'
                    : '${nilai.length} nilai tersedia',
                onTap: onOpenNilai,
              ),
              _DashboardQuickAction(
                icon: Icons.work_rounded,
                title: 'Kegiatan',
                subtitle: 'Skripsi, magang, KKN',
                onTap: onOpenKegiatan,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DashboardSection(
            title: 'Agenda Hari Ini',
            actionLabel: 'Lihat Jadwal',
            onAction: onOpenJadwal,
            child: jadwalHariIni.isEmpty
                ? const _EmptyState(
                    icon: Icons.event_available_rounded,
                    title: 'Tidak ada kelas hari ini',
                    subtitle:
                        'Waktu kosong bisa dipakai untuk tugas atau belajar mandiri.',
                  )
                : Column(
                    children: [
                      for (final kelas in jadwalHariIni)
                        _ScheduleRow(
                          title: service.getMataKuliahName(kelas.mataKuliahId),
                          lecturer: service.getDosenPengajarNames(kelas.id),
                          time: kelas.jam,
                          room: service.getRuanganName(kelas.ruangan),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _DashboardSection(
            title: 'Tugas Terdekat',
            child: tugas.isEmpty
                ? const _EmptyState(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Belum ada tugas aktif',
                    subtitle:
                        'Semua tugas dari kelas yang diambil akan muncul di sini.',
                  )
                : Column(
                    children: [
                      for (final item in tugas.take(3))
                        _AssignmentRow(
                          title: item.judul,
                          course: service.getMataKuliahName(
                            service.kelas
                                .firstWhere((kelas) => kelas.id == item.kelasId)
                                .mataKuliahId,
                          ),
                          deadline: item.deadline,
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _DashboardSection(
            title: 'Grafik Progres IPK',
            actionLabel: 'Detail Nilai',
            onAction: onOpenNilai,
            child: _IpkProgressChart(points: ipkTrend),
          ),
          const SizedBox(height: 16),
          _DashboardSection(
            title: 'Performa Akademik',
            actionLabel: 'Detail Nilai',
            onAction: onOpenNilai,
            child: nilai.isEmpty
                ? const _EmptyState(
                    icon: Icons.insights_rounded,
                    title: 'Nilai belum tersedia',
                    subtitle:
                        'Nilai yang sudah diproses dosen akan dirangkum otomatis.',
                  )
                : Column(
                    children: [
                      for (final item in nilai.take(3))
                        _GradeRow(
                          title: service.getMataKuliahName(
                            service.kelas
                                .firstWhere((kelas) => kelas.id == item.kelasId)
                                .mataKuliahId,
                          ),
                          score: item.nilaiAngka,
                          grade: item.nilaiHuruf,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static List<Kelas> _todayClasses(List<Kelas> kelas) {
    final today = _hariFromWeekday(DateTime.now().weekday);
    return kelas
        .where((item) => item.hari.toLowerCase() == today.toLowerCase())
        .toList();
  }

  static String _hariFromWeekday(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Senin',
      DateTime.tuesday => 'Selasa',
      DateTime.wednesday => 'Rabu',
      DateTime.thursday => 'Kamis',
      DateTime.friday => 'Jumat',
      DateTime.saturday => 'Sabtu',
      _ => 'Minggu',
    };
  }

  static double _gradePoint(String grade) {
    return switch (grade) {
      'A' => 4,
      'B+' => 3.5,
      'B' => 3,
      'C' => 2,
      'D' => 1,
      _ => 0,
    };
  }

  static List<_IpkPoint> _buildIpkTrend(
    List<Nilai> nilai,
    MockService service,
  ) {
    final points = <_IpkPoint>[];
    for (int semester = 1; semester <= 15; semester++) {
      final semesterNilai = nilai
          .where((item) => item.semester == semester)
          .toList();
      if (semesterNilai.isEmpty) continue;

      double totalBobot = 0;
      int totalSks = 0;
      for (final item in semesterNilai) {
        final kelas = service.kelas.firstWhere(
          (kelas) => kelas.id == item.kelasId,
        );
        final mk = service.mataKuliah.firstWhere(
          (mk) => mk.kode == kelas.mataKuliahId,
        );
        totalBobot += _gradePoint(item.nilaiHuruf) * mk.sks;
        totalSks += mk.sks;
      }
      if (totalSks > 0) {
        points.add(_IpkPoint(semester: semester, ipk: totalBobot / totalSks));
      }
    }
    return points;
  }

  static String _deadlineText(DateTime deadline) {
    final days = deadline.difference(DateTime.now()).inDays;
    if (days < 0) return 'Terlambat ${days.abs()} hari';
    if (days == 0) return 'Deadline hari ini';
    return 'Terdekat $days hari';
  }
}

class _DashboardImageBanner extends StatelessWidget {
  const _DashboardImageBanner({
    required this.imagePath,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String imagePath;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 5.5,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
              cacheWidth: 1200,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.72),
                    Colors.black.withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF0B57D0)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentHeroCard extends StatelessWidget {
  const _StudentHeroCard({
    required this.name,
    required this.nim,
    required this.prodi,
    required this.fakultas,
    required this.nextClass,
  });

  final String name;
  final String nim;
  final String prodi;
  final String fakultas;
  final _ClassSummary? nextClass;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedEntrance(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.studentStudy,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                filterQuality: FilterQuality.medium,
                cacheWidth: 1200,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary.withValues(alpha: 0.94),
                      const Color(0xFF0D47A1).withValues(alpha: 0.82),
                      Colors.black.withValues(alpha: 0.46),
                    ],
                    stops: const [0, 0.58, 1],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 640;
                  final profile = Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        child: Text(
                          name.substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$nim - $prodi',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              fakultas,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  final next = _NextClassPanel(nextClass: nextClass);
                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: profile),
                            const SizedBox(width: 18),
                            SizedBox(width: 290, child: next),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [profile, const SizedBox(height: 18), next],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextClassPanel extends StatelessWidget {
  const _NextClassPanel({required this.nextClass});

  final _ClassSummary? nextClass;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: nextClass == null
                ? Text(
                    'Belum ada jadwal aktif',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextClass!.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${nextClass!.time} - ${nextClass!.room}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.76),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveStatsGrid extends StatelessWidget {
  const _ResponsiveStatsGrid({required this.stats});

  final List<_DashboardStat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 760 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth >= 760 ? 1.42 : 1.08,
          ),
          itemBuilder: (context, index) => AnimatedEntrance(
            delay: Duration(milliseconds: index * 70),
            child: _StatCard(stat: stats[index]),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(stat.icon, color: scheme.primary, size: 21),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.helper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.actions});

  final List<_DashboardQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth >= 760 ? 3 : 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth >= 760 ? 2.7 : 3.9,
          ),
          itemBuilder: (context, index) =>
              _QuickActionCard(action: actions[index]),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final _DashboardQuickAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 3,
      shadowColor: scheme.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(action.icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      action.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.58),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedEntrance(
      child: Card(
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (actionLabel != null && onAction != null)
                    TextButton(
                      onPressed: onAction,
                      child: Text(
                        actionLabel!,
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.title,
    required this.lecturer,
    required this.time,
    required this.room,
  });

  final String title;
  final String lecturer;
  final String time;
  final String room;

  @override
  Widget build(BuildContext context) {
    return _DashboardInfoRow(
      icon: Icons.schedule_rounded,
      title: title,
      subtitle: '$lecturer - $room',
      trailing: time,
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  const _AssignmentRow({
    required this.title,
    required this.course,
    required this.deadline,
  });

  final String title;
  final String course;
  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    return _DashboardInfoRow(
      icon: Icons.assignment_outlined,
      title: title,
      subtitle: course,
      trailing: MahasiswaDashboardView._deadlineText(deadline),
      isWarning: deadline.difference(DateTime.now()).inDays <= 3,
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({
    required this.title,
    required this.score,
    required this.grade,
  });

  final String title;
  final double score;
  final String grade;

  @override
  Widget build(BuildContext context) {
    return _DashboardInfoRow(
      icon: Icons.bar_chart_rounded,
      title: title,
      subtitle: 'Nilai angka ${score.toStringAsFixed(0)}',
      trailing: grade,
    );
  }
}

class _IpkProgressChart extends StatelessWidget {
  const _IpkProgressChart({required this.points});

  final List<_IpkPoint> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 230,
          child: points.isEmpty
              ? const _EmptyState(
                  icon: Icons.show_chart_rounded,
                  title: 'Grafik IPK belum tersedia',
                  subtitle:
                      'Grafik akan terbentuk setelah nilai semester masuk.',
                )
              : CustomPaint(
                  painter: _IpkProgressPainter(
                    points: points,
                    primary: scheme.primary,
                    onSurface: scheme.onSurface,
                    surface: scheme.surface,
                  ),
                  child: const SizedBox.expand(),
                ),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _ChartLegend(color: Color(0xFF2E7D32), label: 'Semester 1-8 aman'),
            _ChartLegend(
              color: Color(0xFFF9A825),
              label: 'Semester 9-14 peringatan',
            ),
            _ChartLegend(
              color: Color(0xFFC62828),
              label: 'Semester 14+ dropout',
            ),
          ],
        ),
      ],
    );
  }
}

class _IpkProgressPainter extends CustomPainter {
  const _IpkProgressPainter({
    required this.points,
    required this.primary,
    required this.onSurface,
    required this.surface,
  });

  final List<_IpkPoint> points;
  final Color primary;
  final Color onSurface;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 38.0;
    const right = 14.0;
    const top = 14.0;
    const bottom = 34.0;
    final chart = Rect.fromLTWH(
      left,
      top,
      size.width - left - right,
      size.height - top - bottom,
    );

    final safePaint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.10);
    final warningPaint = Paint()
      ..color = const Color(0xFFF9A825).withValues(alpha: 0.14);
    final dropoutPaint = Paint()
      ..color = const Color(0xFFC62828).withValues(alpha: 0.12);

    double xForSemester(double semester) {
      return chart.left + ((semester - 1) / 14) * chart.width;
    }

    canvas.drawRect(
      Rect.fromLTRB(
        xForSemester(1),
        chart.top,
        xForSemester(8.5),
        chart.bottom,
      ),
      safePaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        xForSemester(8.5),
        chart.top,
        xForSemester(14),
        chart.bottom,
      ),
      warningPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        xForSemester(14),
        chart.top,
        xForSemester(15),
        chart.bottom,
      ),
      dropoutPaint,
    );

    final axisPaint = Paint()
      ..color = onSurface.withValues(alpha: 0.20)
      ..strokeWidth = 1;
    final gridPaint = Paint()
      ..color = onSurface.withValues(alpha: 0.09)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = chart.bottom - (i / 4) * chart.height;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      _drawText(
        canvas,
        (i.toDouble()).toStringAsFixed(0),
        Offset(6, y - 8),
        color: onSurface.withValues(alpha: 0.55),
        size: 10,
      );
    }

    for (final semester in [1, 4, 8, 9, 13, 14, 15]) {
      final x = xForSemester(semester.toDouble());
      canvas.drawLine(
        Offset(x, chart.bottom),
        Offset(x, chart.bottom + 4),
        axisPaint,
      );
      _drawText(
        canvas,
        '$semester',
        Offset(x - 5, chart.bottom + 9),
        color: onSurface.withValues(alpha: 0.55),
        size: 10,
      );
    }

    canvas.drawLine(
      Offset(chart.left, chart.top),
      Offset(chart.left, chart.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chart.left, chart.bottom),
      Offset(chart.right, chart.bottom),
      axisPaint,
    );

    if (points.isEmpty) return;

    Offset pointFor(_IpkPoint point) {
      final x = xForSemester(point.semester.toDouble());
      final clamped = point.ipk.clamp(0, 4);
      final y = chart.bottom - (clamped / 4) * chart.height;
      return Offset(x, y);
    }

    final linePaint = Paint()
      ..color = primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = primary.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < points.length; i++) {
      final point = pointFor(points[i]);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
        fillPath.moveTo(point.dx, chart.bottom);
        fillPath.lineTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
        fillPath.lineTo(point.dx, point.dy);
      }
    }
    fillPath.lineTo(pointFor(points.last).dx, chart.bottom);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    for (final item in points) {
      final point = pointFor(item);
      canvas.drawCircle(point, 5.5, Paint()..color = surface);
      canvas.drawCircle(point, 4, Paint()..color = primary);
      _drawText(
        canvas,
        item.ipk.toStringAsFixed(2),
        Offset(point.dx - 16, point.dy - 24),
        color: primary,
        size: 10,
        weight: FontWeight.w800,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    double size = 11,
    FontWeight weight = FontWeight.w600,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _IpkProgressPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.primary != primary ||
        oldDelegate.onSurface != onSurface ||
        oldDelegate.surface != surface;
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.64),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _IpkPoint {
  const _IpkPoint({required this.semester, required this.ipk});

  final int semester;
  final double ipk;
}

class _DashboardInfoRow extends StatelessWidget {
  const _DashboardInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.isWarning = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isWarning ? Colors.red : scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            trailing,
            textAlign: TextAlign.right,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStat {
  const _DashboardStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.helper,
  });

  final IconData icon;
  final String label;
  final String value;
  final String helper;
}

class _DashboardQuickAction {
  const _DashboardQuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _ClassSummary {
  const _ClassSummary({
    required this.title,
    required this.time,
    required this.room,
  });

  final String title;
  final String time;
  final String room;
}

class MahasiswaKrsView extends StatefulWidget {
  const MahasiswaKrsView({required this.mahasiswaId, super.key});

  final String mahasiswaId;

  @override
  State<MahasiswaKrsView> createState() => _MahasiswaKrsViewState();
}

class _MahasiswaKrsViewState extends State<MahasiswaKrsView> {
  int? _selectedSemester;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final krsVm = context.watch<KRSViewModel>();
    final mahasiswa = service.mahasiswa.firstWhere(
      (item) => item.nim == widget.mahasiswaId,
    );
    final allKrs = krsVm.items(mahasiswaId: widget.mahasiswaId);
    final semesterOptions = {
      mahasiswa.semester,
      ...allKrs.map((item) => item.semester),
    }.toList()..sort();
    final selectedSemester = _selectedSemester ?? mahasiswa.semester;
    final isCurrentSemester = selectedSemester == mahasiswa.semester;
    final selectedKrs = allKrs
        .where(
          (item) =>
              item.semester == selectedSemester &&
              (!isCurrentSemester ||
                  item.tahunAjaranId == service.tahunAjaranAktif.id),
        )
        .toList();
    final selectedAllSemester = allKrs.map((item) => item.kelasId).toSet();
    final selectedHasKrs = selectedKrs.isNotEmpty;
    final selectedApproved =
        selectedHasKrs && selectedKrs.every((item) => item.isValidated);
    final selectedSubmitted =
        selectedHasKrs &&
        selectedKrs.any((item) => item.isSubmitted && !item.isValidated);
    final selectedRejected =
        selectedHasKrs && selectedKrs.any((item) => item.isRejected);
    final selectedLocked =
        isCurrentSemester &&
        selectedKrs.any((item) => item.isSubmitted || item.isValidated);
    final faseKrs = service.faseKrsTahunAktif;
    final faseKrsBerlangsung = service.isFaseKrsBerlangsung;
    final canSubmit =
        isCurrentSemester &&
        faseKrsBerlangsung &&
        selectedHasKrs &&
        !selectedSubmitted &&
        !selectedApproved;
    final krsStatus = !selectedHasKrs
        ? 'Belum diisi'
        : selectedApproved
        ? 'Disetujui'
        : selectedSubmitted
        ? 'Diajukan'
        : selectedRejected
        ? 'Ditolak'
        : 'Draft';
    final catatanDosenPa = selectedKrs
        .where((item) => item.catatanDosenPa.isNotEmpty)
        .map((item) => item.catatanDosenPa)
        .toSet()
        .join('\n');
    final availableKelas = service.kelas.where((kelas) {
      final mataKuliah = service.mataKuliah.firstWhere(
        (item) => item.kode == kelas.mataKuliahId,
      );
      return mataKuliah.prodiId == mahasiswa.prodiId &&
          kelas.tahunAjaranId == service.tahunAjaranAktif.id;
    }).toList();
    final visibleKelas = isCurrentSemester
        ? availableKelas
        : [
            for (final item in selectedKrs)
              service.kelas.firstWhere((kelas) => kelas.id == item.kelasId),
          ];

    return AppScaffold(
      title: 'KRS',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            await PdfService.printKRS(
              context: context,
              mahasiswaId: widget.mahasiswaId,
              service: service,
              semester: selectedSemester,
            );
          } catch (e) {
            if (context.mounted) {
              showAppMessage(context, 'Gagal membuat PDF: $e');
            }
          }
        },
        label: const Text('Cetak KRS'),
        icon: const Icon(Icons.print_rounded),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                faseKrsBerlangsung
                    ? Icons.event_available_outlined
                    : Icons.event_busy_outlined,
                color: faseKrsBerlangsung
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              title: Text(
                faseKrsBerlangsung
                    ? 'Fase KRS Sedang Berlangsung'
                    : 'Pengisian KRS Tidak Aktif',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                faseKrs == null
                    ? 'Admin Universitas belum membuka fase KRS.'
                    : 'Status: ${faseKrs.statusPada(DateTime.now())}\n'
                          'Periode: ${_formatKrsDate(faseKrs.mulai)} sampai ${_formatKrsDate(faseKrs.berakhir)}',
              ),
              isThreeLine: faseKrs != null,
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCurrentSemester ? 'KRS Aktif' : 'History KRS',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCurrentSemester
                              ? 'Semester berjalan: ${mahasiswa.semester}'
                              : 'Riwayat semester $selectedSemester',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.58),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: $krsStatus - Dosen PA: ${service.getDosenName(mahasiswa.pembimbingAkademikId)}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        if (catatanDosenPa.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Catatan Dosen PA: $catatanDosenPa',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedSemester,
                          decoration: const InputDecoration(
                            labelText: 'Semester',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: [
                            for (final semester in semesterOptions)
                              DropdownMenuItem(
                                value: semester,
                                child: Text('Semester $semester'),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedSemester = value);
                          },
                        ),
                      ),
                      if (isCurrentSemester) ...[
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: canSubmit
                              ? () {
                                  krsVm.submit(
                                    widget.mahasiswaId,
                                    selectedSemester,
                                  );
                                  showAppMessage(context, krsVm.message);
                                }
                              : null,
                          icon: const Icon(Icons.send_rounded),
                          label: Text(
                            selectedApproved
                                ? 'Disetujui'
                                : selectedSubmitted
                                ? 'Diajukan'
                                : 'Ajukan KRS',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (visibleKelas.isEmpty)
            const _EmptyState(
              icon: Icons.history_edu_rounded,
              title: 'Belum ada data KRS',
              subtitle: 'History KRS semester ini belum tersedia.',
            )
          else
            for (int i = 0; i < visibleKelas.length; i++)
              AnimatedEntrance(
                delay: Duration(milliseconds: i * 80),
                child: Builder(
                  builder: (context) {
                    final kelas = visibleKelas[i];
                    final jumlahPeserta = service.getJumlahPesertaKelas(
                      kelas.id,
                    );
                    final isSelected = selectedAllSemester.contains(kelas.id);
                    final isFull = service.isKelasPenuh(kelas.id);
                    final krsSemester = allKrs
                        .where((item) => item.kelasId == kelas.id)
                        .map((item) => item.semester)
                        .join(', ');
                    final krsMatches = selectedKrs.where(
                      (item) => item.kelasId == kelas.id,
                    );
                    final krsStatus = krsMatches.isEmpty
                        ? ''
                        : krsMatches.first.statusLabel;
                    final canRemove =
                        isCurrentSemester &&
                        faseKrsBerlangsung &&
                        krsMatches.isNotEmpty &&
                        !krsMatches.first.isSubmitted &&
                        !krsMatches.first.isValidated;

                    return InfoTile(
                      icon: isSelected
                          ? Icons.check_circle
                          : (isFull
                                ? Icons.block_outlined
                                : Icons.playlist_add_check),
                      title: service.getMataKuliahName(kelas.mataKuliahId),
                      subtitle:
                          '${kelas.id}\nDosen: ${service.getDosenPengajarNames(kelas.id)}\n${kelas.hari}, ${kelas.jam} - ${service.getRuanganName(kelas.ruangan)}\nKapasitas: $jumlahPeserta/${kelas.kapasitas}${isSelected ? '\nDiambil pada semester $krsSemester${krsStatus.isEmpty ? '' : ' - $krsStatus'}${krsMatches.isNotEmpty && krsMatches.first.catatanDosenPa.isNotEmpty ? '\nCatatan: ${krsMatches.first.catatanDosenPa}' : ''}' : ''}',
                      trailing: !isCurrentSemester
                          ? const Text(
                              'History',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            )
                          : isSelected
                          ? canRemove
                                ? OutlinedButton(
                                    onPressed: () {
                                      krsVm.remove(
                                        krsMatches.first.id,
                                        widget.mahasiswaId,
                                      );
                                      showAppMessage(context, krsVm.message);
                                    },
                                    child: const Text('Hapus'),
                                  )
                                : Text(
                                    krsStatus.isEmpty ? 'Diambil' : krsStatus,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                          : FilledButton(
                              onPressed:
                                  isFull ||
                                      selectedLocked ||
                                      !faseKrsBerlangsung
                                  ? null
                                  : () {
                                      krsVm.take(widget.mahasiswaId, kelas.id);
                                      showAppMessage(context, krsVm.message);
                                    },
                              child: Text(
                                !faseKrsBerlangsung
                                    ? 'KRS Ditutup'
                                    : selectedLocked
                                    ? 'Terkunci'
                                    : isFull
                                    ? 'Penuh'
                                    : 'Ambil',
                              ),
                            ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

String _formatKrsDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year} '
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

class MahasiswaJadwalView extends StatefulWidget {
  const MahasiswaJadwalView({required this.mahasiswaId, super.key});

  final String mahasiswaId;

  @override
  State<MahasiswaJadwalView> createState() => _MahasiswaJadwalViewState();
}

class _MahasiswaJadwalViewState extends State<MahasiswaJadwalView> {
  String _selectedHari = 'Senin';
  final List<String> _hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final krs = context.watch<KRSViewModel>().items(
      mahasiswaId: widget.mahasiswaId,
    );

    // Jadwal dibentuk dari KRS mahasiswa, lalu difilter berdasarkan hari.
    final jadwalHariIni = krs.where((item) {
      final kelas = service.kelas.firstWhere((k) => k.id == item.kelasId);
      return kelas.hari.toLowerCase() == _selectedHari.toLowerCase();
    }).toList();

    return AppScaffold(
      title: 'Jadwal Kuliah',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _hariList.map((hari) {
                final isSelected = _selectedHari == hari;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
                  child: FilterChip(
                    label: Text(hari),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedHari = hari);
                      }
                    },
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    side: isSelected
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          if (jadwalHariIni.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Tidak ada jadwal untuk hari ini')),
            )
          else
            for (int i = 0; i < jadwalHariIni.length; i++)
              AnimatedEntrance(
                delay: Duration(milliseconds: i * 100),
                child: Builder(
                  builder: (context) {
                    final item = jadwalHariIni[i];
                    final kelas = service.kelas.firstWhere(
                      (kelas) => kelas.id == item.kelasId,
                    );
                    return InfoTile(
                      icon: Icons.schedule_rounded,
                      title: service.getMataKuliahName(kelas.mataKuliahId),
                      subtitle:
                          '${kelas.jam}\n${service.getRuanganName(kelas.ruangan)} - ${service.getDosenPengajarNames(kelas.id)}',
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class MahasiswaNilaiView extends StatefulWidget {
  const MahasiswaNilaiView({required this.mahasiswaId, super.key});

  final String mahasiswaId;

  @override
  State<MahasiswaNilaiView> createState() => _MahasiswaNilaiViewState();
}

class _MahasiswaNilaiViewState extends State<MahasiswaNilaiView> {
  int? _selectedSemester;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final nilai = context.watch<NilaiViewModel>().items(
      mahasiswaId: widget.mahasiswaId,
    )..sort((a, b) => a.semester.compareTo(b.semester));
    final semesters = nilai.map((item) => item.semester).toSet().toList()
      ..sort();
    final selectedSemester =
        _selectedSemester ?? (semesters.isEmpty ? null : semesters.last);
    final filteredNilai = selectedSemester == null
        ? <Nilai>[]
        : nilai.where((item) => item.semester == selectedSemester).toList();
    final totalFinal = filteredNilai.isEmpty
        ? 0.0
        : filteredNilai.fold<double>(0, (sum, item) => sum + item.finalBobot) /
              filteredNilai.length;

    return AppScaffold(
      title: 'Nilai',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            await PdfService.printKHS(
              context: context,
              mahasiswaId: widget.mahasiswaId,
              service: service,
              semester: selectedSemester,
            );
          } catch (e) {
            if (context.mounted) {
              showAppMessage(context, 'Gagal membuat PDF: $e');
            }
          }
        },
        label: const Text('Cetak KHS'),
        icon: const Icon(Icons.print_rounded),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Cek Nilai Semester',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedSemester,
                          decoration: const InputDecoration(
                            labelText: 'Semester',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: [
                            for (final semester in semesters)
                              DropdownMenuItem(
                                value: semester,
                                child: Text('Semester $semester'),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedSemester = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _NilaiSummaryBar(
                    totalMatkul: filteredNilai.length,
                    finalBobot: totalFinal,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (filteredNilai.isEmpty)
            const _EmptyState(
              icon: Icons.bar_chart_rounded,
              title: 'Nilai semester ini belum tersedia',
              subtitle:
                  'Pilih semester lain atau cek kembali setelah dosen input nilai.',
            )
          else
            for (int i = 0; i < filteredNilai.length; i++)
              AnimatedEntrance(
                delay: Duration(milliseconds: i * 100),
                child: Builder(
                  builder: (context) {
                    final item = filteredNilai[i];
                    final kelas = service.kelas.firstWhere(
                      (kelas) => kelas.id == item.kelasId,
                    );
                    final mk = service.mataKuliah.firstWhere(
                      (mk) => mk.kode == kelas.mataKuliahId,
                    );
                    return _DetailedGradeCard(
                      course: mk.nama,
                      sks: mk.sks,
                      lecturer: service.getDosenPengajarNames(kelas.id),
                      nilai: item,
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class _NilaiSummaryBar extends StatelessWidget {
  const _NilaiSummaryBar({required this.totalMatkul, required this.finalBobot});

  final int totalMatkul;
  final double finalBobot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SmallSummaryItem(
              label: 'Mata Kuliah',
              value: '$totalMatkul',
            ),
          ),
          Expanded(
            child: _SmallSummaryItem(
              label: 'Rata-rata Final',
              value: totalMatkul == 0 ? '-' : finalBobot.toStringAsFixed(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallSummaryItem extends StatelessWidget {
  const _SmallSummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DetailedGradeCard extends StatelessWidget {
  const _DetailedGradeCard({
    required this.course,
    required this.sks,
    required this.lecturer,
    required this.nilai,
  });

  final String course;
  final int sks;
  final String lecturer;
  final Nilai nilai;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        course,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$lecturer - $sks SKS',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.58),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        nilai.nilaiHuruf,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        nilai.finalBobot.toStringAsFixed(1),
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.62),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _GradeComponentRow(
              label: 'Tugas',
              score: nilai.nilaiTugas,
              weight: nilai.bobotTugas,
              weighted: nilai.subBobotTugas,
            ),
            _GradeComponentRow(
              label: 'UTS',
              score: nilai.nilaiUts,
              weight: nilai.bobotUts,
              weighted: nilai.subBobotUts,
            ),
            _GradeComponentRow(
              label: 'UAS',
              score: nilai.nilaiUas,
              weight: nilai.bobotUas,
              weighted: nilai.subBobotUas,
            ),
            _GradeComponentRow(
              label: 'Softskill',
              score: nilai.nilaiSoftskill,
              weight: nilai.bobotSoftskill,
              weighted: nilai.subBobotSoftskill,
            ),
            const Divider(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Final Bobot',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  '${nilai.totalBobot.toStringAsFixed(0)}% -> ${nilai.finalBobot.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w900,
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

class _GradeComponentRow extends StatelessWidget {
  const _GradeComponentRow({
    required this.label,
    required this.score,
    required this.weight,
    required this.weighted,
  });

  final String label;
  final double score;
  final double weight;
  final double weighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              score.toStringAsFixed(0),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.68),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${weight.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.68),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              weighted.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MahasiswaKegiatanView extends StatefulWidget {
  const MahasiswaKegiatanView({required this.mahasiswaId, super.key});

  final String mahasiswaId;

  @override
  State<MahasiswaKegiatanView> createState() => _MahasiswaKegiatanViewState();
}

class _MahasiswaKegiatanViewState extends State<MahasiswaKegiatanView> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final mahasiswa = service.mahasiswa.firstWhere(
      (item) => item.nim == widget.mahasiswaId,
    );
    final skripsi = service.skripsi
        .where((item) => item.mahasiswaId == widget.mahasiswaId)
        .toList();
    final magang = service.magang
        .where((item) => item.mahasiswaId == widget.mahasiswaId)
        .toList();
    final kkn = service.kkn
        .where((item) => item.mahasiswaId == widget.mahasiswaId)
        .toList();

    return AppScaffold(
      title: 'Kegiatan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KegiatanCard(
            icon: Icons.school_rounded,
            title: 'Skripsi',
            subtitle:
                'Pembimbing: ${service.getDosenName(mahasiswa.pembimbingAkademikId)}',
            status: skripsi.isEmpty
                ? 'Belum dimulai'
                : skripsi.last.status.label,
            detail: skripsi.isEmpty
                ? 'Mulai skripsi dengan mengisi judul dan topik penelitian.'
                : '${skripsi.last.judul}\nTopik: ${skripsi.last.topik}${skripsi.last.catatan.isEmpty ? '' : '\nCatatan: ${skripsi.last.catatan.last}'}',
            actionLabel: skripsi.isEmpty ? 'Mulai Skripsi' : null,
            onAction: skripsi.isEmpty
                ? () => _mulaiSkripsi(context, widget.mahasiswaId)
                : null,
          ),
          _KegiatanCard(
            icon: Icons.business_center_rounded,
            title: 'Magang',
            subtitle: 'Pengajuan praktik kerja lapangan',
            status: magang.isEmpty
                ? 'Belum diajukan'
                : magang.last.status.label,
            detail: magang.isEmpty
                ? 'Ajukan tempat dan posisi magang yang dituju.'
                : '${magang.last.instansi}\nPosisi: ${magang.last.posisi}',
            actionLabel: magang.isEmpty ? 'Ajukan Magang' : null,
            onAction: magang.isEmpty
                ? () => _ajukanMagang(context, widget.mahasiswaId)
                : null,
          ),
          _KegiatanCard(
            icon: Icons.groups_2_rounded,
            title: 'KKN',
            subtitle: 'Kuliah kerja nyata',
            status: kkn.isEmpty ? 'Belum diajukan' : kkn.last.status.label,
            detail: kkn.isEmpty
                ? 'Ajukan lokasi dan tema KKN.'
                : '${kkn.last.lokasi}\nTema: ${kkn.last.tema}',
            actionLabel: kkn.isEmpty ? 'Ajukan KKN' : null,
            onAction: kkn.isEmpty
                ? () => _ajukanKkn(context, widget.mahasiswaId)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _mulaiSkripsi(BuildContext context, String mahasiswaId) async {
    final judulController = TextEditingController();
    final topikController = TextEditingController();
    await _showKegiatanDialog(
      context: context,
      title: 'Mulai Skripsi',
      fields: [
        TextField(
          controller: judulController,
          decoration: const InputDecoration(labelText: 'Judul skripsi'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: topikController,
          decoration: const InputDecoration(labelText: 'Topik penelitian'),
          maxLines: 3,
        ),
      ],
      onSave: () => context.read<MockService>().mulaiSkripsi(
        mahasiswaId: mahasiswaId,
        judul: judulController.text,
        topik: topikController.text,
      ),
    );
    judulController.dispose();
    topikController.dispose();
  }

  Future<void> _ajukanMagang(BuildContext context, String mahasiswaId) async {
    final instansiController = TextEditingController();
    final posisiController = TextEditingController();
    await _showKegiatanDialog(
      context: context,
      title: 'Ajukan Magang',
      fields: [
        TextField(
          controller: instansiController,
          decoration: const InputDecoration(labelText: 'Instansi'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: posisiController,
          decoration: const InputDecoration(labelText: 'Posisi'),
        ),
      ],
      onSave: () => context.read<MockService>().ajukanMagang(
        mahasiswaId: mahasiswaId,
        instansi: instansiController.text,
        posisi: posisiController.text,
      ),
    );
    instansiController.dispose();
    posisiController.dispose();
  }

  Future<void> _ajukanKkn(BuildContext context, String mahasiswaId) async {
    final lokasiController = TextEditingController();
    final temaController = TextEditingController();
    await _showKegiatanDialog(
      context: context,
      title: 'Ajukan KKN',
      fields: [
        TextField(
          controller: lokasiController,
          decoration: const InputDecoration(labelText: 'Lokasi'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: temaController,
          decoration: const InputDecoration(labelText: 'Tema'),
        ),
      ],
      onSave: () => context.read<MockService>().ajukanKkn(
        mahasiswaId: mahasiswaId,
        lokasi: lokasiController.text,
        tema: temaController.text,
      ),
    );
    lokasiController.dispose();
    temaController.dispose();
  }

  Future<void> _showKegiatanDialog({
    required BuildContext context,
    required String title,
    required List<Widget> fields,
    required String Function() onSave,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: fields),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              try {
                final msg = onSave();
                showAppMessage(context, msg);
                Navigator.pop(context);
                setState(() {});
              } catch (e) {
                showAppMessage(context, e.toString());
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _KegiatanCard extends StatelessWidget {
  const _KegiatanCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.detail,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
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
                      Text(subtitle),
                    ],
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(detail),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MahasiswaProfileView extends StatelessWidget {
  const MahasiswaProfileView({
    required this.user,
    required this.onLogout,
    super.key,
  });

  final User user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final mahasiswa = context.watch<MahasiswaViewModel>().byNim(user.scopeId);
    if (mahasiswa == null) {
      return AppScaffold(
        title: 'Profil',
        child: const _EmptyState(
          icon: Icons.person_off_rounded,
          title: 'Profil tidak ditemukan',
          subtitle: 'Data mahasiswa belum tersedia di sistem.',
        ),
      );
    }

    final prodi = service.prodi.firstWhere(
      (item) => item.id == mahasiswa.prodiId,
      orElse: () => const Prodi(id: '', nama: '-', fakultasId: ''),
    );
    final fakultas = service.fakultas.firstWhere(
      (item) => item.id == prodi.fakultasId,
      orElse: () => const Fakultas(id: '', nama: '-'),
    );

    return AppScaffold(
      title: 'Profil',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      mahasiswa.nama.substring(0, 1),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mahasiswa.nama,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${mahasiswa.nim} - Semester ${mahasiswa.semester}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _ProfileSection(
            title: 'Data Akademik',
            children: [
              _ProfileInfoRow(label: 'Nama', value: mahasiswa.nama),
              _ProfileInfoRow(label: 'NIM', value: mahasiswa.nim),
              _ProfileInfoRow(label: 'Program Studi', value: prodi.nama),
              _ProfileInfoRow(label: 'Fakultas', value: fakultas.nama),
              _ProfileInfoRow(
                label: 'Jenis Kelamin',
                value: mahasiswa.jenisKelamin,
              ),
              _ProfileInfoRow(
                label: 'Semester',
                value: '${mahasiswa.semester}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSection(
            title: 'Kontak',
            action: TextButton.icon(
              onPressed: () => _editProfile(context, mahasiswa),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit'),
            ),
            children: [
              _ProfileInfoRow(
                label: 'Email',
                value: mahasiswa.email.isEmpty ? '-' : mahasiswa.email,
              ),
              _ProfileInfoRow(
                label: 'No. HP',
                value: mahasiswa.noHp.isEmpty ? '-' : mahasiswa.noHp,
              ),
              _ProfileInfoRow(
                label: 'Alamat',
                value: mahasiswa.alamat.isEmpty ? '-' : mahasiswa.alamat,
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, Mahasiswa mahasiswa) async {
    final vm = context.read<MahasiswaViewModel>();
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController(text: mahasiswa.email);
    final noHpController = TextEditingController(text: mahasiswa.noHp);
    final alamatController = TextEditingController(text: mahasiswa.alamat);
    var jenisKelamin = mahasiswa.jenisKelamin;
    var semester = mahasiswa.semester;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Profil'),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LockedProfileField(
                          label: 'Nama',
                          value: mahasiswa.nama,
                        ),
                        const SizedBox(height: 12),
                        _LockedProfileField(label: 'NIM', value: mahasiswa.nim),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: jenisKelamin,
                          decoration: const InputDecoration(
                            labelText: 'Jenis Kelamin',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Laki-laki',
                              child: Text('Laki-laki'),
                            ),
                            DropdownMenuItem(
                              value: 'Perempuan',
                              child: Text('Perempuan'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => jenisKelamin = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: semester,
                          decoration: const InputDecoration(
                            labelText: 'Semester',
                          ),
                          items: [
                            for (int i = 1; i <= 14; i++)
                              DropdownMenuItem(
                                value: i,
                                child: Text('Semester $i'),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => semester = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: noHpController,
                          decoration: const InputDecoration(
                            labelText: 'No. HP',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: alamatController,
                          decoration: const InputDecoration(
                            labelText: 'Alamat',
                            prefixIcon: Icon(Icons.home_outlined),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    vm.updateProfile(
                      nim: mahasiswa.nim,
                      jenisKelamin: jenisKelamin,
                      semester: semester,
                      email: emailController.text,
                      noHp: noHpController.text,
                      alamat: alamatController.text,
                    );
                    Navigator.of(dialogContext).pop();
                    showAppMessage(context, vm.message);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    emailController.dispose();
    noHpController.dispose();
    alamatController.dispose();
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.children,
    this.action,
  });

  final String title;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.58),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedProfileField extends StatelessWidget {
  const _LockedProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
      ),
    );
  }
}

class MahasiswaTugasBox extends StatelessWidget {
  const MahasiswaTugasBox({required this.mahasiswaId, super.key});

  final String mahasiswaId;

  @override
  Widget build(BuildContext context) {
    // Tugas mahasiswa berasal dari semua kelas yang sudah masuk KRS.
    final service = context.watch<MockService>();
    final krs = service.krs.where((k) => k.mahasiswaId == mahasiswaId).toList();
    final kelasIds = krs.map((k) => k.kelasId).toSet();
    final tugasList = service.tugas
        .where((t) => kelasIds.contains(t.kelasId))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tugas Kuliah',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        if (tugasList.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Belum ada tugas saat ini \uD83C\uDF89',
                  style: TextStyle(color: Color(0xFF5F6368)),
                ),
              ),
            ),
          )
        else
          for (int i = 0; i < tugasList.length; i++)
            AnimatedEntrance(
              delay: Duration(milliseconds: i * 120),
              child: Builder(
                builder: (context) {
                  final tugas = tugasList[i];
                  final kelas = service.kelas.firstWhere(
                    (k) => k.id == tugas.kelasId,
                  );
                  final mkName = service.getMataKuliahName(kelas.mataKuliahId);

                  final days = tugas.deadline.difference(DateTime.now()).inDays;
                  final isUrgent = days <= 3;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isUrgent
                            ? Colors.red.withValues(alpha: 0.15)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.assignment_outlined,
                          color: isUrgent
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        tugas.judul,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            mkName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tugas.deskripsi,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: isUrgent
                                    ? Colors.red
                                    : const Color(0xFF5F6368),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                days < 0
                                    ? 'Melewati batas waktu'
                                    : 'Tersisa $days hari',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isUrgent
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isUrgent
                                      ? Colors.red
                                      : const Color(0xFF5F6368),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }
}
