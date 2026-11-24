import 'package:flutter/material.dart';

/// Dark theme colors
/// Each name matches the design token (text/primary -> textPrimary)
class AppThemeDark {
  AppThemeDark._();

  // ---------------- text ----------------
  static const Color textPrimary = Color(
    0xFFF3F7F6,
  ); // text/primary - neutral/light-text
  static const Color textSecondary = Color(
    0xFFCFD9DA,
  ); // text/secondary - neutral/200
  static const Color textTertiary = Color(
    0xFFCFD9DA,
  ); // text/tertiary - neutral/200
  static const Color textInverse = Color(
    0xFF102027,
  ); // text/inverse - neutral/950
  static const Color textDisabled = Color(
    0xFF75888C,
  ); // text/disabled - neutral/400
  static const Color homeSectionTitle = Color(0xFFE8F1F2);
  static const Color homeSeeAll = Color(0xFF6FD3C3);

  // ---------------- background ----------------
  static const Color backgroundPrimary = Color(
    0xFF102027,
  ); // background/primary - neutral/950
  static const Color backgroundSecondary = Color(
    0xFF16282F,
  ); // background/secondary - neutral/900
  static const Color backgroundTertiary = Color(
    0xFF1C3037,
  ); // background/tertiary - neutral/850

  // ---------------- surface ----------------
  static const Color surfaceDefault = Color(
    0xFF16282F,
  ); // surface/default - neutral/900
  static const Color surfaceElevated = Color(
    0xFF253A41,
  ); // surface/elevated - neutral/800
  static const Color surfaceSelected = Color(
    0xFF253A41,
  ); // surface/selected - neutral/800
  static const Color surfacePressed = Color(
    0xFF304A52,
  ); // surface/pressed - nile/pressed-dark
  static const Color homeGuideSurface = Color(0xFF172B33);

  // ---------------- border ----------------
  static const Color borderDefault = Color(
    0xFF5A6E73,
  ); // border/default - neutral/500
  static const Color borderSubtle = Color(
    0xFF253A41,
  ); // border/subtle - neutral/800
  static const Color borderStrong = Color(
    0xFFCFD9DA,
  ); // border/strong - neutral/200
  static const Color homeGuideBorder = Color(0xFF244552);

  // ---------------- home guide card ----------------
  static const Color homeGuideName = Color(0xFFFFFFFF);
  static const Color homeGuideVerified = Color(0xFF4FD1C5);
  static const Color homeGuideRating = Color(0xFFFFC83D);
  static const Color homeGuideSecondary = Color(0xFF9FB6BC);
  static const Color homeGuidePrice = Color(0xFFFF8A4C);

  // ---------------- action ----------------
  static const Color actionPrimary = Color(
    0xFF0E5261,
  ); // action/primary - brand/deep-nile
  static const Color actionPrimaryHover = Color(
    0xFF0A414D,
  ); // action/primary-hover - nile/800
  static const Color actionPrimaryPressed = Color(
    0xFF083642,
  ); // action/primary-pressed - nile/900
  static const Color actionSecondary = Color(
    0xFF94D4CC,
  ); // action/secondary - nile/300
  static const Color actionDisabled = Color(
    0xFF253A41,
  ); // action/disabled - neutral/800

  // ---------------- status ----------------
  static const Color statusSuccess = Color(
    0xFF8AD9AA,
  ); // status/success - status/success-light
  static const Color statusWarning = Color(
    0xFFF1CB78,
  ); // status/warning - status/warning-light
  static const Color statusError = Color(
    0xFFFFA58B,
  ); // status/error - sunset/300
  static const Color statusInfo = Color(
    0xFF98C9F3,
  ); // status/info - status/info-light
  static const Color statusErrorHover = Color(
    0xFFFFC2AE,
  ); // status/error-hover - sunset/200
  static const Color statusErrorPressed = Color(
    0xFFE07A4F,
  ); // status/error-pressed - brand/sunset

  // ---------------- icon ----------------
  static const Color iconPrimary = Color(0xFF94D4CC); // icon/primary - nile/300
  static const Color iconSecondary = Color(
    0xFFCFD9DA,
  ); // icon/secondary - neutral/200

  // ---------------- overlay ----------------
  static const Color overlayScrim = Color(
    0xFF102027,
  ); // overlay/scrim - raw value
}
