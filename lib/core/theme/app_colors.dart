import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Central palette for the Triply app.
///
/// Every member delegates to [AppPalette], which resolves the active light or
/// dark token set. Call sites keep using `AppColors.<name>` unchanged; the
/// theme cubit swaps the palette when the user toggles the theme.
class AppColors {
  AppColors._();

  // =========================================================================
  // Theme tokens
  // =========================================================================
  static Color get backgroundPrimary => AppPalette.current.backgroundPrimary;
  static Color get backgroundSecondary =>
      AppPalette.current.backgroundSecondary;
  static Color get backgroundTertiary => AppPalette.current.backgroundTertiary;
  static Color get surfaceDefault => AppPalette.current.surfaceDefault;
  static Color get surfaceElevated => AppPalette.current.surfaceElevated;
  static Color get surfaceSelected => AppPalette.current.surfaceSelected;
  static Color get surfacePressed => AppPalette.current.surfacePressed;
  static Color get borderDefault => AppPalette.current.borderDefault;
  static Color get borderSubtle => AppPalette.current.borderSubtle;
  static Color get borderStrong => AppPalette.current.borderStrong;
  static Color get actionPrimary => AppPalette.current.actionPrimary;
  static Color get actionPrimaryHover => AppPalette.current.actionPrimaryHover;
  static Color get actionPrimaryPressed =>
      AppPalette.current.actionPrimaryPressed;
  static Color get actionSecondary => AppPalette.current.actionSecondary;
  static Color get actionDisabled => AppPalette.current.actionDisabled;
  static Color get statusSuccess => AppPalette.current.statusSuccess;
  static Color get statusWarning => AppPalette.current.statusWarning;
  static Color get statusError => AppPalette.current.statusError;
  static Color get statusInfo => AppPalette.current.statusInfo;
  static Color get statusErrorHover => AppPalette.current.statusErrorHover;
  static Color get statusErrorPressed => AppPalette.current.statusErrorPressed;
  static Color get iconPrimary => AppPalette.current.iconPrimary;
  static Color get iconSecondary => AppPalette.current.iconSecondary;
  static Color get textPrimary => AppPalette.current.textPrimary;
  static Color get textSecondary => AppPalette.current.textSecondary;
  static Color get textTertiary => AppPalette.current.textTertiary;
  static Color get textInverse => AppPalette.current.textInverse;
  static Color get textDisabled => AppPalette.current.textDisabled;
  static Color get overlayScrim => AppPalette.current.overlayScrim;
  static Color get onPrimary => AppPalette.current.onPrimary;
  static Color get onImage => AppPalette.current.onImage;

  // =========================================================================
  // Primary
  // =========================================================================
  static Color get primary => AppPalette.current.actionPrimary;
  static Color get primaryLight => AppPalette.current.surfaceSelected;
  static Color get primaryText => AppPalette.current.actionPrimary;
  static Color get primaryTeal => AppPalette.current.primaryTeal;
  static Color get guidesName => AppPalette.current.guidesName;
  static Color get deepNile => AppPalette.current.actionPrimary;
  static Color get nileCyan => AppPalette.current.actionSecondary;

  // =========================================================================
  // auth
  // =========================================================================
  static Color get darkTeal => AppPalette.current.actionPrimary;
  static Color get darkTealEnd => AppPalette.current.darkTealEnd;
  static Color get mutedTeal => AppPalette.current.mutedTeal;
  static Color get signInDark => AppPalette.current.signInDark;
  static Color get fieldBackground => AppPalette.current.fieldBackground;
  static Color get fieldBorder => AppPalette.current.borderDefault;
  static Color get iconGrey => AppPalette.current.iconGrey;
  static Color get successTeal => AppPalette.current.successTeal;
  static Color get lightCircleBg => AppPalette.current.lightCircleBg;

  // =========================================================================
  // Backgrounds & surfaces
  // =========================================================================
  static Color get pureWhite => AppPalette.current.onImage;
  static Color get softSand => AppPalette.current.backgroundSecondary;
  static Color get warmCream => AppPalette.current.backgroundSecondary;
  static Color get background => AppPalette.current.backgroundPrimary;
  static Color get pageBackground => AppPalette.current.backgroundSecondary;
  static Color get searchBg => AppPalette.current.backgroundTertiary;
  static Color get chatIconBg => AppPalette.current.surfaceElevated;
  static Color get inputFill => AppPalette.current.inputFill;
  static Color get storyBg => AppPalette.current.storyBg;

  // =========================================================================
  // Text
  // =========================================================================
  static Color get textDark => AppPalette.current.textPrimary;
  static Color get textGrey => AppPalette.current.textTertiary;
  static Color get subtitle => AppPalette.current.textSecondary;
  static Color get hint => AppPalette.current.textDisabled;
  static Color get dateText => AppPalette.current.dateText;
  static Color get guideLabel => AppPalette.current.textTertiary;
  static Color get title => AppPalette.current.textPrimary;
  static Color get titleDark => AppPalette.current.textPrimary;
  static Color get titleDetails => AppPalette.current.textPrimary;

  // =========================================================================
  // Borders & dividers
  // =========================================================================
  static Color get borderColor => AppPalette.current.borderSubtle;
  static Color get cardBorder => AppPalette.current.borderSubtle;
  static Color get cardShadow => AppPalette.current.overlayScrim;

  // =========================================================================
  // Accent
  // =========================================================================
  static Color get price => AppPalette.current.price;
  static Color get priceTeal => AppPalette.current.actionSecondary;
  static Color get accentOrange => AppPalette.current.statusErrorPressed;
  static Color get pin => AppPalette.current.statusErrorPressed;
  static Color get star => AppPalette.current.star;
  static Color get starGold => AppPalette.current.statusWarning;
  static Color get iconDetails => AppPalette.current.iconSecondary;

  // =========================================================================
  // Tabs
  // =========================================================================
  static Color get tabSelectedBg => AppPalette.current.actionPrimary;
  static Color get tabUnselectedBg => AppPalette.current.surfaceElevated;
  static Color get tabUnselected => AppPalette.current.tabUnselected;

  // =========================================================================
  // Bottom nav
  // =========================================================================
  static Color get bottomNavSelected => AppPalette.current.iconPrimary;
  static Color get bottomNavUnselected =>
      AppPalette.current.bottomNavUnselected;

  // =========================================================================
  // Guided tour
  // =========================================================================
  static Color get guidedTourText => AppPalette.current.guidedTourText;
  static Color get guidedTourBg => AppPalette.current.guidedTourBg;
  static Color get bulletGold => AppPalette.current.statusWarning;
  static Color get chipGrey => AppPalette.current.surfaceElevated;
  static Color get chipTextGrey => AppPalette.current.dateText;

  // =========================================================================
  // Admin Dashboard (prefix: admin)
  // =========================================================================
  static Color get adminPrimary => AppPalette.current.actionPrimary;
  static Color get adminPrimaryLight => AppPalette.current.adminPrimaryLight;

  static Color get adminBackground => AppPalette.current.adminBackground;
  static Color get adminCardBg => AppPalette.current.surfaceDefault;
  static Color get adminSidebarBg => AppPalette.current.backgroundSecondary;
  static Color get adminInputBg => AppPalette.current.surfaceDefault;
  static Color get adminDocumentPreviewBg => AppPalette.current.surfaceElevated;

  static Color get adminTextPrimary => AppPalette.current.textPrimary;
  static Color get adminTextSecondary => AppPalette.current.textSecondary;
  static Color get adminTextMuted => AppPalette.current.textDisabled;
  static Color get adminTextLink => AppPalette.current.actionSecondary;

  static Color get adminStatusActiveBg => AppPalette.current.surfaceDefault;
  static Color get adminStatusActiveText => AppPalette.current.statusSuccess;
  static Color get adminStatusPendingBg => AppPalette.current.surfaceElevated;
  static Color get adminStatusPendingText => AppPalette.current.statusWarning;
  static Color get adminStatusSuspendedBg => AppPalette.current.surfaceElevated;
  static Color get adminStatusSuspendedText => AppPalette.current.textSecondary;
  static Color get adminStatusCancelledBg => AppPalette.current.surfaceDefault;
  static Color get adminStatusCancelledText => AppPalette.current.statusError;

  static Color get adminDanger => AppPalette.current.statusError;
  static Color get adminDangerLight => AppPalette.current.surfaceDefault;

  static Color get adminDivider => AppPalette.current.borderSubtle;
  static Color get adminBorderLight => AppPalette.current.borderSubtle;

  static Color get adminSidebarActiveBg => AppPalette.current.actionPrimary;
  static Color get adminSidebarActiveText => AppPalette.current.textPrimary;
  static Color get adminSidebarInactiveText => AppPalette.current.textSecondary;

  static Color get adminLogoutRed => AppPalette.current.statusError;
  static Color get adminManageAllGreen => AppPalette.current.statusSuccess;
  static Color get adminPendingChipBg => AppPalette.current.surfaceElevated;
  static Color get adminPendingChipText => AppPalette.current.statusWarning;
  static Color get adminPositiveGreen => AppPalette.current.statusSuccess;
  static Color get adminStatBadgeBg => AppPalette.current.surfaceElevated;
  static Color get adminStatBadgeText => AppPalette.current.textSecondary;
}
