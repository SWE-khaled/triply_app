import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllTap;

  const SectionHeader({super.key, required this.title, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    final titleColor = AppThemeColors.resolve(
      context,
      light: AppColors.textDark,
      dark: AppThemeDark.homeSectionTitle,
    );
    final seeAllColor = AppThemeColors.resolve(
      context,
      light: AppColors.primaryTeal,
      dark: AppThemeDark.homeSeeAll,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle.copyWith(color: titleColor),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See all',
                style: AppTextStyles.seeAll.copyWith(color: seeAllColor),
              ),
              Icon(Icons.chevron_right, size: 16, color: seeAllColor),
            ],
          ),
        ),
      ],
    );
  }
}
