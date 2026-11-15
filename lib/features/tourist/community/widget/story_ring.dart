import 'package:flutter/material.dart';

import 'package:triply/core/theme/app_colors.dart';
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
              radius: 36,
              backgroundColor: AppColors.chipGrey,
              foregroundImage: _avatarImage(story.authorAvatarUrl),
              onForegroundImageError: (_, _) {},
              child: Text(
                story.userName.isEmpty ? '?' : story.userName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 72,
            child: Text(
              story.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static ImageProvider? _avatarImage(String value) {
    final url = value.trim();
    final uri = Uri.tryParse(url);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      return null;
    }
    return NetworkImage(url);
  }
}
