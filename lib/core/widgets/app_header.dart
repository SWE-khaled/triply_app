import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
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
          backgroundColor: AppColors.chipGrey,
          iconColor: Colors.black,
          iconSize: 24,
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 0,
              color: Color(0xFF17343B),
            ),
          ),
        ),
        trailing ?? const SizedBox(width: 40),
      ],
    );
  }
}
