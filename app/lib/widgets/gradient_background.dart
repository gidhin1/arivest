import 'package:flutter/material.dart';

import '../design_system.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = DesignSystem.tokens.colors;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            colors.background,
            colors.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: _SoftCircle(
              size: 180,
              color: colors.primary.withOpacity(0.08),
            ),
          ),
          Positioned(
            top: 120,
            left: -70,
            child: _SoftCircle(
              size: 200,
              color: colors.secondary.withOpacity(0.08),
            ),
          ),
          Positioned(
            bottom: -80,
            right: 40,
            child: _SoftCircle(
              size: 220,
              color: colors.onSurface.withOpacity(0.06),
            ),
          ),
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
