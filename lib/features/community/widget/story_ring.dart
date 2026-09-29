import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../model/community_story.dart';

/// Story ring extracted from `_StoryRing` in `community_view.dart`.
class StoryRing extends StatelessWidget {
  final CommunityStory story;
  final Color ringColor;
  final VoidCallback onTap;

  const StoryRing({
    super.key,
    required this.story,
    required this.ringColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentOrange, width: 3),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.chipGrey,
              backgroundImage: NetworkImage(story.imageUrl),
              onBackgroundImageError: (_, _) {},
            ),
          ),
          const SizedBox(height: 4),
          Text(
            story.userName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
