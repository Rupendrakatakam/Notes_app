import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AuraNotes theme system.
/// Two themes: OLED Dark (pure black) and Off-White Light.
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────
  static ThemeData get dark {
    final textTheme = _buildTextTheme(AppColors.darkTextPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkBackground,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        primary: AppColors.accent,
        primaryContainer: AppColors.accentSubtle,
        onPrimary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorderSubtle,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleMedium,
        iconTheme: const IconThemeData(color: AppColors.darkIcon, size: 20),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 0.5,
        space: 0,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkIcon, size: 20),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        titleTextStyle: textTheme.titleMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.darkTextTertiary,
          fontSize: 14,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        textStyle: GoogleFonts.inter(
          color: AppColors.darkTextPrimary,
          fontSize: 12,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  // ─────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────
  static ThemeData get light {
    final textTheme = _buildTextTheme(AppColors.lightTextPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      canvasColor: AppColors.lightBackground,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightSurface,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        primary: AppColors.accent,
        primaryContainer: AppColors.accentSubtle,
        onPrimary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onSurfaceVariant: AppColors.lightTextSecondary,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightBorderSubtle,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleMedium,
        iconTheme: const IconThemeData(color: AppColors.lightIcon, size: 20),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 0.5,
        space: 0,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightIcon, size: 20),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        titleTextStyle: textTheme.titleMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.lightTextTertiary,
          fontSize: 14,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.lightBorder, width: 0.5),
        ),
        textStyle: GoogleFonts.inter(
          color: AppColors.lightTextPrimary,
          fontSize: 12,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  // ─────────────────────────────────────
  // TYPOGRAPHY
  // ─────────────────────────────────────
  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w700, color: baseColor, height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28, fontWeight: FontWeight.w600, color: baseColor, height: 1.25,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24, fontWeight: FontWeight.w600, color: baseColor, height: 1.3,
      ),
      // Headline
      headlineMedium: GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w600, color: baseColor, height: 1.35,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, color: baseColor, height: 1.35,
      ),
      // Title
      titleLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, color: baseColor, height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w500, color: baseColor, height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, color: baseColor, height: 1.4,
      ),
      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: baseColor, height: 1.6,
        letterSpacing: 0.1,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: baseColor, height: 1.55,
        letterSpacing: 0.1,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: baseColor, height: 1.5,
      ),
      // Label
      labelLarge: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w500, color: baseColor, height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500, color: baseColor, height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500, color: baseColor, height: 1.4,
        letterSpacing: 0.3,
      ),
    );
  }
}
