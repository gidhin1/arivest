import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7F3EC),
            Color(0xFFE7F1EE),
            Color(0xFFF2EDE3),
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
              color: const Color(0xFF0F6C5C).withOpacity(0.08),
            ),
          ),
          Positioned(
            top: 120,
            left: -70,
            child: _SoftCircle(
              size: 200,
              color: const Color(0xFFC0762B).withOpacity(0.08),
            ),
          ),
          Positioned(
            bottom: -80,
            right: 40,
            child: _SoftCircle(
              size: 220,
              color: const Color(0xFF1E2B23).withOpacity(0.06),
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
