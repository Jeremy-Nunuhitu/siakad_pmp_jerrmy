import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_service.dart';
import '../utils/app_assets.dart';
import '../utils/app_helpers.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/animated_entrance.dart';
import 'role_home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController(text: '2406080046');
  final _password = TextEditingController(text: 'password');
  bool _hidePassword = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthViewModel>();
    final success = auth.login(_username.text, _password.text);
    if (!success) {
      showAppMessage(context, auth.errorMessage);
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RoleHomeView()),
    );
  }

  void _useAccount(_AccountInfo account) {
    setState(() {
      _username.text = account.username;
      _password.text = account.password;
    });
    showAppMessage(context, 'Kredensial disalin ke form login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _LoginBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 920;
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 48 : 20,
                    vertical: isWide ? 28 : 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(flex: 5, child: _BrandPanel()),
                              const SizedBox(width: 42),
                              SizedBox(
                                width: 420,
                                child: _LoginColumn(
                                  formKey: _formKey,
                                  username: _username,
                                  password: _password,
                                  hidePassword: _hidePassword,
                                  onTogglePassword: () {
                                    setState(
                                      () => _hidePassword = !_hidePassword,
                                    );
                                  },
                                  onLogin: _login,
                                  onUseAccount: _useAccount,
                                ),
                              ),
                            ],
                          )
                        : _LoginColumn(
                            formKey: _formKey,
                            username: _username,
                            password: _password,
                            hidePassword: _hidePassword,
                            onTogglePassword: () {
                              setState(() => _hidePassword = !_hidePassword);
                            },
                            onLogin: _login,
                            onUseAccount: _useAccount,
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppAssets.campusHero,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          cacheWidth: 1600,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF050A14).withValues(alpha: 0.94),
                      const Color(0xFF0B1020).withValues(alpha: 0.88),
                      const Color(0xFF101820).withValues(alpha: 0.84),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.90),
                      const Color(0xFFEAF2FF).withValues(alpha: 0.88),
                      const Color(0xFFFFF8DF).withValues(alpha: 0.82),
                    ],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _LoginPatternPainter(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.045)
                  : const Color(0xFF0B57D0).withValues(alpha: 0.055),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _LoginPatternPainter extends CustomPainter {
  const _LoginPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const gap = 48.0;

    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }

    final bandPaint = Paint()
      ..color = color.withValues(alpha: color.a * 1.8)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * 0.58, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.72, size.height)
      ..close();
    canvas.drawPath(path, bandPaint);
  }

  @override
  bool shouldRepaint(covariant _LoginPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedEntrance(
      offset: const Offset(-18, 0),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.school_rounded,
                color: scheme.onPrimary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SIAKAD Faiz Abdul Majid',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kelola data akademik, KRS, nilai, dosen, dan mahasiswa dalam satu ruang kerja yang lebih cepat dan tertata.',
              style: textTheme.titleMedium?.copyWith(
                height: 1.45,
                color: scheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 24),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _FeaturePill(icon: Icons.admin_panel_settings, label: 'Admin'),
                _FeaturePill(icon: Icons.groups_rounded, label: 'Prodi'),
                _FeaturePill(icon: Icons.badge_rounded, label: 'Dosen'),
                _FeaturePill(icon: Icons.person_rounded, label: 'Mahasiswa'),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: const [
                Expanded(
                  flex: 4,
                  child: _MetricCard(value: '4', label: 'Role akses'),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: _MetricCard(value: '1', label: 'Portal terpadu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.66),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginColumn extends StatelessWidget {
  const _LoginColumn({
    required this.formKey,
    required this.username,
    required this.password,
    required this.hidePassword,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onUseAccount,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController username;
  final TextEditingController password;
  final bool hidePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final ValueChanged<_AccountInfo> onUseAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedEntrance(
          child: _LoginCard(
            formKey: formKey,
            username: username,
            password: password,
            hidePassword: hidePassword,
            onTogglePassword: onTogglePassword,
            onLogin: onLogin,
          ),
        ),
        const SizedBox(height: 14),
        AnimatedEntrance(
          delay: const Duration(milliseconds: 160),
          child: _TestingAccountsCard(onUseAccount: onUseAccount),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.username,
    required this.password,
    required this.hidePassword,
    required this.onTogglePassword,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController username;
  final TextEditingController password;
  final bool hidePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shadowColor: scheme.primary.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.lock_open_rounded, color: scheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Masuk untuk melanjutkan',
                          style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: username,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Username atau NIM',
                  hintText: 'Contoh: 2406080046',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Username wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: password,
                obscureText: hidePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onLogin(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: onTogglePassword,
                    tooltip: hidePassword
                        ? 'Tampilkan password'
                        : 'Sembunyikan password',
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Password minimal 1 karakter'
                    : null,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Gunakan password: password',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.56),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onLogin,
                icon: const Icon(Icons.login_rounded),
                label: const Text('Masuk Sekarang'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestingAccountsCard extends StatelessWidget {
  const _TestingAccountsCard({required this.onUseAccount});

  final ValueChanged<_AccountInfo> onUseAccount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
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
                      const Text(
                        'Akun Testing',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Pilih akun untuk mengisi form otomatis',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.58),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.manage_accounts_rounded, color: scheme.primary),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<MockService>(
              builder: (context, mock, child) {
                final allAccounts = mock.demoAccounts
                    .map(
                      (account) => _AccountInfo(
                        account.name,
                        account.username,
                        account.password,
                        account.role,
                      ),
                    )
                    .toList(growable: false);

                return SizedBox(
                  height: 174,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: allAccounts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final account = allAccounts[index];
                      return _AccountTile(
                        account: account,
                        onTap: () => onUseAccount(account),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, required this.onTap});

  final _AccountInfo account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.055),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(_roleIcon(account.role), color: scheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${account.username} - ${account.role}',
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
              const SizedBox(width: 8),
              Icon(Icons.content_copy_rounded, size: 18, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  IconData _roleIcon(String role) {
    return switch (role.toLowerCase()) {
      'admin' => Icons.admin_panel_settings_rounded,
      'dosen' => Icons.badge_rounded,
      'mahasiswa' => Icons.person_rounded,
      _ => Icons.groups_rounded,
    };
  }
}

class _AccountInfo {
  final String name;
  final String username;
  final String password;
  final String role;

  const _AccountInfo(this.name, this.username, this.password, this.role);
}
