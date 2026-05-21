import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import '../utils/app_assets.dart';
import '../services/pdf_service.dart';
import '../utils/app_helpers.dart';
import '../viewmodels/dosen_viewmodel.dart';
import '../viewmodels/kelas_viewmodel.dart';
import '../viewmodels/krs_viewmodel.dart';
import '../viewmodels/nilai_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../widgets/animated_entrance.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/menu_tile.dart';

class DosenDashboardView extends StatelessWidget {
  const DosenDashboardView({
    required this.user,
    required this.onOpenKelas,
    required this.onOpenNilai,
    required this.onOpenValidasiKrs,
    required this.onOpenTugas,
    required this.onOpenBimbingan,
    super.key,
  });

  final User user;
  final VoidCallback onOpenKelas;
  final VoidCallback onOpenNilai;
  final VoidCallback onOpenValidasiKrs;
  final VoidCallback onOpenTugas;
  final VoidCallback onOpenBimbingan;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final themeVm = context.watch<ThemeViewModel>();
    final kelas = context.watch<KelasViewModel>().items(dosenId: user.scopeId);
    final mahasiswaBimbingan = service.mahasiswa
        .where((item) => item.pembimbingAkademikId == user.scopeId)
        .map((item) => item.nim)
        .toSet();
    final tugas =
        service.tugas
            .where((item) => kelas.any((k) => k.id == item.kelasId))
            .toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));
    final kelasIds = kelas.map((item) => item.id).toSet();
    final peserta = service.krs
        .where((item) => kelasIds.contains(item.kelasId))
        .toList();
    final belumValidasi = service.krs
        .where(
          (item) =>
              mahasiswaBimbingan.contains(item.mahasiswaId) &&
              item.isSubmitted &&
              !item.isValidated,
        )
        .length;
    final bimbinganAktif = service.skripsi
        .where(
          (item) =>
              item.pembimbingId == user.scopeId &&
              item.status != StatusPengajuan.selesai,
        )
        .length;

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
          _DosenHeroCard(user: user, service: service),
          const SizedBox(height: 16),
          const _DosenImageBanner(
            imagePath: AppAssets.libraryBooks,
            icon: Icons.auto_stories_rounded,
            title: 'Pengajaran lebih terstruktur',
            subtitle:
                'Kelola kelas, presensi, tugas, nilai, dan bimbingan dari satu tempat.',
          ),
          const SizedBox(height: 16),
          _DosenStatsGrid(
            stats: [
              _DosenStat(
                icon: Icons.auto_stories_rounded,
                label: 'Beban SKS',
                value: '${service.getTotalSksDosen(user.scopeId)}',
                helper: '${kelas.length} kelas diampu',
              ),
              _DosenStat(
                icon: Icons.groups_rounded,
                label: 'Peserta',
                value: '${peserta.length}',
                helper: 'Total mahasiswa KRS',
              ),
              _DosenStat(
                icon: Icons.assignment_turned_in_rounded,
                label: 'Tugas',
                value: '${tugas.length}',
                helper: tugas.isEmpty
                    ? 'Belum ada deadline'
                    : _deadlineText(tugas.first.deadline),
              ),
              _DosenStat(
                icon: Icons.school_rounded,
                label: 'Bimbingan',
                value: '$bimbinganAktif',
                helper: 'Skripsi aktif',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DosenQuickActions(
            actions: [
              _DosenQuickAction(
                icon: Icons.class_rounded,
                title: 'Kelas & Presensi',
                subtitle: 'Kelola pertemuan kelas',
                onTap: onOpenKelas,
              ),
              _DosenQuickAction(
                icon: Icons.edit_note_rounded,
                title: 'Input Nilai',
                subtitle: 'Tugas, UTS, UAS, softskill',
                onTap: onOpenNilai,
              ),
              _DosenQuickAction(
                icon: Icons.verified_rounded,
                title: 'Validasi KRS',
                subtitle: '$belumValidasi pengajuan menunggu',
                onTap: onOpenValidasiKrs,
              ),
              _DosenQuickAction(
                icon: Icons.assignment_add,
                title: 'Beri Tugas',
                subtitle: '${tugas.length} tugas aktif',
                onTap: onOpenTugas,
              ),
              _DosenQuickAction(
                icon: Icons.school_rounded,
                title: 'Bimbingan',
                subtitle: '$bimbinganAktif skripsi aktif',
                onTap: onOpenBimbingan,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DosenSection(
            title: 'Jadwal Perkuliahan',
            actionLabel: 'Lihat Kelas',
            onAction: onOpenKelas,
            child: kelas.isEmpty
                ? const _DosenEmptyState(
                    icon: Icons.event_busy_rounded,
                    title: 'Belum ada jadwal',
                    subtitle: 'Kelas yang diampu akan tampil di sini.',
                  )
                : Column(
                    children: [
                      for (final item in kelas)
                        _DosenInfoRow(
                          icon: Icons.schedule_rounded,
                          title: service.getMataKuliahName(item.mataKuliahId),
                          subtitle: '${item.hari}, ${item.jam}',
                          trailing: item.ruangan,
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _DosenSection(
            title: 'Deadline Tugas',
            child: tugas.isEmpty
                ? const _DosenEmptyState(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Belum ada tugas aktif',
                    subtitle:
                        'Deadline tugas yang diberikan akan tampil otomatis.',
                  )
                : Column(
                    children: [
                      for (final item in tugas.take(4))
                        _DosenInfoRow(
                          icon: Icons.assignment_outlined,
                          title: item.judul,
                          subtitle: service.getMataKuliahName(
                            service.kelas
                                .firstWhere((k) => k.id == item.kelasId)
                                .mataKuliahId,
                          ),
                          trailing: _deadlineText(item.deadline),
                          isWarning:
                              item.deadline.difference(DateTime.now()).inDays <=
                              3,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static String _deadlineText(DateTime deadline) {
    final days = deadline.difference(DateTime.now()).inDays;
    if (days < 0) return 'Terlambat';
    if (days == 0) return 'Hari ini';
    return '$days hari';
  }
}

class _DosenImageBanner extends StatelessWidget {
  const _DosenImageBanner({
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
                    Colors.black.withValues(alpha: 0.74),
                    Colors.black.withValues(alpha: 0.30),
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

class _DosenHeroCard extends StatelessWidget {
  const _DosenHeroCard({required this.user, required this.service});

  final User user;
  final MockService service;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fullInfo = service.getDosenFullInfo(user.scopeId);
    return AnimatedEntrance(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.classroomLearning,
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
                      scheme.primary.withValues(alpha: 0.96),
                      const Color(0xFF0D47A1).withValues(alpha: 0.84),
                      Colors.black.withValues(alpha: 0.50),
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 31,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    child: Text(
                      user.name.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
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
                          user.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${user.scopeId} - $fullInfo',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),
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
      ),
    );
  }
}

class _DosenStatsGrid extends StatelessWidget {
  const _DosenStatsGrid({required this.stats});

  final List<_DosenStat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 760 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth >= 760 ? 1.45 : 1.08,
          ),
          itemBuilder: (context, index) => _DosenStatCard(stat: stats[index]),
        );
      },
    );
  }
}

class _DosenStatCard extends StatelessWidget {
  const _DosenStatCard({required this.stat});

  final _DosenStat stat;

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
            Icon(stat.icon, color: scheme.primary),
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
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  stat.helper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _DosenQuickActions extends StatelessWidget {
  const _DosenQuickActions({required this.actions});

  final List<_DosenQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return KeyedSubtree(
      key: ValueKey('dosen-quick-actions-$brightness'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth >= 760 ? 3 : 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: constraints.maxWidth >= 760 ? 2.7 : 3.8,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              final theme = Theme.of(context);
              final scheme = Theme.of(context).colorScheme;
              final isDark = theme.brightness == Brightness.dark;
              final cardColor = isDark
                  ? const Color(0xFF1A1C1E)
                  : (theme.cardTheme.color ?? scheme.surface);
              final borderColor = isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE8EEF8);

              return Material(
                color: cardColor,
                elevation: 3,
                borderRadius: BorderRadius.circular(8),
                shadowColor: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : scheme.primary.withValues(alpha: 0.12),
                child: InkWell(
                  onTap: action.onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(action.icon, color: scheme.primary),
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
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  action.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.66,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: scheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DosenSection extends StatelessWidget {
  const _DosenSection({
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
                if (actionLabel != null && onAction != null)
                  TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _DosenInfoRow extends StatelessWidget {
  const _DosenInfoRow({
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
          Icon(icon, color: color),
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
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _DosenEmptyState extends StatelessWidget {
  const _DosenEmptyState({
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
                Text(
                  subtitle,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _DosenStat {
  const _DosenStat({
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

class _DosenQuickAction {
  const _DosenQuickAction({
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

class DosenKelasView extends StatelessWidget {
  const DosenKelasView({required this.dosenId, super.key});

  final String dosenId;

  @override
  Widget build(BuildContext context) {
    // Dosen hanya melihat kelas yang dosenId-nya sama dengan user aktif.
    final service = context.watch<MockService>();
    final kelas = context.watch<KelasViewModel>().items(dosenId: dosenId);
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Kelas Saya',
      child: Column(
        children: [
          AnimatedEntrance(
            child: Card(
              color: scheme.primary,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      color: scheme.onPrimary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Beban Mengajar',
                          style: TextStyle(
                            color: scheme.onPrimary.withValues(alpha: 0.72),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${service.getTotalSksDosen(dosenId)} SKS Semester Ini',
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (int i = 0; i < kelas.length; i++)
            AnimatedEntrance(
              delay: Duration(milliseconds: i * 100),
              child: InkWell(
                onTap: () {
                  final item = kelas[i];
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          KelasPertemuanView(kelasId: item.id),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            final slide =
                                Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                );
                            return SlideTransition(
                              position: slide,
                              child: child,
                            );
                          },
                    ),
                  );
                },
                child: InfoTile(
                  icon: Icons.class_outlined,
                  title: service.getMataKuliahName(kelas[i].mataKuliahId),
                  subtitle:
                      '${kelas[i].id} - ${kelas[i].hari}, ${kelas[i].jam}\n${kelas[i].ruangan}',
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DosenNilaiView extends StatelessWidget {
  const DosenNilaiView({required this.dosenId, super.key});

  final String dosenId;

  @override
  Widget build(BuildContext context) {
    // Halaman nilai dimulai dari pemilihan kelas yang diajar dosen.
    final service = context.watch<MockService>();
    final kelas = context.watch<KelasViewModel>().items(dosenId: dosenId);

    return AppScaffold(
      title: 'Pilih Mata Kuliah',
      child: Column(
        children: [
          for (int i = 0; i < kelas.length; i++)
            AnimatedEntrance(
              delay: Duration(milliseconds: i * 80),
              child: InfoTile(
                icon: Icons.assignment_outlined,
                title: service.getMataKuliahName(kelas[i].mataKuliahId),
                subtitle: 'ID Kelas: ${kelas[i].id}',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DosenInputNilaiKelasView(
                        kelasId: kelas[i].id,
                        dosenId: dosenId,
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

class DosenInputNilaiKelasView extends StatelessWidget {
  const DosenInputNilaiKelasView({
    required this.kelasId,
    required this.dosenId,
    super.key,
  });

  final String kelasId;
  final String dosenId;

  @override
  Widget build(BuildContext context) {
    // Setelah kelas dipilih, daftar peserta diambil dari KRS kelas tersebut.
    final service = context.watch<MockService>();
    final kelas = service.kelas.firstWhere((k) => k.id == kelasId);
    final krs = service.krs.where((k) => k.kelasId == kelasId).toList();
    final nilaiVm = context.watch<NilaiViewModel>();

    return AppScaffold(
      title: 'Input Nilai: ${service.getMataKuliahName(kelas.mataKuliahId)}',
      child: Column(
        children: [
          if (krs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Belum ada mahasiswa di kelas ini')),
            )
          else
            for (int i = 0; i < krs.length; i++)
              AnimatedEntrance(
                delay: Duration(milliseconds: i * 80),
                child: InfoTile(
                  icon: Icons.person_outline,
                  title: service.getMahasiswaName(krs[i].mahasiswaId),
                  subtitle: 'NIM: ${krs[i].mahasiswaId}',
                  trailing: FilledButton(
                    onPressed: () => _showInputNilaiDialog(
                      context: context,
                      nilaiVm: nilaiVm,
                      mahasiswaId: krs[i].mahasiswaId,
                    ),
                    child: const Text('Input'),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _showInputNilaiDialog({
    required BuildContext context,
    required NilaiViewModel nilaiVm,
    required String mahasiswaId,
  }) async {
    final tugasCtrl = TextEditingController();
    final utsCtrl = TextEditingController();
    final uasCtrl = TextEditingController();
    final softskillCtrl = TextEditingController();

    double parse(TextEditingController controller) =>
        double.tryParse(controller.text.trim())?.clamp(0, 100).toDouble() ?? 0;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Input Detail Nilai'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ScoreField(controller: tugasCtrl, label: 'Nilai Tugas'),
                  const SizedBox(height: 12),
                  _ScoreField(controller: utsCtrl, label: 'Nilai UTS'),
                  const SizedBox(height: 12),
                  _ScoreField(controller: uasCtrl, label: 'Nilai UAS'),
                  const SizedBox(height: 12),
                  _ScoreField(
                    controller: softskillCtrl,
                    label: 'Nilai Softskill',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bobot: Tugas 25%, UTS 25%, UAS 35%, Softskill 15%',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final tugas = parse(tugasCtrl);
                final uts = parse(utsCtrl);
                final uas = parse(uasCtrl);
                final softskill = parse(softskillCtrl);
                final finalScore =
                    (tugas * 0.25) +
                    (uts * 0.25) +
                    (uas * 0.35) +
                    (softskill * 0.15);
                nilaiVm.input(
                  dosenId: dosenId,
                  mahasiswaId: mahasiswaId,
                  kelasId: kelasId,
                  angka: finalScore,
                  tugas: tugas,
                  uts: uts,
                  uas: uas,
                  softskill: softskill,
                );
                Navigator.pop(dialogContext);
                showAppMessage(context, nilaiVm.message);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    tugasCtrl.dispose();
    utsCtrl.dispose();
    uasCtrl.dispose();
    softskillCtrl.dispose();
  }
}

class _ScoreField extends StatelessWidget {
  const _ScoreField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: '$label (0-100)'),
      keyboardType: TextInputType.number,
    );
  }
}

class DosenKrsValidationView extends StatelessWidget {
  const DosenKrsValidationView({required this.dosenId, super.key});

  final String dosenId;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final krsVm = context.watch<KRSViewModel>();
    final mahasiswaBimbingan = service.mahasiswa
        .where((item) => item.pembimbingAkademikId == dosenId)
        .map((item) => item.nim)
        .toSet();
    final krsList =
        service.krs
            .where(
              (item) =>
                  mahasiswaBimbingan.contains(item.mahasiswaId) &&
                  item.isSubmitted,
            )
            .toList()
          ..sort((a, b) {
            if (a.isValidated != b.isValidated) {
              return a.isValidated ? 1 : -1;
            }
            return b.semester.compareTo(a.semester);
          });

    return AppScaffold(
      title: 'Validasi KRS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (krsList.isEmpty)
            const _DosenEmptyState(
              icon: Icons.playlist_add_check_rounded,
              title: 'Belum ada KRS',
              subtitle:
                  'Pengajuan KRS mahasiswa bimbingan akademik Anda akan tampil di sini.',
            )
          else
            for (int i = 0; i < krsList.length; i++)
              AnimatedEntrance(
                delay: Duration(milliseconds: i * 70),
                child: Builder(
                  builder: (context) {
                    final krs = krsList[i];
                    final kelas = service.kelas.firstWhere(
                      (item) => item.id == krs.kelasId,
                    );
                    return InfoTile(
                      icon: krs.isValidated
                          ? Icons.verified_rounded
                          : Icons.pending_actions_rounded,
                      title: service.getMahasiswaName(krs.mahasiswaId),
                      subtitle:
                          '${service.getMataKuliahName(kelas.mataKuliahId)}\nNIM: ${krs.mahasiswaId} - Semester ${krs.semester}\nDosen pengampu: ${service.getDosenName(kelas.dosenId)}',
                      trailing: krs.isValidated
                          ? const Text(
                              'Disetujui',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            )
                          : FilledButton(
                              onPressed: () {
                                krsVm.validate(krs.id, dosenId);
                                showAppMessage(context, krsVm.message);
                              },
                              child: const Text('Setujui'),
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

class DosenProfileView extends StatelessWidget {
  const DosenProfileView({
    required this.user,
    required this.onLogout,
    super.key,
  });

  final User user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final vm = context.watch<DosenViewModel>();
    final dosen = vm.byId(user.scopeId);
    if (dosen == null) {
      return AppScaffold(
        title: 'Profil',
        child: const _DosenEmptyState(
          icon: Icons.person_off_rounded,
          title: 'Profil tidak ditemukan',
          subtitle: 'Data dosen belum tersedia di sistem.',
        ),
      );
    }
    final prodi = service.prodi.firstWhere(
      (item) => item.id == dosen.prodiId,
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
                      dosen.nama.substring(0, 1),
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
                          dosen.nama,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dosen.nidn} - ${prodi.nama}',
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
          _DosenProfileSection(
            title: 'Data Akademik',
            children: [
              _DosenProfileRow(label: 'Nama', value: dosen.nama),
              _DosenProfileRow(label: 'NIDN', value: dosen.nidn),
              _DosenProfileRow(label: 'Program Studi', value: prodi.nama),
              _DosenProfileRow(label: 'Fakultas', value: fakultas.nama),
              _DosenProfileRow(
                label: 'Keahlian',
                value: dosen.keahlian.isEmpty ? '-' : dosen.keahlian,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DosenProfileSection(
            title: 'Kontak',
            action: TextButton.icon(
              onPressed: () => _editProfile(context, dosen),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit'),
            ),
            children: [
              _DosenProfileRow(
                label: 'Email',
                value: dosen.email.isEmpty ? '-' : dosen.email,
              ),
              _DosenProfileRow(
                label: 'No. HP',
                value: dosen.noHp.isEmpty ? '-' : dosen.noHp,
              ),
              _DosenProfileRow(
                label: 'Alamat',
                value: dosen.alamat.isEmpty ? '-' : dosen.alamat,
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

  Future<void> _editProfile(BuildContext context, Dosen dosen) async {
    final vm = context.read<DosenViewModel>();
    final emailCtrl = TextEditingController(text: dosen.email);
    final noHpCtrl = TextEditingController(text: dosen.noHp);
    final alamatCtrl = TextEditingController(text: dosen.alamat);
    final keahlianCtrl = TextEditingController(text: dosen.keahlian);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profil Dosen'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: dosen.nama,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: dosen.nidn,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'NIDN',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keahlianCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Bidang Keahlian',
                    prefixIcon: Icon(Icons.psychology_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noHpCtrl,
                  decoration: const InputDecoration(
                    labelText: 'No. HP',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: alamatCtrl,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              vm.updateProfile(
                nidn: dosen.nidn,
                email: emailCtrl.text,
                noHp: noHpCtrl.text,
                alamat: alamatCtrl.text,
                keahlian: keahlianCtrl.text,
              );
              Navigator.pop(dialogContext);
              showAppMessage(context, vm.message);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    emailCtrl.dispose();
    noHpCtrl.dispose();
    alamatCtrl.dispose();
    keahlianCtrl.dispose();
  }
}

class _DosenProfileSection extends StatelessWidget {
  const _DosenProfileSection({
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

class _DosenProfileRow extends StatelessWidget {
  const _DosenProfileRow({required this.label, required this.value});

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

class DosenTugasView extends StatefulWidget {
  const DosenTugasView({required this.dosenId, super.key});

  final String dosenId;

  @override
  State<DosenTugasView> createState() => _DosenTugasViewState();
}

class _DosenTugasViewState extends State<DosenTugasView> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final kelas = context.watch<KelasViewModel>().items(
      dosenId: widget.dosenId,
    );
    final kelasIds = kelas.map((item) => item.id).toSet();
    final tugas =
        service.tugas.where((item) => kelasIds.contains(item.kelasId)).toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return AppScaffold(
      title: 'Tugas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DosenTugasBox(
            dosenId: widget.dosenId,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 16),
          if (tugas.isEmpty)
            const _DosenEmptyState(
              icon: Icons.assignment_outlined,
              title: 'Belum ada tugas',
              subtitle: 'Tugas yang Anda berikan akan tampil di sini.',
            )
          else
            for (int i = 0; i < tugas.length; i++)
              AnimatedEntrance(
                delay: Duration(milliseconds: i * 70),
                child: Builder(
                  builder: (context) {
                    final item = tugas[i];
                    final kelas = service.kelas.firstWhere(
                      (kelas) => kelas.id == item.kelasId,
                    );
                    return InfoTile(
                      icon: Icons.assignment_rounded,
                      title: item.judul,
                      subtitle:
                          '${service.getMataKuliahName(kelas.mataKuliahId)}\n${item.deskripsi}',
                      trailing: Text(
                        DosenDashboardView._deadlineText(item.deadline),
                        style: const TextStyle(fontWeight: FontWeight.w900),
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

class DosenBimbinganView extends StatefulWidget {
  const DosenBimbinganView({required this.dosenId, super.key});

  final String dosenId;

  @override
  State<DosenBimbinganView> createState() => _DosenBimbinganViewState();
}

class _DosenBimbinganViewState extends State<DosenBimbinganView> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final skripsi =
        service.skripsi
            .where((item) => item.pembimbingId == widget.dosenId)
            .toList()
          ..sort((a, b) => b.dibuatPada.compareTo(a.dibuatPada));

    return AppScaffold(
      title: 'Bimbingan Skripsi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (skripsi.isEmpty)
            const _DosenEmptyState(
              icon: Icons.school_outlined,
              title: 'Belum ada bimbingan',
              subtitle:
                  'Mahasiswa bimbingan yang memulai skripsi akan tampil di sini.',
            )
          else
            for (int i = 0; i < skripsi.length; i++)
              AnimatedEntrance(
                delay: Duration(milliseconds: i * 70),
                child: Builder(
                  builder: (context) {
                    final item = skripsi[i];
                    return InfoTile(
                      icon: item.status == StatusPengajuan.diajukan
                          ? Icons.pending_actions_rounded
                          : Icons.school_rounded,
                      title: service.getMahasiswaName(item.mahasiswaId),
                      subtitle:
                          '${item.judul}\nTopik: ${item.topik}\nStatus: ${item.status.label}${item.catatan.isEmpty ? '' : '\nCatatan terakhir: ${item.catatan.last}'}',
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          if (item.status == StatusPengajuan.diajukan)
                            FilledButton(
                              onPressed: () {
                                final msg = service.setujuiSkripsi(
                                  item.id,
                                  widget.dosenId,
                                );
                                showAppMessage(context, msg);
                                setState(() {});
                              },
                              child: const Text('Setujui'),
                            ),
                          IconButton(
                            onPressed: () => _addCatatan(context, item.id),
                            icon: const Icon(Icons.note_add_outlined),
                            tooltip: 'Tambah catatan',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _addCatatan(BuildContext context, String skripsiId) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan Bimbingan'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Catatan'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              try {
                final msg = context.read<MockService>().tambahCatatanBimbingan(
                  skripsiId: skripsiId,
                  dosenId: widget.dosenId,
                  catatan: controller.text,
                );
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
    controller.dispose();
  }
}

class DosenTugasBox extends StatelessWidget {
  const DosenTugasBox({required this.dosenId, this.onChanged, super.key});

  final String dosenId;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    // Kotak tugas di dashboard dosen menampilkan tugas dari kelas yang diajar.
    final service = context.watch<MockService>();
    final kelas = context.watch<KelasViewModel>().items(dosenId: dosenId);

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
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 540 ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            MenuTile(
              icon: Icons.assignment_add,
              title: 'Beri Tugas',
              subtitle: 'Buat tugas baru untuk kelas Anda',
              color: const Color(0xFF0B57D0),
              onTap: () async {
                if (kelas.isEmpty) {
                  showAppMessage(context, 'Anda belum memiliki kelas');
                  return;
                }

                String? selectedKelasId = kelas.first.id;
                final judulCtrl = TextEditingController();
                final deskripsiCtrl = TextEditingController();
                DateTime deadline = DateTime.now().add(const Duration(days: 7));

                await showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Beri Tugas Baru'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButtonFormField<String>(
                                  initialValue: selectedKelasId,
                                  decoration: const InputDecoration(
                                    labelText: 'Pilih Kelas',
                                  ),
                                  items: kelas.map((k) {
                                    final mkName = service.getMataKuliahName(
                                      k.mataKuliahId,
                                    );
                                    return DropdownMenuItem(
                                      value: k.id,
                                      child: Text('$mkName (${k.id})'),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => selectedKelasId = val),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: judulCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Judul Tugas',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: deskripsiCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Deskripsi',
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Deadline'),
                                  subtitle: Text(
                                    '${deadline.day}/${deadline.month}/${deadline.year}',
                                  ),
                                  trailing: const Icon(Icons.calendar_today),
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: deadline,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (date != null) {
                                      setState(() => deadline = date);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            FilledButton(
                              onPressed: () {
                                try {
                                  final msg = service.addTugas(
                                    dosenId: dosenId,
                                    kelasId: selectedKelasId!,
                                    judul: judulCtrl.text,
                                    deskripsi: deskripsiCtrl.text,
                                    deadline: deadline,
                                  );
                                  showAppMessage(context, msg);
                                  Navigator.pop(context);
                                  onChanged?.call();
                                } catch (e) {
                                  showAppMessage(context, e.toString());
                                }
                              },
                              child: const Text('Simpan'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class KelasPertemuanView extends StatefulWidget {
  const KelasPertemuanView({required this.kelasId, super.key});

  final String kelasId;

  @override
  State<KelasPertemuanView> createState() => _KelasPertemuanViewState();
}

class _KelasPertemuanViewState extends State<KelasPertemuanView> {
  @override
  Widget build(BuildContext context) {
    // Detail kelas berisi daftar 16 pertemuan dan aksi presensi per pertemuan.
    final service = context.watch<MockService>();
    final scheme = Theme.of(context).colorScheme;
    final kelas = service.kelas.firstWhere((k) => k.id == widget.kelasId);
    final pertemuanList =
        service.pertemuan.where((p) => p.kelasId == widget.kelasId).toList()
          ..sort((a, b) => a.pertemuanKe.compareTo(b.pertemuanKe));
    final mkName = service.getMataKuliahName(kelas.mataKuliahId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pertemuan Kelas', style: TextStyle(fontSize: 16)),
            Text(
              mkName,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cetak Presensi',
            onPressed: () async {
              try {
                await PdfService.printPresensiKelas(
                  context: context,
                  kelasId: widget.kelasId,
                  service: service,
                );
              } catch (e) {
                if (context.mounted) {
                  showAppMessage(context, 'Gagal membuat PDF: $e');
                }
              }
            },
            icon: const Icon(Icons.print_rounded),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pertemuanList.length,
        itemBuilder: (context, index) {
          final p = pertemuanList[index];
          final isBelumMulai = p.status == StatusPertemuan.belumDimulai;
          final isBerlangsung = p.status == StatusPertemuan.berlangsung;
          final statusColor = isBelumMulai
              ? scheme.onSurface
              : isBerlangsung
              ? Colors.green
              : scheme.primary;

          return AnimatedEntrance(
            delay: Duration(milliseconds: index * 50),
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Pertemuan ${p.pertemuanKe}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (p.pertemuanKe == 8 || p.pertemuanKe == 16) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  p.pertemuanKe == 8 ? 'UTS' : 'UAS',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isBelumMulai
                                ? scheme.onSurface.withValues(alpha: 0.08)
                                : (p.status == StatusPertemuan.berlangsung
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : scheme.primary.withValues(alpha: 0.16)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBelumMulai
                                ? 'Belum Dimulai'
                                : (p.status == StatusPertemuan.berlangsung
                                      ? 'Berlangsung'
                                      : 'Selesai'),
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isBelumMulai && p.materi != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Materi: ${p.materi}',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.68),
                        ),
                      ),
                      if (p.waktuMulai != null)
                        Text(
                          'Waktu: ${p.waktuMulai!.day}/${p.waktuMulai!.month}/${p.waktuMulai!.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.58),
                          ),
                        ),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          if (isBelumMulai)
                            FilledButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Mulai Pertemuan'),
                              onPressed: () =>
                                  _showMulaiDialog(context, service, p),
                            )
                          else ...[
                            FilledButton.icon(
                              icon: const Icon(Icons.fact_check_outlined),
                              label: const Text('Isi Presensi'),
                              style: FilledButton.styleFrom(
                                backgroundColor: scheme.primary,
                                foregroundColor: scheme.onPrimary,
                              ),
                              onPressed: () =>
                                  _showPresensiDialog(context, service, p),
                            ),
                            if (isBerlangsung)
                              FilledButton.icon(
                                icon: const Icon(Icons.done_all_rounded),
                                label: const Text('Selesaikan'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () =>
                                    _selesaikanPertemuan(context, service, p),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showMulaiDialog(
    BuildContext context,
    MockService service,
    Pertemuan p,
  ) async {
    final materiCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mulai Pertemuan ${p.pertemuanKe}'),
          content: TextField(
            controller: materiCtrl,
            decoration: const InputDecoration(labelText: 'Materi Pembahasan'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                try {
                  service.mulaiPertemuan(p.id, materiCtrl.text);
                  Navigator.pop(context);
                  if (mounted) setState(() {});
                  showAppMessage(context, 'Pertemuan ${p.pertemuanKe} dimulai');
                } catch (e) {
                  showAppMessage(context, e.toString());
                }
              },
              child: const Text('Mulai'),
            ),
          ],
        );
      },
    );
  }

  void _selesaikanPertemuan(
    BuildContext context,
    MockService service,
    Pertemuan p,
  ) {
    try {
      service.selesaikanPertemuan(p.id);
      if (mounted) setState(() {});
      showAppMessage(context, 'Pertemuan ${p.pertemuanKe} selesai');
    } catch (e) {
      showAppMessage(context, e.toString());
    }
  }

  Future<void> _showPresensiDialog(
    BuildContext context,
    MockService service,
    Pertemuan p,
  ) async {
    final krsList = service.krs.where((k) => k.kelasId == p.kelasId).toList();
    final currentPresensi = service.presensi
        .where((pr) => pr.pertemuanId == p.id)
        .toList();

    // Initial status for everyone is 'Hadir', unless already saved
    final Map<String, String> status = {};
    for (final k in krsList) {
      final saved = currentPresensi
          .where((pr) => pr.mahasiswaId == k.mahasiswaId)
          .firstOrNull;
      status[k.mahasiswaId] = saved?.statusKehadiran ?? 'Hadir';
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Presensi Pertemuan ${p.pertemuanKe}'),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setState) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: krsList.length,
                  itemBuilder: (context, index) {
                    final mhsId = krsList[index].mahasiswaId;
                    final mhs = service.mahasiswa.firstWhere(
                      (m) => m.nim == mhsId,
                    );
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        mhs.nama,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(mhs.nim),
                      trailing: DropdownButton<String>(
                        value: status[mhsId],
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Hadir',
                            child: Text(
                              'Hadir',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Ijin',
                            child: Text(
                              'Ijin',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Sakit',
                            child: Text(
                              'Sakit',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Alpa',
                            child: Text(
                              'Alpa',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => status[mhsId] = val);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                try {
                  service.simpanPresensi(p.id, status);
                  Navigator.pop(context);
                  if (mounted) setState(() {});
                  showAppMessage(
                    context,
                    'Presensi pertemuan ${p.pertemuanKe} disimpan',
                  );
                } catch (e) {
                  showAppMessage(context, e.toString());
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
