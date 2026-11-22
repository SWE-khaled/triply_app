import 'package:flutter/material.dart';

/// Light theme tokens.
///
/// Mirrors every name in [AppThemeDark] so [AppPalette] can switch between the
/// two palettes without a single call site changing. Values are the original
/// Triply light colors, recovered from the pre-dark-mode palette.
class AppThemeLight {
  AppThemeLight._();

  // ---------------- text ----------------
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF7A8A8E);
  static const Color textTertiary = Color(0xFF8A8A8A);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFF9AA9AD);

  // ---------------- background ----------------
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF7F8F8);
  static const Color backgroundTertiary = Color(0xFFF2F4F4);

  // ---------------- surface ----------------
  static const Color surfaceDefault = Color(0xFFFFFFFF);

  /// Neutral one-step-above-surface grey. Brand tints have their own token
  /// ([surfaceSelected]) so chips/circles/cards don't all turn teal in light
  /// mode the way they did when this alias pointed at `primaryLight`.
  static const Color surfaceElevated = Color(0xFFF2F4F4);
  static const Color surfaceSelected = Color(0xFFEAF3F4);
  static const Color surfacePressed = Color(0xFFE8ECEC);

  /// Kept from the original light palette (guide names / account rows).
  static const Color guidesName = Color(0xFF235D59);

  // ---------------- border ----------------
  static const Color borderDefault = Color(0xFFE3E6E8);
  static const Color borderSubtle = Color(0xFFE5EAEA);
  static const Color borderStrong = Color(0xFF0E5261);

  // ---------------- action ----------------
  static const Color actionPrimary = Color(0xFF0C4A56);
  static const Color actionPrimaryHover = Color(0xFF0E5261);
  static const Color actionPrimaryPressed = Color(0xFF0E4A56);
  static const Color actionSecondary = Color(0xFF196B7D);
  static const Color actionDisabled = Color(0xFFF0F3F3);

  // ---------------- status ----------------
  static const Color statusSuccess = Color(0xFF0E7B6B);
  static const Color statusWarning = Color(0xFFD8B66A);
  static const Color statusError = Color(0xFFD4504A);
  static const Color statusInfo = Color(0xFF4DA7A0);
  static const Color statusErrorHover = Color(0xFFE07B39);
  static const Color statusErrorPressed = Color(0xFFE86A2C);

  // ---------------- icon ----------------
  static const Color iconPrimary = Color(0xFF0E5261);
  static const Color iconSecondary = Color(0xFF6E8B90);

  // ---------------- fixed-foreground ----------------
  /// Text over photos/brand surfaces stays light in both themes.
  static const Color onImage = Color(0xFFFFFFFF);

  // ---------------- overlay ----------------
  static const Color overlayScrim = Color(0x1A000000);

  // ---------------- original light-only aliases ----------------
  /// Exact values from the pre-dark palette for call sites that used a
  /// dedicated color instead of one of the generic tokens above. Dark mode
  /// keeps using its own token for each of these.
  static const Color inputFill = Color(0xFFF2F2F2);
  static const Color storyBg = Color(0xFFFFF8ED);
  static const Color star = Color(0xFFF5A623);
  static const Color guidedTourBg = Color(0x264DA7A0);
  static const Color dateText = Color(0xFF526B72);
  static const Color fieldBackground = Color(0xFFF4F5F6);
  static const Color lightCircleBg = Color(0xFFEFF3F3);
  static const Color adminPrimaryLight = Color(0xFFDEF0EE);
  static const Color adminBackground = Color(0xFFECF0F5);
  static const Color tabUnselected = Color(0xFFFBF7EF);
  static const Color mutedTeal = Color(0xFF7FA8AC);
  static const Color darkTealEnd = Color(0xFF1C6670);
  static const Color signInDark = Color(0xFF14555F);
  static const Color successTeal = Color(0xFF3FAE9A);
  static const Color iconGrey = Color(0xFF9AA5A9);
  static const Color bottomNavUnselected = Color(0xFFB0BEC5);
  static const Color primaryTeal = Color(0xFF0E5261);
}
