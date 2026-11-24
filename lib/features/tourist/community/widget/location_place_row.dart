import 'package:flutter/material.dart';

import 'package:triply/core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

/// Place row extracted from `location_picker_view.dart:181`.
class LocationPlaceRow extends StatelessWidget {
  final String place;
  final VoidCallback onTap;

  const LocationPlaceRow({super.key, required this.place, required this.onTap});

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
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                place,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppThemeColors.resolve(
                    context,
                    light: const Color(0xFF17343B),
                    dark: AppThemeDark.textPrimary,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.textGrey,
                dark: AppThemeDark.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
