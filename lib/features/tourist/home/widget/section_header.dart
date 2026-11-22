import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllTap;

  const SectionHeader({super.key, required this.title, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        GestureDetector(
          onTap: onSeeAllTap,
          child:  Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('See all', style: AppTextStyles.seeAll),
              Icon(Icons.chevron_right, size: 16, color: AppColors.iconPrimary),
            ],
          ),
        ),
      ],
    );
  }
}
