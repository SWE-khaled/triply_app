import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Own story bubble extracted from `_MyStoryBubble` in `community_view.dart`.
class MyStoryBubble extends StatelessWidget {
  final bool hasStory;
  final VoidCallback onAddTap;
  final VoidCallback onViewTap;

  const MyStoryBubble({
    super.key,
    required this.hasStory,
    required this.onAddTap,
    required this.onViewTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasStory ? onViewTap : onAddTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasStory
                        ? AppColors.accentOrange
                        : AppColors.cardBorder,
                    width: hasStory ? 3 : 0,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.chipGrey,
                  child: Icon(
                    Icons.person,
                    color: AppColors.textGrey,
                    size: 28,
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Your Story',
            style: TextStyle(
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
