import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_palette.dart';

/// Builds the Material theme for the main app (Tourist + Tour Guide).
///
/// All colors come from [AppPalette], which resolves the active light or dark
/// token set. Passing [brightness] keeps both themes available at once, even
/// while `ThemeMode.system` is selected.
ThemeData buildAppTheme({Brightness brightness = Brightness.dark}) {
  final p = AppPalette.forBrightness(brightness);
  final isDark = p.isDark;
  final onPrimary = p.onPrimary;

  ColorScheme buildScheme() => isDark
      ? ColorScheme.dark(
          primary: p.actionPrimary,
          onPrimary: onPrimary,
          secondary: p.actionSecondary,
          onSecondary: p.textInverse,
          tertiary: p.statusInfo,
          onTertiary: p.textInverse,
          surface: p.surfaceDefault,
          onSurface: p.textPrimary,
          surfaceContainerHighest: p.surfaceElevated,
          error: p.statusError,
          onError: p.textInverse,
        )
      : ColorScheme.light(
          primary: p.actionPrimary,
          onPrimary: onPrimary,
          secondary: p.actionSecondary,
          onSecondary: p.textInverse,
          tertiary: p.statusInfo,
          onTertiary: p.textInverse,
          surface: p.surfaceDefault,
          onSurface: p.textPrimary,
          surfaceContainerHighest: p.surfaceElevated,
          error: p.statusError,
          onError: p.textInverse,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: buildScheme(),
    scaffoldBackgroundColor: p.backgroundPrimary,
    canvasColor: p.backgroundPrimary,
    cardColor: p.surfaceDefault,
    dividerColor: p.borderSubtle,
    shadowColor: p.overlayScrim,
    hoverColor: p.surfaceElevated,
    splashColor: p.surfacePressed,
    highlightColor: p.surfacePressed,
    appBarTheme: AppBarTheme(
      backgroundColor: p.backgroundPrimary,
      foregroundColor: p.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: p.iconPrimary),
      actionsIconTheme: IconThemeData(color: p.iconPrimary),
    ),
    iconTheme: IconThemeData(color: p.iconPrimary),
    primaryIconTheme: IconThemeData(color: p.iconPrimary),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surfaceElevated,
      modalBackgroundColor: p.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceDefault,
      hintStyle: TextStyle(fontSize: 13, color: p.textDisabled),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: p.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: p.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: p.actionSecondary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: p.statusError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: p.statusError),
      ),
      labelStyle: TextStyle(color: p.textSecondary),
      floatingLabelStyle: TextStyle(color: p.actionSecondary),
      suffixIconColor: p.iconSecondary,
      prefixIconColor: p.iconSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.actionPrimary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: p.actionDisabled,
        disabledForegroundColor: p.textDisabled,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.actionPrimary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: p.actionDisabled,
        disabledForegroundColor: p.textDisabled,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.actionSecondary,
        side: BorderSide(color: p.borderDefault),
        disabledForegroundColor: p.textDisabled,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.actionSecondary,
        disabledForegroundColor: p.textDisabled,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? p.textDisabled
            : p.actionSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? p.actionPrimary
            : p.surfaceElevated,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? p.actionPrimary
            : p.surfaceElevated,
      ),
      checkColor: WidgetStateProperty.all(onPrimary),
      side: BorderSide(color: p.borderDefault),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? p.actionPrimary
            : p.iconSecondary,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.actionPrimary,
      linearTrackColor: p.surfaceElevated,
      circularTrackColor: p.surfaceElevated,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.actionPrimary,
      inactiveTrackColor: p.surfaceElevated,
      thumbColor: p.actionSecondary,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.surfaceElevated,
      contentTextStyle: TextStyle(color: p.textPrimary),
      actionTextColor: p.actionSecondary,
      behavior: SnackBarBehavior.floating,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      textStyle: TextStyle(color: p.textPrimary),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: p.backgroundPrimary,
      selectedItemColor: p.iconPrimary,
      unselectedItemColor: p.textDisabled,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.backgroundPrimary,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.surfaceSelected,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? p.iconPrimary
              : p.textDisabled,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? p.textPrimary
              : p.textDisabled,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surfaceElevated,
      selectedColor: p.actionPrimary,
      disabledColor: p.actionDisabled,
      checkmarkColor: onPrimary,
      side: BorderSide(color: p.borderSubtle),
      labelStyle: TextStyle(color: p.textPrimary),
      secondaryLabelStyle: TextStyle(color: p.textSecondary),
    ),
    dividerTheme: DividerThemeData(
      color: p.borderSubtle,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: p.iconPrimary,
      textColor: p.textPrimary,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: TextStyle(color: p.textPrimary),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: p.surfaceElevated,
      hourMinuteTextColor: p.textPrimary,
      dayPeriodTextColor: p.textSecondary,
      dialHandColor: p.actionPrimary,
      dialTextColor: p.textPrimary,
      entryModeIconColor: p.iconPrimary,
      helpTextStyle: TextStyle(color: p.textSecondary),
    ),
  );
}

/// Admin dashboard theme (formerly d_app_theme.dart).
class AdminTheme {
  AdminTheme._();

  static ThemeData theme({Brightness? brightness}) {
    final resolved = brightness ?? AppPalette.current.brightness;
    return ThemeData(
      useMaterial3: true,
      brightness: resolved,
      scaffoldBackgroundColor: AppColors.adminBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.adminPrimary,
        brightness: resolved,
      ),
      textTheme:
          GoogleFonts.interTextTheme(
            ThemeData(brightness: resolved).textTheme,
          ).apply(
            bodyColor: AppColors.adminTextPrimary,
            displayColor: AppColors.adminTextPrimary,
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.adminInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.adminDivider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.adminPrimary, width: 1.5),
        ),
        hintStyle: TextStyle(
          fontSize: 13,
          color: AppColors.adminTextMuted,
          fontFamily: 'Inter',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
    );
  }

  /// Kept for backwards compatibility with existing call sites.
  static ThemeData get light => theme();
}
