import 'package:flutter/material.dart';

class AnimatedEntrance extends StatelessWidget {
  const AnimatedEntrance({
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 18),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    if (animationsDisabled) return child;

    final cappedDelay = delay.inMilliseconds.clamp(0, 180);
    const baseDuration = 280;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: baseDuration + cappedDelay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayedValue = cappedDelay == 0
            ? value
            : ((value * (baseDuration + cappedDelay) - cappedDelay) /
                      baseDuration)
                  .clamp(0.0, 1.0);
        return RepaintBoundary(
          child: Opacity(
            opacity: delayedValue,
            child: Transform.translate(
              offset: offset * (1 - delayedValue),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class BlueYellowBackground extends StatelessWidget {
  const BlueYellowBackground({
    required this.child,
    this.subtle = false,
    super.key,
  });

  final Widget child;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = subtle
        ? isDark
              ? const [Color(0xFF101214), Color(0xFF15181D)]
              : const [Color(0xFFF7F9FC), Color(0xFFFFFFFF)]
        : isDark
        ? const [Color(0xFF0F1113), Color(0xFF141820), Color(0xFF0F1113)]
        : const [Color(0xFFEAF2FF), Color(0xFFFFF8DD), Color(0xFFF7FAFF)];
    final glowColor1 = isDark
        ? const Color(0xFF4785FF)
        : const Color(0xFFFFC107);
    final glowColor2 = isDark
        ? const Color(0xFF1A3A6E)
        : const Color(0xFF0B57D0);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          if (!subtle) ...[
            Positioned(
              top: -80,
              right: -58,
              child: _GlowCircle(size: 190, color: glowColor1),
            ),
            Positioned(
              left: -90,
              bottom: 90,
              child: _GlowCircle(size: 210, color: glowColor2),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.14),
          ),
        ),
      ),
    );
  }
}
