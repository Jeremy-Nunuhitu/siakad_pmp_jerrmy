import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mock_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/dosen_viewmodel.dart';
import 'viewmodels/fakultas_viewmodel.dart';
import 'viewmodels/kelas_viewmodel.dart';
import 'viewmodels/krs_viewmodel.dart';
import 'viewmodels/mahasiswa_viewmodel.dart';
import 'viewmodels/mata_kuliah_viewmodel.dart';
import 'viewmodels/nilai_viewmodel.dart';
import 'viewmodels/prodi_viewmodel.dart';
import 'viewmodels/ruangan_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = await MockService.create();
  // Titik awal aplikasi: Flutter akan membangun widget SiakadApp.
  runApp(SiakadApp(service: service));
}

class SiakadApp extends StatelessWidget {
  const SiakadApp({super.key, required this.service});

  final MockService service;

  @override
  Widget build(BuildContext context) {
    // MockService memakai SQLite di native dan data in-memory di Web.
    // Instance ini dibagikan ke semua ViewModel melalui Provider.
    return MultiProvider(
      providers: [
        // Provider di bawah membentuk alur data:
        // View membaca ViewModel, lalu ViewModel memanggil MockService.
        Provider<MockService>.value(value: service),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel(service)),
        ChangeNotifierProvider(create: (_) => FakultasViewModel(service)),
        ChangeNotifierProvider(create: (_) => ProdiViewModel(service)),
        ChangeNotifierProvider(create: (_) => MahasiswaViewModel(service)),
        ChangeNotifierProvider(create: (_) => DosenViewModel(service)),
        ChangeNotifierProvider(create: (_) => MataKuliahViewModel(service)),
        ChangeNotifierProvider(create: (_) => RuanganViewModel(service)),
        ChangeNotifierProvider(create: (_) => KelasViewModel(service)),
        ChangeNotifierProvider(create: (_) => KRSViewModel(service)),
        ChangeNotifierProvider(create: (_) => NilaiViewModel(service)),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, child) {
          // MaterialApp dibangun ulang saat tema berubah.
          // Halaman pertama selalu SplashView, lalu diarahkan ke LoginView.
          return MaterialApp(
            title: 'SIAKAD Jeremy',
            debugShowCheckedModeBanner: false,
            themeMode: themeVm.themeMode,
            theme: _buildTheme(),
            darkTheme: _buildDarkTheme(),
            home: const SplashView(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    // Tema terang dipakai sebagai gaya utama aplikasi SIAKAD.
    const primaryBlue = Color(0xFF0B57D0);
    const accentYellow = Color(0xFFFFC107);
    const ink = Color(0xFF102033);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: primaryBlue,
            brightness: Brightness.light,
          ).copyWith(
            primary: primaryBlue,
            secondary: accentYellow,
            tertiary: const Color(0xFF1E88E5),
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: ink,
          ),
      scaffoldBackgroundColor: const Color(0xFFF4F8FF),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: accentYellow.withValues(alpha: 0.35),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? primaryBlue
                : const Color(0xFF5F6368),
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primaryBlue
                : const Color(0xFF6B7280),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFFF4F8FF),
        foregroundColor: ink,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: const Color(0x140B57D0),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE8EEF8)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFFF8E1),
        selectedColor: accentYellow.withValues(alpha: 0.45),
        labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w700),
        side: BorderSide(color: accentYellow.withValues(alpha: 0.45)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDADCE0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDADCE0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 1.8),
        ),
        prefixIconColor: primaryBlue,
        suffixIconColor: primaryBlue,
        labelStyle: const TextStyle(color: Color(0xFF5F6368)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryBlue.withValues(alpha: 0.18),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    // Tema gelap memakai struktur komponen yang sama agar UI tetap konsisten.
    const primaryBlue = Color(0xFF4785FF);
    const accentYellow = Color(0xFFFFD54F);
    const darkSurface = Color(0xFF1A1C1E);
    const darkBg = Color(0xFF0F1113);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: primaryBlue,
            brightness: Brightness.dark,
          ).copyWith(
            primary: primaryBlue,
            secondary: accentYellow,
            surface: darkSurface,
            onSurface: Colors.white.withValues(alpha: 0.9),
            onPrimary: Colors.white,
          ),
      scaffoldBackgroundColor: darkBg,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        elevation: 3,
        indicatorColor: primaryBlue.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? primaryBlue
                : Colors.white54,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primaryBlue
                : Colors.white54,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: darkBg,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 1.8),
        ),
      ),
    );
  }
}
