import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // OLED Dark Mode
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF0D0D0D);
  static const darkCard = Color(0xFF141414);
  static const darkBorder = Color(0xFF222222);
  static const darkText = Color(0xFFEEEEEE);
  static const darkSubtext = Color(0xFF888888);
  static const darkAccent = Color(0xFFB9A8FF); // soft lavender
  static const darkAccentSoft = Color(0x22B9A8FF);
  static const darkHover = Color(0xFF1A1A1A);
  static const darkSelection = Color(0xFF2A2550);

  // Off-White Light Mode
  static const lightBackground = Color(0xFFF9F7F2);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFF3F1EC);
  static const lightBorder = Color(0xFFE5E3DC);
  static const lightText = Color(0xFF1A1A1A);
  static const lightSubtext = Color(0xFF888880);
  static const lightAccent = Color(0xFF7C6FCD); // deeper lavender
  static const lightAccentSoft = Color(0x157C6FCD);
  static const lightHover = Color(0xFFEFEDE8);
  static const lightSelection = Color(0xFFE0DCF5);

  // Shared
  static const error = Color(0xFFFF6B6B);
  static const success = Color(0xFF6BCB77);
  static const warning = Color(0xFFFFD166);
  static const codeBackground = Color(0xFF1E1E2E);
}

class AppTextStyles {
  static TextStyle heading1(BuildContext context) => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle heading2(BuildContext context) => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle heading3(BuildContext context) => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle body(BuildContext context) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.65,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
  );

  static TextStyle mono = GoogleFonts.jetBrainsMono(fontSize: 13, height: 1.6);

  static TextStyle sidebarItem(BuildContext context) => GoogleFonts.inter(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
      primary: AppColors.darkAccent,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.darkAccentSoft,
      onSecondary: AppColors.darkAccent,
      outline: AppColors.darkBorder,
      surfaceContainerHighest: AppColors.darkCard,
      surfaceContainer: AppColors.darkSurface,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      hintStyle: TextStyle(
        color: AppColors.darkSubtext,
        fontFamily: GoogleFonts.inter().fontFamily,
        fontSize: 15,
      ),
    ),
    dividerColor: AppColors.darkBorder,
    splashColor: Colors.transparent,
    highlightColor: AppColors.darkHover,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    iconTheme: const IconThemeData(color: AppColors.darkSubtext, size: 18),
    cardTheme: const CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightText,
      primary: AppColors.lightAccent,
      onPrimary: Colors.white,
      secondary: AppColors.lightAccentSoft,
      onSecondary: AppColors.lightAccent,
      outline: AppColors.lightBorder,
      surfaceContainerHighest: AppColors.lightCard,
      surfaceContainer: AppColors.lightSurface,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      hintStyle: TextStyle(
        color: AppColors.lightSubtext,
        fontFamily: GoogleFonts.inter().fontFamily,
        fontSize: 15,
      ),
    ),
    dividerColor: AppColors.lightBorder,
    splashColor: Colors.transparent,
    highlightColor: AppColors.lightHover,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    iconTheme: const IconThemeData(color: AppColors.lightSubtext, size: 18),
    cardTheme: const CardThemeData(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );
}
