import 'package:flutter/material.dart';

/// MDT App Theme — Material 3, Light Theme ONLY.
/// Per 08_COMPONENT_SPEC.md §8 Visual Rules.
///
/// Design priorities:
/// - High contrast text for field-ready readability
/// - Large touch targets (min 48px)
/// - Tablet-optimized spacing
/// - Semantic category accent colors
/// - Minimum font size = 16sp (per spec §8)

class MdtTheme {
  MdtTheme._();

  // ─── Category Accent Colors (per spec §8) ──────────────────────
  // operation = green, standby = blue, delay = yellow, breakdown = red
  static const Color operationColor = Color(0xFF19B05B); // green
  static const Color standbyColor = Color(0xFF3577F2);   // blue
  static const Color delayColor = Color(0xFFF5C518);     // yellow
  static const Color breakdownColor = Color(0xFFE63946); // red

  // ─── Brand Colors ────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF1B2838);
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryDarkColor = Color(0xFF0D47A1);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);

  // ─── Gradient Colors ─────────────────────────────────────────────
  static const Color gradientStart = Color(0xFFF0F4F8);
  static const Color gradientEnd = Color(0xFFE8EDF2);
  static const Color statusBarGradientStart = Color(0xFF1565C0);
  static const Color statusBarGradientEnd = Color(0xFF0D47A1);

  // ─── Text Colors ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1B2838);
  static const Color textSecondary = Color(0xFF3D4F5F);
  static const Color textTertiary = Color(0xFF616161);
  static const Color textHint = Color(0xFFB0B8C1);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      surface: surfaceColor,
      error: errorColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 56),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          color: Colors.grey.shade600,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          color: Colors.grey.shade400,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF212121),
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF424242),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF424242),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF616161),
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
