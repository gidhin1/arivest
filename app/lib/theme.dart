import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArivestTheme {
  static const _primary = Color(0xFF0F6C5C);
  static const _secondary = Color(0xFFC0762B);
  static const _surface = Color(0xFFF7F3EC);
  static const _background = Color(0xFFF4F1EA);
  static const _onSurface = Color(0xFF1E2B23);
  static const _outline = Color(0xFF9C948A);

  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Colors.white,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: _surface,
      onSurface: _onSurface,
      background: _background,
      onBackground: _onSurface,
      outline: _outline,
    );

    final baseText = GoogleFonts.workSansTextTheme();
    final headingText = GoogleFonts.merriweatherTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
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
        backgroundColor: _background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingText.titleLarge?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _outline.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surface,
        side: BorderSide(color: _outline.withOpacity(0.2)),
        labelStyle: baseText.labelLarge?.copyWith(color: _onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: _outline.withOpacity(0.2),
      ),
    );
  }
}
