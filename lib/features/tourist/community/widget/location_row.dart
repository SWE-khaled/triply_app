import 'package:flutter/material.dart';

import 'package:triply/core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/location_tag_chip.dart';

/// Location row extracted from `share_composer_view.dart:264`.
class LocationRow extends StatelessWidget {
  final String? location;
  final VoidCallback onTap;

  const LocationRow({super.key, required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppThemeColors.resolve(
              context,
              light: AppColors.cardBorder,
              dark: AppThemeDark.borderSubtle,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.primaryTeal,
                dark: AppThemeDark.actionSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Add Location',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: 0,
                color: AppThemeColors.resolve(
                  context,
                  light: const Color(0xFF17343B),
                  dark: AppThemeDark.textPrimary,
                ),
              ),
            ),
            const Spacer(),
            if (location case final loc?) LocationTagChip(label: loc),
          ],
        ),
      ),
    );
  }
}
