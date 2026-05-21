import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/animated_entrance.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Splash memberi jeda singkat sebelum user diarahkan ke halaman login.
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BlueYellowBackground(
        child: Center(
          child: AnimatedEntrance(
            offset: Offset(0, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SplashLogo(),
                SizedBox(height: 22),
                Text(
                  'SIAKAD',
                  style: TextStyle(
                    color: Color(0xFF102033),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Academic System Multi-Role',
                  style: TextStyle(
                    color: Color(0xFF5F6368),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 28),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Color(0xFFFFC107),
                    backgroundColor: Color(0xFFE3ECFF),
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

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102,
      height: 102,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B57D0), Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Icon(
        Icons.school_rounded,
        color: Color(0xFFFFC107),
        size: 52,
      ),
    );
  }
}
