import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystem {
  static DesignTokens _tokens = DesignTokens.fallback();

  static DesignTokens get tokens => _tokens;

  static Future<void> load() async {
    try {
      final raw = await rootBundle.loadString('assets/design_tokens.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _tokens = DesignTokens.fromJson(json);
    } catch (_) {
      _tokens = DesignTokens.fallback();
    }
  }

  static TextTheme bodyTextTheme() {
    final font = tokens.typography.bodyFont.toLowerCase();
    if (font.contains('inter')) {
      return GoogleFonts.interTextTheme();
    }
    if (font.contains('work sans')) {
      return GoogleFonts.workSansTextTheme();
    }
    return GoogleFonts.workSansTextTheme();
  }

  static TextTheme headingTextTheme() {
    final font = tokens.typography.headingFont.toLowerCase();
    if (font.contains('merriweather')) {
      return GoogleFonts.merriweatherTextTheme();
    }
    if (font.contains('playfair')) {
      return GoogleFonts.playfairDisplayTextTheme();
    }
    return GoogleFonts.merriweatherTextTheme();
  }
}

class DesignTokens {
  const DesignTokens({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.radii,
    required this.breakpoints,
  });

  final DesignColors colors;
  final DesignTypography typography;
  final DesignSpacing spacing;
  final DesignRadii radii;
  final DesignBreakpoints breakpoints;

  factory DesignTokens.fallback() {
    return DesignTokens(
      colors: DesignColors(
        primary: const Color(0xFF0F6C5C),
        secondary: const Color(0xFFC0762B),
        background: const Color(0xFFF4F1EA),
        surface: const Color(0xFFF7F3EC),
        onSurface: const Color(0xFF1E2B23),
        outline: const Color(0xFF9C948A),
        error: const Color(0xFFB3261E),
        success: const Color(0xFF1E7B4B),
        warning: const Color(0xFFC78B1B),
        info: const Color(0xFF2B5FC0),
      ),
      typography: const DesignTypography(
        headingFont: 'Merriweather',
        bodyFont: 'Work Sans',
      ),
      spacing: const DesignSpacing(
        base: 8,
        scale: [4, 8, 12, 16, 20, 24, 32, 40, 48],
      ),
      radii: const DesignRadii(
        input: 16,
        card: 20,
        chip: 12,
        button: 16,
      ),
      breakpoints: const DesignBreakpoints(
        mobile: DesignRange(min: 0, max: 599),
        tablet: DesignRange(min: 600, max: 899),
        desktop: DesignRange(min: 900, max: 1199),
        wide: DesignRange(min: 1200, max: 9999),
      ),
    );
  }

  factory DesignTokens.fromJson(Map<String, dynamic> json) {
    final fallback = DesignTokens.fallback();
    final colorsJson = _asMap(json['colors']);
    final typographyJson = _asMap(json['typography']);
    final spacingJson = _asMap(json['spacing']);
    final radiiJson = _asMap(json['radii']);
    final breakpointsJson = _asMap(json['breakpoints']);

    return DesignTokens(
      colors: DesignColors(
        primary: _colorFromHex(colorsJson['primary']) ?? fallback.colors.primary,
        secondary: _colorFromHex(colorsJson['secondary']) ?? fallback.colors.secondary,
        background: _colorFromHex(colorsJson['background']) ?? fallback.colors.background,
        surface: _colorFromHex(colorsJson['surface']) ?? fallback.colors.surface,
        onSurface: _colorFromHex(colorsJson['onSurface']) ?? fallback.colors.onSurface,
        outline: _colorFromHex(colorsJson['outline']) ?? fallback.colors.outline,
        error: _colorFromHex(colorsJson['error']) ?? fallback.colors.error,
        success: _colorFromHex(colorsJson['success']) ?? fallback.colors.success,
        warning: _colorFromHex(colorsJson['warning']) ?? fallback.colors.warning,
        info: _colorFromHex(colorsJson['info']) ?? fallback.colors.info,
      ),
      typography: DesignTypography(
        headingFont: _stringOr(typographyJson['headingFont'], fallback.typography.headingFont),
        bodyFont: _stringOr(typographyJson['bodyFont'], fallback.typography.bodyFont),
      ),
      spacing: DesignSpacing(
        base: _doubleOr(spacingJson['base'], fallback.spacing.base),
        scale: _doubleListOr(spacingJson['scale'], fallback.spacing.scale),
      ),
      radii: DesignRadii(
        input: _doubleOr(radiiJson['input'], fallback.radii.input),
        card: _doubleOr(radiiJson['card'], fallback.radii.card),
        chip: _doubleOr(radiiJson['chip'], fallback.radii.chip),
        button: _doubleOr(radiiJson['button'], fallback.radii.button),
      ),
      breakpoints: DesignBreakpoints(
        mobile: _rangeOr(breakpointsJson['mobile'], fallback.breakpoints.mobile),
        tablet: _rangeOr(breakpointsJson['tablet'], fallback.breakpoints.tablet),
        desktop: _rangeOr(breakpointsJson['desktop'], fallback.breakpoints.desktop),
        wide: _rangeOr(breakpointsJson['wide'], fallback.breakpoints.wide),
      ),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return {};
  }

  static String _stringOr(Object? value, String fallback) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return fallback;
  }

  static double _doubleOr(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  static List<double> _doubleListOr(Object? value, List<double> fallback) {
    if (value is List) {
      final parsed = value.whereType<num>().map((item) => item.toDouble()).toList();
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }
    return fallback;
  }

  static DesignRange _rangeOr(Object? value, DesignRange fallback) {
    if (value is List && value.length == 2) {
      final minVal = value[0];
      final maxVal = value[1];
      if (minVal is num && maxVal is num) {
        return DesignRange(min: minVal.toInt(), max: maxVal.toInt());
      }
    }
    return fallback;
  }

  static Color? _colorFromHex(Object? hex) {
    if (hex is! String) {
      return null;
    }
    final cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    if (cleaned.length == 8) {
      return Color(int.parse(cleaned, radix: 16));
    }
    return null;
  }
}

class DesignColors {
  const DesignColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.outline,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color outline;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
}

class DesignTypography {
  const DesignTypography({
    required this.headingFont,
    required this.bodyFont,
  });

  final String headingFont;
  final String bodyFont;
}

class DesignSpacing {
  const DesignSpacing({
    required this.base,
    required this.scale,
  });

  final double base;
  final List<double> scale;
}

class DesignRadii {
  const DesignRadii({
    required this.input,
    required this.card,
    required this.chip,
    required this.button,
  });

  final double input;
  final double card;
  final double chip;
  final double button;
}

class DesignRange {
  const DesignRange({required this.min, required this.max});

  final int min;
  final int max;

  bool contains(double width) => width >= min && width <= max;
}

class DesignBreakpoints {
  const DesignBreakpoints({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.wide,
  });

  final DesignRange mobile;
  final DesignRange tablet;
  final DesignRange desktop;
  final DesignRange wide;
}
