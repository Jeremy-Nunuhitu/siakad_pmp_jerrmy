import 'package:flutter/material.dart';

import 'animated_entrance.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      offset: const Offset(0, 10),
      child: Card(
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
