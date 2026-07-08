import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_service.dart';
import '../viewmodels/theme_viewmodel.dart';

import '../models/siakad_models.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/menu_tile.dart';
import 'admin_views.dart';
import 'dosen_views.dart';
import 'login_view.dart';
import 'mahasiswa_views.dart';
import 'pimpinan_views.dart';
import 'presensi_views.dart';

class RoleHomeView extends StatefulWidget {
  const RoleHomeView({super.key});

  @override
  State<RoleHomeView> createState() => _RoleHomeViewState();
}

class _RoleHomeViewState extends State<RoleHomeView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;
    // Jika tidak ada sesi aktif, user dikembalikan ke login.
    if (user == null) return const LoginView();

    // Role menentukan menu navigasi dan halaman yang boleh diakses.
    final config = _RoleNavConfig.fromUser(user);
    final pageBuilders = config.pageBuilders(user, _logout, (index) {
      _selectIndex(index);
    });
    if (_index >= pageBuilders.length) _index = pageBuilders.length - 1;

    final pageStack = _LazyRolePageStack(
      key: ValueKey('${user.id}-${user.role.name}'),
      index: _index,
      pageBuilders: pageBuilders,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTopBar = constraints.maxWidth >= 900;

        return Scaffold(
          body: useTopBar
              ? Column(
                  children: [
                    _DesktopTopBar(
                      selectedIndex: _index,
                      destinations: config.destinations,
                      onDestinationSelected: _selectIndex,
                      onLogout: _logout,
                    ),
                    Expanded(child: pageStack),
                  ],
                )
              : pageStack,
          bottomNavigationBar: useTopBar
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: _selectIndex,
                  destinations: config.destinations,
                ),
        );
      },
    );
  }

  void _selectIndex(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  void _logout() {
    // Logout membersihkan AuthViewModel dan menghapus semua halaman sebelumnya.
    context.read<AuthViewModel>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginView()),
      (_) => false,
    );
  }
}

typedef _RolePageBuilder = Widget Function();

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.onLogout,
  });

  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final themeVm = context.watch<ThemeViewModel>();

    return SafeArea(
      bottom: false,
      child: Material(
        color: scheme.surface,
        elevation: 0,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.52),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: scheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'SIAKAD',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: destinations.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final destination = destinations[index];
                      final selected = index == selectedIndex;

                      return Tooltip(
                        message: destination.label,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => onDestinationSelected(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? scheme.primary.withValues(alpha: 0.11)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? scheme.primary.withValues(alpha: 0.24)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconTheme(
                                  data: IconThemeData(
                                    color: selected
                                        ? scheme.primary
                                        : scheme.onSurface.withValues(
                                            alpha: 0.62,
                                          ),
                                    size: 21,
                                  ),
                                  child: destination.icon,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  destination.label,
                                  style: TextStyle(
                                    color: selected
                                        ? scheme.primary
                                        : scheme.onSurface.withValues(
                                            alpha: 0.72,
                                          ),
                                    fontWeight: selected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: themeVm.isDarkMode
                      ? 'Gunakan tema terang'
                      : 'Gunakan tema gelap',
                  child: IconButton.filledTonal(
                    onPressed: () => themeVm.toggleTheme(),
                    icon: Icon(
                      themeVm.isDarkMode
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Logout',
                  child: IconButton.filledTonal(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LazyRolePageStack extends StatelessWidget {
  const _LazyRolePageStack({
    required this.index,
    required this.pageBuilders,
    super.key,
  });

  final int index;
  final List<_RolePageBuilder> pageBuilders;

  @override
  Widget build(BuildContext context) {
    // Hidden pages contain Provider listeners and expensive data projections.
    // Keeping them mounted makes every data update rebuild tabs the user cannot
    // see. PageStorageKey in AppScaffold still preserves scroll positions.
    return KeyedSubtree(key: ValueKey(index), child: pageBuilders[index]());
  }
}

class RoleDashboard extends StatelessWidget {
  const RoleDashboard({
    required this.user,
    required this.actions,
    required this.flow,
    this.extraContent,
    super.key,
  });

  final User user;
  final List<DashboardAction> actions;
  final List<String> flow;
  final Widget? extraContent;

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();

    // Dashboard dipakai ulang oleh semua role, sementara isi flow dan widget
    // tambahan dikirim dari konfigurasi masing-masing role.
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.name.substring(0, 1),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 24,
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
                          user.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.role == Role.dosen
                              ? '${user.role.label} - ${context.read<MockService>().getDosenFullInfo(user.scopeId)}'
                              : user.role.label,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Alur Sistem',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final item in flow)
            InfoTile(
              icon: Icons.account_tree_outlined,
              title: item,
              subtitle: 'Terhubung melalui role dan relasi data',
              trailing: Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 540 ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final action in actions)
                MenuTile(
                  icon: action.icon,
                  title: action.title,
                  subtitle: action.subtitle,
                  color: action.color,
                  onTap: action.onTap,
                ),
            ],
          ),
          if (extraContent != null) ...[
            const SizedBox(height: 18),
            extraContent!,
          ],
        ],
      ),
    );
  }
}

class _AdminUniversitasHome extends StatefulWidget {
  const _AdminUniversitasHome({required this.user, required this.selectTab});

  final User user;
  final ValueChanged<int> selectTab;

  @override
  State<_AdminUniversitasHome> createState() => _AdminUniversitasHomeState();
}

class _AdminUniversitasHomeState extends State<_AdminUniversitasHome> {
  int? _revision;
  _AdminUniversitySnapshot? _snapshot;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final themeVm = context.watch<ThemeViewModel>();
    final snapshot = _snapshotFor(service);
    final scheme = Theme.of(context).colorScheme;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdminHeroCard(
            user: widget.user,
            snapshot: snapshot,
            onPrimaryTap: () => widget.selectTab(2),
            onSecondaryTap: () => widget.selectTab(4),
          ),
          const SizedBox(height: 16),
          _AdminKpiGrid(snapshot: snapshot),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 920;
              final children = [
                _AdminPanel(
                  title: 'Sebaran Fakultas',
                  icon: Icons.account_balance_outlined,
                  child: Column(
                    children: [
                      for (final faculty in snapshot.facultyLoads)
                        _FacultyLoadRow(
                          name: faculty.name,
                          prodiCount: faculty.prodiCount,
                          studentCount: faculty.studentCount,
                          maxStudentCount: snapshot.maxFacultyStudents,
                        ),
                    ],
                  ),
                ),
                _AdminPanel(
                  title: 'Status KRS',
                  icon: Icons.fact_check_outlined,
                  child: Column(
                    children: [
                      _ProgressMetricRow(
                        label: 'Disetujui',
                        value: snapshot.krsApproved,
                        total: snapshot.totalKrs,
                        color: Colors.green,
                      ),
                      _ProgressMetricRow(
                        label: 'Diajukan',
                        value: snapshot.krsSubmitted,
                        total: snapshot.totalKrs,
                        color: scheme.primary,
                      ),
                      _ProgressMetricRow(
                        label: 'Draft',
                        value: snapshot.krsDraft,
                        total: snapshot.totalKrs,
                        color: Colors.orange,
                      ),
                      _ProgressMetricRow(
                        label: 'Ditolak',
                        value: snapshot.krsRejected,
                        total: snapshot.totalKrs,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ];

              if (!twoColumns) {
                return Column(
                  children: [
                    children[0],
                    const SizedBox(height: 12),
                    children[1],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[0]),
                  const SizedBox(width: 12),
                  Expanded(child: children[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 920;
              final children = [
                _AdminPanel(
                  title: 'Sinyal Operasional',
                  icon: Icons.monitor_heart_outlined,
                  child: Column(
                    children: [
                      _OperationalSignal(
                        icon: Icons.how_to_reg_outlined,
                        title: 'Presensi mahasiswa',
                        value: '${snapshot.attendanceRateText} hadir',
                        tone: Colors.green,
                      ),
                      _OperationalSignal(
                        icon: Icons.event_available_outlined,
                        title: 'Fase KRS',
                        value: snapshot.krsPhaseText,
                        tone: snapshot.krsPhaseActive
                            ? Colors.green
                            : Colors.orange,
                      ),
                      _OperationalSignal(
                        icon: Icons.groups_2_outlined,
                        title: 'Kelas penuh',
                        value: '${snapshot.fullClassCount} kelas',
                        tone: snapshot.fullClassCount == 0
                            ? Colors.green
                            : Colors.red,
                      ),
                      _OperationalSignal(
                        icon: Icons.person_search_outlined,
                        title: 'Mahasiswa belum KRS',
                        value: '${snapshot.studentsWithoutKrs} orang',
                        tone: snapshot.studentsWithoutKrs == 0
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ],
                  ),
                ),
                _AdminPanel(
                  title: 'Aksi Cepat',
                  icon: Icons.bolt_outlined,
                  child: Column(
                    children: [
                      _AdminQuickAction(
                        icon: Icons.account_tree_outlined,
                        title: 'Struktur Fakultas',
                        subtitle:
                            '${snapshot.totalFakultas} fakultas dan '
                            '${snapshot.totalProdi} prodi',
                        onTap: () => widget.selectTab(1),
                      ),
                      _AdminQuickAction(
                        icon: Icons.storage_outlined,
                        title: 'Data Akademik Global',
                        subtitle:
                            '${_formatNumber(snapshot.totalMahasiswa)} '
                            'mahasiswa, ${_formatNumber(snapshot.totalDosen)} dosen',
                        onTap: () => widget.selectTab(2),
                      ),
                      _AdminQuickAction(
                        icon: Icons.manage_accounts_outlined,
                        title: 'Akun dan Role',
                        subtitle: '${snapshot.totalUsers} akun pengguna aktif',
                        onTap: () => widget.selectTab(4),
                      ),
                    ],
                  ),
                ),
              ];

              if (!twoColumns) {
                return Column(
                  children: [
                    children[0],
                    const SizedBox(height: 12),
                    children[1],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[0]),
                  const SizedBox(width: 12),
                  Expanded(child: children[1]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  _AdminUniversitySnapshot _snapshotFor(MockService service) {
    if (_revision == service.dataRevision && _snapshot != null) {
      return _snapshot!;
    }
    _revision = service.dataRevision;
    _snapshot = _AdminUniversitySnapshot.from(service);
    return _snapshot!;
  }
}

class _AdminHeroCard extends StatelessWidget {
  const _AdminHeroCard({
    required this.user,
    required this.snapshot,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final User user;
  final _AdminUniversitySnapshot snapshot;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary,
              Color.lerp(scheme.primary, scheme.secondary, 0.42)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final identity = Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.onPrimary.withValues(alpha: 0.16),
                  child: Text(
                    user.name.substring(0, 1),
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 24,
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
                        'Command Center Universitas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.name} - ${snapshot.activeAcademicYear}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onPrimary.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final actions = Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: wide ? WrapAlignment.end : WrapAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: onPrimaryTap,
                  icon: const Icon(Icons.storage_outlined),
                  label: const Text('Data Global'),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.onPrimary,
                    foregroundColor: scheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onSecondaryTap,
                  icon: const Icon(Icons.group_outlined),
                  label: const Text('Kelola User'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onPrimary,
                    side: BorderSide(
                      color: scheme.onPrimary.withValues(alpha: 0.55),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );

            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [identity, const SizedBox(height: 16), actions],
              );
            }

            return Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: 16),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminKpiGrid extends StatelessWidget {
  const _AdminKpiGrid({required this.snapshot});

  final _AdminUniversitySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100 ? 4 : (width >= 640 ? 2 : 1);

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: width >= 640 ? 2.55 : 3.4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _AdminKpiCard(
          icon: Icons.school_outlined,
          label: 'Mahasiswa Aktif',
          value: _formatNumber(snapshot.activeMahasiswa),
          caption: '${snapshot.activeStudentRateText} dari total mahasiswa',
        ),
        _AdminKpiCard(
          icon: Icons.badge_outlined,
          label: 'Dosen',
          value: _formatNumber(snapshot.totalDosen),
          caption: '${snapshot.totalProdi} prodi terlayani',
        ),
        _AdminKpiCard(
          icon: Icons.class_outlined,
          label: 'Kelas Dibuka',
          value: _formatNumber(snapshot.totalKelas),
          caption: '${snapshot.fullClassCount} kelas penuh',
        ),
        _AdminKpiCard(
          icon: Icons.fact_check_outlined,
          label: 'KRS Disetujui',
          value: snapshot.krsApprovedRateText,
          caption: '${_formatNumber(snapshot.krsApproved)} record tervalidasi',
        ),
      ],
    );
  }
}

class _AdminKpiCard extends StatelessWidget {
  const _AdminKpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w600,
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

class _AdminPanel extends StatelessWidget {
  const _AdminPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _FacultyLoadRow extends StatelessWidget {
  const _FacultyLoadRow({
    required this.name,
    required this.prodiCount,
    required this.studentCount,
    required this.maxStudentCount,
  });

  final String name;
  final int prodiCount;
  final int studentCount;
  final int maxStudentCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = maxStudentCount == 0
        ? 0.0
        : studentCount / maxStudentCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_formatNumber(studentCount)} mhs',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.64),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _MiniProgressBar(value: progress, color: scheme.primary),
          const SizedBox(height: 4),
          Text(
            '$prodiCount prodi',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.58),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressMetricRow extends StatelessWidget {
  const _ProgressMetricRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = total == 0 ? 0.0 : value / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${_formatNumber(value)} (${_formatPercent(progress)})',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.64),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _MiniProgressBar(value: progress, color: color),
        ],
      ),
    );
  }
}

class _MiniProgressBar extends StatelessWidget {
  const _MiniProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 8,
        value: value.clamp(0.0, 1.0),
        color: color,
        backgroundColor: scheme.surfaceContainerHighest,
      ),
    );
  }
}

class _OperationalSignal extends StatelessWidget {
  const _OperationalSignal({
    required this.icon,
    required this.title,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: tone, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.68),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminQuickAction extends StatelessWidget {
  const _AdminQuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.outlineVariant),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminUniversitySnapshot {
  const _AdminUniversitySnapshot({
    required this.totalFakultas,
    required this.totalProdi,
    required this.totalMahasiswa,
    required this.activeMahasiswa,
    required this.totalDosen,
    required this.totalKelas,
    required this.totalUsers,
    required this.totalKrs,
    required this.krsDraft,
    required this.krsSubmitted,
    required this.krsApproved,
    required this.krsRejected,
    required this.fullClassCount,
    required this.studentsWithoutKrs,
    required this.attendanceRate,
    required this.activeAcademicYear,
    required this.krsPhaseText,
    required this.krsPhaseActive,
    required this.facultyLoads,
  });

  final int totalFakultas;
  final int totalProdi;
  final int totalMahasiswa;
  final int activeMahasiswa;
  final int totalDosen;
  final int totalKelas;
  final int totalUsers;
  final int totalKrs;
  final int krsDraft;
  final int krsSubmitted;
  final int krsApproved;
  final int krsRejected;
  final int fullClassCount;
  final int studentsWithoutKrs;
  final double attendanceRate;
  final String activeAcademicYear;
  final String krsPhaseText;
  final bool krsPhaseActive;
  final List<_FacultyLoad> facultyLoads;

  int get maxFacultyStudents {
    var max = 0;
    for (final item in facultyLoads) {
      if (item.studentCount > max) max = item.studentCount;
    }
    return max;
  }

  String get activeStudentRateText => _formatPercent(
    totalMahasiswa == 0 ? 0 : activeMahasiswa / totalMahasiswa,
  );

  String get krsApprovedRateText =>
      _formatPercent(totalKrs == 0 ? 0 : krsApproved / totalKrs);

  String get attendanceRateText => _formatPercent(attendanceRate);

  factory _AdminUniversitySnapshot.from(MockService service) {
    final prodiToFakultas = <String, String>{};
    final prodiCountByFakultas = <String, int>{
      for (final fakultas in service.fakultas) fakultas.id: 0,
    };
    final mahasiswaCountByFakultas = <String, int>{
      for (final fakultas in service.fakultas) fakultas.id: 0,
    };

    for (final prodi in service.prodi) {
      prodiToFakultas[prodi.id] = prodi.fakultasId;
      prodiCountByFakultas[prodi.fakultasId] =
          (prodiCountByFakultas[prodi.fakultasId] ?? 0) + 1;
    }

    var activeMahasiswa = 0;
    for (final mahasiswa in service.mahasiswa) {
      if (mahasiswa.status == StatusMahasiswa.aktif) activeMahasiswa++;
      final fakultasId = prodiToFakultas[mahasiswa.prodiId];
      if (fakultasId != null) {
        mahasiswaCountByFakultas[fakultasId] =
            (mahasiswaCountByFakultas[fakultasId] ?? 0) + 1;
      }
    }

    var krsDraft = 0;
    var krsSubmitted = 0;
    var krsApproved = 0;
    var krsRejected = 0;
    final studentsWithKrs = <String>{};
    final participantCountByClass = <String, int>{};
    for (final krs in service.krs) {
      studentsWithKrs.add(krs.mahasiswaId);
      participantCountByClass[krs.kelasId] =
          (participantCountByClass[krs.kelasId] ?? 0) + 1;
      switch (krs.status) {
        case KrsStatus.draft:
          krsDraft++;
        case KrsStatus.diajukan:
          krsSubmitted++;
        case KrsStatus.disetujui:
          krsApproved++;
        case KrsStatus.ditolak:
          krsRejected++;
      }
    }

    var fullClassCount = 0;
    for (final kelas in service.kelas) {
      final participants = participantCountByClass[kelas.id] ?? 0;
      if (participants >= kelas.kapasitas) fullClassCount++;
    }

    var attended = 0;
    for (final presensi in service.presensi) {
      if (presensi.statusKehadiran.toLowerCase() == 'hadir') attended++;
    }

    final now = DateTime.now();
    final krsPhase = service.faseKrs
        .where((fase) => fase.tahunAjaranId == service.tahunAjaranAktif.id)
        .toList();
    final activePhase = krsPhase.where((fase) => fase.berlangsungPada(now));
    final krsPhaseText = activePhase.isNotEmpty
        ? 'Berlangsung'
        : (krsPhase.isEmpty ? 'Belum diatur' : krsPhase.first.statusPada(now));

    final facultyLoads = [
      for (final fakultas in service.fakultas)
        _FacultyLoad(
          name: fakultas.nama,
          prodiCount: prodiCountByFakultas[fakultas.id] ?? 0,
          studentCount: mahasiswaCountByFakultas[fakultas.id] ?? 0,
        ),
    ]..sort((a, b) => b.studentCount.compareTo(a.studentCount));

    return _AdminUniversitySnapshot(
      totalFakultas: service.fakultas.length,
      totalProdi: service.prodi.length,
      totalMahasiswa: service.mahasiswa.length,
      activeMahasiswa: activeMahasiswa,
      totalDosen: service.dosen.length,
      totalKelas: service.kelas.length,
      totalUsers: service.users.length,
      totalKrs: service.krs.length,
      krsDraft: krsDraft,
      krsSubmitted: krsSubmitted,
      krsApproved: krsApproved,
      krsRejected: krsRejected,
      fullClassCount: fullClassCount,
      studentsWithoutKrs: service.mahasiswa.length - studentsWithKrs.length,
      attendanceRate: service.presensi.isEmpty
          ? 0
          : attended / service.presensi.length,
      activeAcademicYear: service.tahunAjaranAktif.label,
      krsPhaseText: krsPhaseText,
      krsPhaseActive: activePhase.isNotEmpty,
      facultyLoads: facultyLoads,
    );
  }
}

class _FacultyLoad {
  const _FacultyLoad({
    required this.name,
    required this.prodiCount,
    required this.studentCount,
  });

  final String name;
  final int prodiCount;
  final int studentCount;
}

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final remaining = text.length - i;
    buffer.write(text[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return buffer.toString();
}

String _formatPercent(num value) => '${(value * 100).round()}%';

class AdminProdiDashboard extends StatelessWidget {
  const AdminProdiDashboard({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    final prodiId = user.scopeId;
    final mahasiswaCount = service.mahasiswa
        .where((item) => item.prodiId == prodiId)
        .length;
    final dosenCount = service.dosen
        .where((item) => item.prodiId == prodiId)
        .length;
    final mataKuliahCount = service.mataKuliah
        .where((item) => item.prodiId == prodiId)
        .length;
    final kelasCount = service.kelas.where((kelas) {
      final mataKuliah = service.mataKuliah.where(
        (item) => item.kode == kelas.mataKuliahId,
      );
      return mataKuliah.isNotEmpty && mataKuliah.first.prodiId == prodiId;
    }).length;
    final ruanganCount = service.ruangan.length;

    return AppScaffold(
      title: 'Dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.name.substring(0, 1),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 24,
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
                          user.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.role.label,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width >= 1180
                ? 5
                : MediaQuery.sizeOf(context).width >= 760
                ? 3
                : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: MediaQuery.sizeOf(context).width >= 900
                ? 1.85
                : 1.45,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _DashboardStatCard(
                icon: Icons.groups_outlined,
                label: 'Mahasiswa Aktif',
                value: mahasiswaCount,
              ),
              _DashboardStatCard(
                icon: Icons.co_present_outlined,
                label: 'Dosen',
                value: dosenCount,
              ),
              _DashboardStatCard(
                icon: Icons.menu_book_outlined,
                label: 'Mata Kuliah',
                value: mataKuliahCount,
              ),
              _DashboardStatCard(
                icon: Icons.meeting_room_outlined,
                label: 'Ruang Kelas',
                value: ruanganCount,
              ),
              _DashboardStatCard(
                icon: Icons.class_outlined,
                label: 'Kelas Kuliah',
                value: kelasCount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface.withValues(alpha: 0.62),
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

class ProfileView extends StatelessWidget {
  const ProfileView({required this.user, required this.onLogout, super.key});

  final User user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profil',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.name.substring(0, 1),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(user.tingkatPimpinan?.label ?? user.role.label),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
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
}

class _RoleNavConfig {
  const _RoleNavConfig({
    required this.destinations,
    required this.pageBuilders,
  });

  final List<NavigationDestination> destinations;
  final List<_RolePageBuilder> Function(
    User user,
    VoidCallback logout,
    ValueChanged<int> selectTab,
  )
  pageBuilders;

  factory _RoleNavConfig.fromUser(User currentUser) {
    // Inilah pusat routing multi-role:
    // setiap role mendapatkan daftar tab dan halaman yang berbeda.
    switch (currentUser.role) {
      case Role.adminUniversitas:
        return _RoleNavConfig(
          destinations: _adminDestinations,
          pageBuilders: (user, logout, selectTab) => [
            () => _AdminUniversitasHome(user: user, selectTab: selectTab),
            () => const FakultasView(),
            () => const GlobalDataView(),
            () => const ImportExportDataView(),
            () => UserManagementView(currentUser: user),
            () => ProfileView(user: user, onLogout: logout),
          ],
        );
      case Role.adminFakultas:
        return _RoleNavConfig(
          destinations: _adminDestinations,
          pageBuilders: (user, logout, selectTab) => [
            () => RoleDashboard(
              user: user,
              flow: const [
                'Fakultas mengelola Prodi',
                'Operator Prodi mengelola mahasiswa, dosen, mata kuliah, dan kelas',
              ],
              actions: const [],
            ),
            () => ProdiView(fakultasId: user.scopeId),
            () => ProdiScopeDataView(fakultasId: user.scopeId),
            () => UserManagementView(currentUser: user),
            () => ProfileView(user: user, onLogout: logout),
          ],
        );
      case Role.adminProdi:
        return _RoleNavConfig(
          destinations: _adminProdiDestinations,
          pageBuilders: (user, logout, selectTab) => [
            () => AdminProdiDashboard(user: user),
            () => MahasiswaManagementView(prodiId: user.scopeId),
            () => StatusMahasiswaManagementView(prodiId: user.scopeId),
            () => DosenManagementView(prodiId: user.scopeId),
            () => MataKuliahManagementView(prodiId: user.scopeId),
            () => const RuanganManagementView(),
            () => KelasManagementView(prodiId: user.scopeId),
            () => ProdiUserView(prodiId: user.scopeId),
            () => ProfileView(user: user, onLogout: logout),
          ],
        );
      case Role.dosen:
        return _RoleNavConfig(
          destinations: _dosenDestinations,
          pageBuilders: (user, logout, selectTab) => [
            () => DosenDashboardView(
              user: user,
              onOpenKelas: () => selectTab(1),
              onOpenNilai: () => selectTab(2),
              onOpenValidasiKrs: () => selectTab(3),
              onOpenTugas: () => selectTab(4),
              onOpenBimbingan: () => selectTab(5),
            ),
            () => DosenKelasView(dosenId: user.scopeId),
            () => DosenNilaiView(dosenId: user.scopeId),
            () => DosenKrsValidationView(dosenId: user.scopeId),
            () => DosenTugasView(dosenId: user.scopeId),
            () => DosenBimbinganView(dosenId: user.scopeId),
            () => DosenProfileView(user: user, onLogout: logout),
          ],
        );
      case Role.pimpinan:
        if (currentUser.tingkatPimpinan == TingkatPimpinan.korpro) {
          return _RoleNavConfig(
            destinations: _korproDestinations,
            pageBuilders: (user, logout, selectTab) => [
              () => KorproDashboardView(user: user),
              () => KorproMahasiswaView(user: user),
              () => KorproDosenView(user: user),
              () => KorproJadwalView(user: user),
              () => KorproPresensiOverviewView(user: user),
              () => ProfileView(user: user, onLogout: logout),
            ],
          );
        }
        if (currentUser.tingkatPimpinan == TingkatPimpinan.dekan) {
          return _RoleNavConfig(
            destinations: _dekanDestinations,
            pageBuilders: (user, logout, selectTab) => [
              () => DekanDashboardView(
                user: user,
                onOpenKrs: () => selectTab(2),
                onOpenPresensiMahasiswa: () => selectTab(3),
                onOpenPresensiDosen: () => selectTab(3),
                onOpenKelas: () => selectTab(1),
                onOpenLaporan: () => selectTab(4),
              ),
              () => PimpinanDataView(user: user),
              () => PimpinanKrsView(user: user),
              () => PimpinanPresensiView(user: user),
              () => PimpinanLaporanView(user: user),
              () => ProfileView(user: user, onLogout: logout),
            ],
          );
        }
        if (currentUser.tingkatPimpinan == TingkatPimpinan.rektor) {
          return _RoleNavConfig(
            destinations: _rektorDestinations,
            pageBuilders: (user, logout, selectTab) => [
              () => RektorDashboardView(
                user: user,
                onOpenData: () => selectTab(1),
                onOpenKrs: () => selectTab(2),
                onOpenPresensi: () => selectTab(3),
                onOpenLaporan: () => selectTab(4),
              ),
              () => PimpinanDataView(user: user),
              () => PimpinanKrsView(user: user),
              () => PimpinanPresensiView(user: user),
              () => PimpinanLaporanView(user: user),
              () => ProfileView(user: user, onLogout: logout),
            ],
          );
        }
        return _RoleNavConfig(
          destinations: _pimpinanDestinations,
          pageBuilders: (user, logout, selectTab) => [
            () => PimpinanDashboardView(
              user: user,
              onOpenPresensi: () => selectTab(3),
            ),
            () => PimpinanDataView(user: user),
            () => PimpinanKrsView(user: user),
            () => PimpinanPresensiView(user: user),
            () => ProfileView(user: user, onLogout: logout),
          ],
        );
      case Role.mahasiswa:
        return _RoleNavConfig(
          destinations: _mahasiswaDestinations,
          pageBuilders: (user, logout, selectTab) => [
            () => MahasiswaDashboardView(
              user: user,
              onOpenKrs: () => selectTab(1),
              onOpenJadwal: () => selectTab(2),
              onOpenNilai: () => selectTab(3),
              onOpenKegiatan: () => selectTab(4),
            ),
            () => MahasiswaKrsView(mahasiswaId: user.scopeId),
            () => MahasiswaJadwalView(mahasiswaId: user.scopeId),
            () => MahasiswaNilaiView(mahasiswaId: user.scopeId),
            () => MahasiswaKegiatanView(mahasiswaId: user.scopeId),
            () => MahasiswaPresensiView(mahasiswaId: user.scopeId),
            () => MahasiswaProfileView(user: user, onLogout: logout),
          ],
        );
    }
  }
}

class DashboardAction {
  const DashboardAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}

const _adminDestinations = [
  NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
  NavigationDestination(icon: Icon(Icons.storage_outlined), label: 'Data'),
  NavigationDestination(icon: Icon(Icons.tune_outlined), label: 'Manajemen'),
  NavigationDestination(
    icon: Icon(Icons.upload_file_outlined),
    label: 'Import',
  ),
  NavigationDestination(icon: Icon(Icons.group_outlined), label: 'User'),
  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
];

const _adminProdiDestinations = [
  NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
  NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Mahasiswa'),
  NavigationDestination(
    icon: Icon(Icons.manage_accounts_outlined),
    label: 'Status',
  ),
  NavigationDestination(icon: Icon(Icons.co_present_outlined), label: 'Dosen'),
  NavigationDestination(
    icon: Icon(Icons.menu_book_outlined),
    label: 'Mata Kuliah',
  ),
  NavigationDestination(
    icon: Icon(Icons.meeting_room_outlined),
    label: 'Ruangan',
  ),
  NavigationDestination(icon: Icon(Icons.class_outlined), label: 'Kelas'),
  NavigationDestination(icon: Icon(Icons.group_outlined), label: 'User'),
  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
];

const _dosenDestinations = [
  NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
  NavigationDestination(icon: Icon(Icons.class_outlined), label: 'Kelas'),
  NavigationDestination(icon: Icon(Icons.edit_note_outlined), label: 'Nilai'),
  NavigationDestination(icon: Icon(Icons.verified_outlined), label: 'KRS'),
  NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Tugas'),
  NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Bimbingan'),
  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
];

const _mahasiswaDestinations = [
  NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
  NavigationDestination(icon: Icon(Icons.playlist_add_check), label: 'KRS'),
  NavigationDestination(
    icon: Icon(Icons.calendar_month_outlined),
    label: 'Jadwal',
  ),
  NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Nilai'),
  NavigationDestination(icon: Icon(Icons.work_outline), label: 'Kegiatan'),
  NavigationDestination(
    icon: Icon(Icons.how_to_reg_outlined),
    label: 'Presensi',
  ),
  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
];

const _pimpinanDestinations = [
  NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    label: 'Dashboard',
  ),
  NavigationDestination(icon: Icon(Icons.storage_outlined), label: 'Data'),
  NavigationDestination(icon: Icon(Icons.fact_check_outlined), label: 'KRS'),
  NavigationDestination(
    icon: Icon(Icons.monitor_heart_outlined),
    label: 'Presensi',
  ),
  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
];

const _korproDestinations = [
  NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    label: 'Dashboard Prodi',
  ),
  NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Mahasiswa'),
  NavigationDestination(icon: Icon(Icons.co_present_outlined), label: 'Dosen'),
  NavigationDestination(
    icon: Icon(Icons.calendar_month_outlined),
    label: 'Jadwal Kuliah',
  ),
  NavigationDestination(
    icon: Icon(Icons.insights_outlined),
    label: 'Overview Presensi',
  ),
  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
];

const _dekanDestinations = [
  NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    label: 'Dashboard Fakultas',
  ),
  NavigationDestination(icon: Icon(Icons.class_outlined), label: 'Kelas'),
  NavigationDestination(icon: Icon(Icons.fact_check_outlined), label: 'KRS'),
  NavigationDestination(
    icon: Icon(Icons.monitor_heart_outlined),
    label: 'Presensi',
  ),
  NavigationDestination(icon: Icon(Icons.summarize_outlined), label: 'Laporan'),
  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
];

const _rektorDestinations = [
  NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    label: 'Dashboard Rektor',
  ),
  NavigationDestination(
    icon: Icon(Icons.account_balance_outlined),
    label: 'Data Universitas',
  ),
  NavigationDestination(
    icon: Icon(Icons.fact_check_outlined),
    label: 'KRS Universitas',
  ),
  NavigationDestination(
    icon: Icon(Icons.monitor_heart_outlined),
    label: 'Presensi',
  ),
  NavigationDestination(
    icon: Icon(Icons.summarize_outlined),
    label: 'Laporan Akademik',
  ),
  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
];
