import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('See all', style: AppTextStyles.seeAll),
              Icon(Icons.chevron_right, size: 16, color: Color(0xFF0E5560)),
            ],
          ),
        ),
      ],
    );
  }
}
