import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF070706);
  static const Color surface = Color(0xFF14181F);
  static const Color surfaceElevated = Color(0xFF1B202A);
  static const Color surfaceBorder = Color(0xFF262E3B);
  static const Color cardHeader = Color(0xFF181D26);

  // Neon Green Accents (EA FC 26 vibe)
  static const Color accentGreen = Color(0xFF38EF58);
  static const Color accentGreenLight = Color(0xFF5FF57A);
  static const Color accentGreenDark = Color(0xFF1EBB38);
  static const Color accentGreenGlow = Color(0x3338EF58);

  // Home / Away Tags
  static const Color homeGreen = Color(0xFF22C55E);
  static const Color homeGreenBg = Color(0xFF163321);
  static const Color awayRed = Color(0xFFEF4444);
  static const Color awayRedBg = Color(0xFF3A1719);

  // Stars & Ratings
  static const Color starGold = Color(0xFFFBBF24);
  static const Color starInactive = Color(0xFF3A4250);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textOnAccent = Color(0xFF080C08);

  // Buttons & Chips
  static const Color chipBackground = Color(0xFF1C222C);
  static const Color chipBorder = Color(0xFF2C3545);
  static const Color chipActiveText = Color(0xFF061408);
}

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = Typography.material2021().white;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentGreen,
        secondary: AppColors.accentGreenDark,
        surface: AppColors.surface,
        onPrimary: AppColors.textOnAccent,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme).copyWith(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: AppColors.textOnAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
