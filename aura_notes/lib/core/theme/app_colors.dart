import 'package:flutter/material.dart';

/// Centralized color palette for AuraNotes.
/// Scandinavian minimalism: muted, harmonious, high-contrast where it matters.
class AppColors {
  AppColors._();

  // ── Dark Theme (OLED Pure Black) ──
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF0A0A0A);
  static const darkSurfaceVariant = Color(0xFF141414);
  static const darkSidebar = Color(0xFF0D0D0D);
  static const darkBorder = Color(0xFF1E1E1E);
  static const darkBorderSubtle = Color(0xFF151515);
  static const darkTextPrimary = Color(0xFFF0F0F0);
  static const darkTextSecondary = Color(0xFF8A8A8A);
  static const darkTextTertiary = Color(0xFF555555);
  static const darkIcon = Color(0xFF777777);
  static const darkHover = Color(0xFF1A1A1A);
  static const darkSelected = Color(0xFF1F1F1F);

  // ── Light Theme (Off-White) ──
  static const lightBackground = Color(0xFFFAFAF9);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF5F5F3);
  static const lightSidebar = Color(0xFFF7F7F5);
  static const lightBorder = Color(0xFFE8E8E5);
  static const lightBorderSubtle = Color(0xFFF0F0ED);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF6B6B6B);
  static const lightTextTertiary = Color(0xFF9A9A9A);
  static const lightIcon = Color(0xFF888888);
  static const lightHover = Color(0xFFF0F0ED);
  static const lightSelected = Color(0xFFEBEBE8);

  // ── Accent Colors (shared) ──
  static const accent = Color(0xFF6C63FF); // Muted indigo-violet
  static const accentLight = Color(0xFF8B83FF);
  static const accentSubtle = Color(0x1A6C63FF); // 10% opacity
  static const accentDark = Color(0xFF5A52E0);

  // ── Semantic Colors ──
  static const error = Color(0xFFE55050);
  static const errorSubtle = Color(0x1AE55050);
  static const success = Color(0xFF4CAF7D);
  static const successSubtle = Color(0x1A4CAF7D);
  static const warning = Color(0xFFE5A040);
  static const warningSubtle = Color(0x1AE5A040);

  // ── Code Block Colors (Dark) ──
  static const codeBackgroundDark = Color(0xFF0F0F0F);
  static const codeBorderDark = Color(0xFF252525);

  // ── Code Block Colors (Light) ──
  static const codeBackgroundLight = Color(0xFFF5F5F0);
  static const codeBorderLight = Color(0xFFE0E0DB);
}
