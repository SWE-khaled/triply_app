import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../common/AuthTourist/providers/auth_provider.dart'; // عدّل المسار لو مختلف

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
    final user = context.watch<AuthProvider>().user;
    final photoUrl = user?.photoURL;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

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
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.chipGrey,
                  backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                  onBackgroundImageError: hasPhoto ? (_, _) {} : null,
                  child: hasPhoto
                      ? null
                      : const Icon(
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