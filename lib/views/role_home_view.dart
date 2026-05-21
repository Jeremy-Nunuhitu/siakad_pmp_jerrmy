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

    // Role menentukan menu bawah dan halaman yang boleh diakses.
    final config = _RoleNavConfig.fromRole(user.role);
    final pageBuilders = config.pageBuilders(user, _logout, (index) {
      _selectIndex(index);
    });
    if (_index >= pageBuilders.length) _index = pageBuilders.length - 1;

    return Scaffold(
      body: _LazyRolePageStack(
        key: ValueKey('${user.id}-${user.role.name}'),
        index: _index,
        pageBuilders: pageBuilders,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectIndex,
        destinations: config.destinations,
      ),
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

class _LazyRolePageStack extends StatefulWidget {
  const _LazyRolePageStack({
    required this.index,
    required this.pageBuilders,
    super.key,
  });

  final int index;
  final List<_RolePageBuilder> pageBuilders;

  @override
  State<_LazyRolePageStack> createState() => _LazyRolePageStackState();
}

class _LazyRolePageStackState extends State<_LazyRolePageStack> {
  late List<Widget?> _pageCache;

  @override
  void initState() {
    super.initState();
    _pageCache = List<Widget?>.filled(widget.pageBuilders.length, null);
  }

  @override
  void didUpdateWidget(covariant _LazyRolePageStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageBuilders.length != widget.pageBuilders.length) {
      _pageCache = List<Widget?>.filled(widget.pageBuilders.length, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    _pageCache[widget.index] ??= RepaintBoundary(
      child: widget.pageBuilders[widget.index](),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < _pageCache.length; i++)
          if (_pageCache[i] != null)
            TickerMode(
              enabled: i == widget.index,
              child: Offstage(
                offstage: i != widget.index,
                child: _pageCache[i],
              ),
            ),
      ],
    );
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
                  Text(user.role.label),
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

  factory _RoleNavConfig.fromRole(Role role) {
    // Inilah pusat routing multi-role:
    // setiap role mendapatkan daftar tab dan halaman yang berbeda.
    switch (role) {
      case Role.adminUniversitas:
        return _RoleNavConfig(
          destinations: _adminDestinations,
          pageBuilders: (user, logout, selectTab) => [
            () => RoleDashboard(
              user: user,
              flow: const [
                'Admin mengelola data master dan akun pengguna',
                'Operator Prodi mengelola data akademik prodi',
              ],
              actions: const [],
            ),
            () => const FakultasView(),
            () => const GlobalDataView(),
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
          destinations: _adminDestinations,
          pageBuilders: (user, logout, selectTab) => [
            () => RoleDashboard(
              user: user,
              flow: const [
                'Input Mahasiswa, Dosen, Mata Kuliah',
                'Buka Kelas Kuliah dengan kapasitas peserta',
                'Kelas Kuliah menjadi pilihan KRS mahasiswa',
              ],
              actions: const [],
            ),
            () => ProdiCoreDataView(prodiId: user.scopeId),
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
  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
];
