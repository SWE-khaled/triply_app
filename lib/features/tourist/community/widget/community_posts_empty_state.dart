import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

/// Subtle placeholder shown when the Community posts feed is empty.
class CommunityPostsEmptyState extends StatelessWidget {
  const CommunityPostsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No posts yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.title,
                  dark: AppThemeDark.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Be the first to share something!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.subtitle,
                  dark: AppThemeDark.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
