import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_theme_dark.dart';

/// Builds the Material theme for the main app (Tourist + Tour Guide).
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryTeal),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.title),
    ),
  );
}

ThemeData buildAppDarkTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppThemeDark.actionPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppThemeDark.actionPrimary,
        onPrimary: AppThemeDark.textPrimary,
        secondary: AppThemeDark.actionSecondary,
        onSecondary: AppThemeDark.textInverse,
        surface: AppThemeDark.surfaceDefault,
        onSurface: AppThemeDark.textPrimary,
        error: AppThemeDark.statusError,
        onError: AppThemeDark.textInverse,
        outline: AppThemeDark.borderDefault,
      );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppThemeDark.backgroundPrimary,
    canvasColor: AppThemeDark.backgroundPrimary,
    cardColor: AppThemeDark.surfaceDefault,
    dividerColor: AppThemeDark.borderSubtle,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppThemeDark.textPrimary),
      bodyMedium: TextStyle(color: AppThemeDark.textPrimary),
      bodySmall: TextStyle(color: AppThemeDark.textSecondary),
      titleLarge: TextStyle(color: AppThemeDark.textPrimary),
      titleMedium: TextStyle(color: AppThemeDark.textPrimary),
      titleSmall: TextStyle(color: AppThemeDark.textPrimary),
      labelLarge: TextStyle(color: AppThemeDark.textPrimary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppThemeDark.backgroundPrimary,
      foregroundColor: AppThemeDark.textPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: AppThemeDark.iconPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeDark.backgroundSecondary,
      hintStyle: const TextStyle(color: AppThemeDark.textDisabled),
      labelStyle: const TextStyle(color: AppThemeDark.textSecondary),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppThemeDark.borderDefault),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppThemeDark.actionSecondary, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(AppThemeDark.textPrimary),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppThemeDark.actionPrimary
            : AppThemeDark.surfaceElevated,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(
        AppThemeDark.borderDefault,
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppThemeDark.surfaceDefault,
      titleTextStyle: TextStyle(color: AppThemeDark.textPrimary, fontSize: 20),
      contentTextStyle: TextStyle(color: AppThemeDark.textSecondary),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppThemeDark.surfaceElevated,
      contentTextStyle: TextStyle(color: AppThemeDark.textPrimary),
    ),
  );
}

/// Admin dashboard theme (formerly d_app_theme.dart).
class AdminTheme {
  AdminTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.adminBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.adminPrimary,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    ),
  );
}
