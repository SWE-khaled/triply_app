import 'package:flutter/material.dart';

import 'package:triply/core/theme/app_colors.dart';
import '../theme/app_theme_colors.dart';
import '../theme/app_theme_dark.dart';
import 'circle_icon_button.dart';

/// Centered-title header row: back circle + title + trailing spacer.
/// Replaces composer header (`new_share_screen.dart:159`) and picker header
/// (`Location_picker_screen.dart:90`).
class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  const AppHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleIconButton(
          icon: Icons.chevron_left,
          onTap: onBack,
          backgroundColor: AppThemeColors.resolve(
            context,
            light: AppColors.chipGrey,
            dark: AppThemeDark.surfaceElevated,
          ),
          iconColor: AppThemeColors.resolve(
            context,
            light: Colors.black,
            dark: AppThemeDark.textPrimary,
          ),
          iconSize: 24,
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 0,
              color: AppThemeColors.resolve(
                context,
                light: const Color(0xFF17343B),
                dark: AppThemeDark.textPrimary,
              ),
            ),
          ),
        ),
        trailing ?? const SizedBox(width: 40),
      ],
    );
  }
}
