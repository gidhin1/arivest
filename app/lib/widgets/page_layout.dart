import 'package:flutter/material.dart';

import '../design_system.dart';

class ResponsiveLayout {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;

  static bool isMobile(BuildContext context) {
    return DesignSystem.tokens.breakpoints.mobile.contains(width(context));
  }

  static bool isTablet(BuildContext context) {
    return DesignSystem.tokens.breakpoints.tablet.contains(width(context));
  }

  static bool isDesktop(BuildContext context) {
    final widthValue = width(context);
    final desktop = DesignSystem.tokens.breakpoints.desktop;
    return widthValue >= desktop.min;
  }

  static bool isWide(BuildContext context) {
    return DesignSystem.tokens.breakpoints.wide.contains(width(context));
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final widthValue = width(context);
    final tokens = DesignSystem.tokens;
    if (tokens.breakpoints.mobile.contains(widthValue)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
    }
    if (tokens.breakpoints.tablet.contains(widthValue)) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
  }
}

class PageLayout extends StatelessWidget {
  const PageLayout({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ?? ResponsiveLayout.pagePadding(context);

    return SingleChildScrollView(
      padding: resolvedPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
