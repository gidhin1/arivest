import 'package:flutter/material.dart';

import 'design_system.dart';

class ArivestTheme {
  static ThemeData light() {
    final tokens = DesignSystem.tokens;
    final colors = tokens.colors;

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: colors.primary,
      onPrimary: Colors.white,
      secondary: colors.secondary,
      onSecondary: Colors.white,
      error: colors.error,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.onSurface,
      background: colors.background,
      onBackground: colors.onSurface,
      outline: colors.outline,
    );

    final baseText = DesignSystem.bodyTextTheme();
    final headingText = DesignSystem.headingTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: baseText.copyWith(
        displayLarge: headingText.displayLarge,
        displayMedium: headingText.displayMedium,
        displaySmall: headingText.displaySmall,
        headlineLarge: headingText.headlineLarge,
        headlineMedium: headingText.headlineMedium,
        headlineSmall: headingText.headlineSmall,
        titleLarge: headingText.titleLarge,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingText.titleLarge?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radii.card),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radii.input),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radii.input),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radii.input),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radii.button),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        side: BorderSide(color: colors.outline.withOpacity(0.2)),
        labelStyle: baseText.labelLarge?.copyWith(color: colors.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline.withOpacity(0.2),
      ),
    );
  }
}
