import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
          children: const [
            Text(
              'No posts yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.title,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Be the first to share something!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.subtitle),
            ),
          ],
        ),
      ),
    );
  }
}
