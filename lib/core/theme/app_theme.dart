import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Single app ThemeData. Assigned once in main.dart.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.tabSelectedBg),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.title),
    ),
  );
}
