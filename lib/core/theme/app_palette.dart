import 'package:flutter/material.dart';

import 'app_theme_dark.dart';
import 'app_theme_light.dart';

/// Resolves the active color set for the current theme mode.
///
/// [current] is updated by `ThemeCubit` whenever the user switches theme (or
/// when the platform brightness changes while `ThemeMode.system` is active).
/// Every [AppColors] member delegates to this palette, so screens keep using
/// the same semantic names in both light and dark mode.
class AppPalette {
  const AppPalette(this.brightness);

  final Brightness brightness;

  static const AppPalette dark = AppPalette(Brightness.dark);
  static const AppPalette light = AppPalette(Brightness.light);

  /// The palette currently applied to the whole app. Dark by default so the
  /// very first frame matches the app's dark starting theme.
  static AppPalette current = dark;

  static AppPalette forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static AppPalette forMode(ThemeMode mode, Brightness platformBrightness) {
    switch (mode) {
      case ThemeMode.light:
        return light;
      case ThemeMode.dark:
        return dark;
      case ThemeMode.system:
        return forBrightness(platformBrightness);
    }
  }

  bool get isDark => brightness == Brightness.dark;

  /// Readable foreground for [actionPrimary]: light text on the light palette's
  /// deep-teal button, light-theme text on the dark palette's brighter surface.
  Color get onPrimary =>
      isDark ? AppThemeDark.textPrimary : AppThemeLight.textInverse;

  /// Foreground for text drawn on top of photos, always light.
  Color get onImage => isDark ? AppThemeDark.onImage : AppThemeLight.onImage;

  // ---------------- text ----------------
  Color get textPrimary =>
      isDark ? AppThemeDark.textPrimary : AppThemeLight.textPrimary;
  Color get textSecondary =>
      isDark ? AppThemeDark.textSecondary : AppThemeLight.textSecondary;
  Color get textTertiary =>
      isDark ? AppThemeDark.textTertiary : AppThemeLight.textTertiary;
  Color get textInverse =>
      isDark ? AppThemeDark.textInverse : AppThemeLight.textInverse;
  Color get textDisabled =>
      isDark ? AppThemeDark.textDisabled : AppThemeLight.textDisabled;

  /// Guide names / account rows: neutral grey in dark mode, the original
  /// deep-teal from the light palette in light mode.
  Color get guidesName =>
      isDark ? AppThemeDark.textSecondary : AppThemeLight.guidesName;

  // ---------------- background ----------------
  Color get backgroundPrimary =>
      isDark ? AppThemeDark.backgroundPrimary : AppThemeLight.backgroundPrimary;
  Color get backgroundSecondary => isDark
      ? AppThemeDark.backgroundSecondary
      : AppThemeLight.backgroundSecondary;
  Color get backgroundTertiary => isDark
      ? AppThemeDark.backgroundTertiary
      : AppThemeLight.backgroundTertiary;

  // ---------------- surface ----------------
  Color get surfaceDefault =>
      isDark ? AppThemeDark.surfaceDefault : AppThemeLight.surfaceDefault;
  Color get surfaceElevated =>
      isDark ? AppThemeDark.surfaceElevated : AppThemeLight.surfaceElevated;
  Color get surfaceSelected =>
      isDark ? AppThemeDark.surfaceSelected : AppThemeLight.surfaceSelected;
  Color get surfacePressed =>
      isDark ? AppThemeDark.surfacePressed : AppThemeLight.surfacePressed;

  // ---------------- border ----------------
  Color get borderDefault =>
      isDark ? AppThemeDark.borderDefault : AppThemeLight.borderDefault;
  Color get borderSubtle =>
      isDark ? AppThemeDark.borderSubtle : AppThemeLight.borderSubtle;
  Color get borderStrong =>
      isDark ? AppThemeDark.borderStrong : AppThemeLight.borderStrong;

  // ---------------- action ----------------
  Color get actionPrimary =>
      isDark ? AppThemeDark.actionPrimary : AppThemeLight.actionPrimary;
  Color get actionPrimaryHover => isDark
      ? AppThemeDark.actionPrimaryHover
      : AppThemeLight.actionPrimaryHover;
  Color get actionPrimaryPressed => isDark
      ? AppThemeDark.actionPrimaryPressed
      : AppThemeLight.actionPrimaryPressed;
  Color get actionSecondary =>
      isDark ? AppThemeDark.actionSecondary : AppThemeLight.actionSecondary;
  Color get actionDisabled =>
      isDark ? AppThemeDark.actionDisabled : AppThemeLight.actionDisabled;

  // ---------------- status ----------------
  Color get statusSuccess =>
      isDark ? AppThemeDark.statusSuccess : AppThemeLight.statusSuccess;
  Color get statusWarning =>
      isDark ? AppThemeDark.statusWarning : AppThemeLight.statusWarning;
  Color get statusError =>
      isDark ? AppThemeDark.statusError : AppThemeLight.statusError;
  Color get statusInfo =>
      isDark ? AppThemeDark.statusInfo : AppThemeLight.statusInfo;
  Color get statusErrorHover =>
      isDark ? AppThemeDark.statusErrorHover : AppThemeLight.statusErrorHover;
  Color get statusErrorPressed => isDark
      ? AppThemeDark.statusErrorPressed
      : AppThemeLight.statusErrorPressed;

  // ---------------- icon ----------------
  Color get iconPrimary =>
      isDark ? AppThemeDark.iconPrimary : AppThemeLight.iconPrimary;
  Color get iconSecondary =>
      isDark ? AppThemeDark.iconSecondary : AppThemeLight.iconSecondary;

  // ---------------- overlay ----------------
  Color get overlayScrim =>
      isDark ? AppThemeDark.overlayScrim : AppThemeLight.overlayScrim;

  // ---------------- aliases with original light-only values ----------------
  Color get primaryTeal =>
      isDark ? AppThemeDark.actionPrimary : AppThemeLight.primaryTeal;
  Color get mutedTeal =>
      isDark ? AppThemeDark.textSecondary : AppThemeLight.mutedTeal;
  Color get darkTealEnd =>
      isDark ? AppThemeDark.actionPrimaryHover : AppThemeLight.darkTealEnd;
  Color get signInDark =>
      isDark ? AppThemeDark.actionPrimary : AppThemeLight.signInDark;
  Color get fieldBackground =>
      isDark ? AppThemeDark.surfaceDefault : AppThemeLight.fieldBackground;
  Color get iconGrey =>
      isDark ? AppThemeDark.iconSecondary : AppThemeLight.iconGrey;
  Color get successTeal =>
      isDark ? AppThemeDark.statusSuccess : AppThemeLight.successTeal;
  Color get lightCircleBg =>
      isDark ? AppThemeDark.surfaceElevated : AppThemeLight.lightCircleBg;
  Color get inputFill =>
      isDark ? AppThemeDark.surfaceDefault : AppThemeLight.inputFill;
  Color get storyBg =>
      isDark ? AppThemeDark.surfaceElevated : AppThemeLight.storyBg;
  Color get dateText =>
      isDark ? AppThemeDark.textSecondary : AppThemeLight.dateText;
  Color get star => isDark ? AppThemeDark.statusWarning : AppThemeLight.star;
  Color get bottomNavUnselected =>
      isDark ? AppThemeDark.textDisabled : AppThemeLight.bottomNavUnselected;
  Color get guidedTourText =>
      isDark ? AppThemeDark.actionSecondary : AppThemeLight.statusInfo;
  Color get guidedTourBg =>
      isDark ? AppThemeDark.surfaceSelected : AppThemeLight.guidedTourBg;
  Color get tabUnselected =>
      isDark ? AppThemeDark.surfaceDefault : AppThemeLight.tabUnselected;
  Color get adminPrimaryLight =>
      isDark ? AppThemeDark.surfaceSelected : AppThemeLight.adminPrimaryLight;
  Color get adminBackground =>
      isDark ? AppThemeDark.backgroundPrimary : AppThemeLight.adminBackground;
  Color get price =>
      isDark ? AppThemeDark.statusErrorPressed : AppThemeLight.statusErrorHover;
}
