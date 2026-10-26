import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Circular avatar with the participant's initial as the offline fallback.
class ChatAvatar extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final double size;

  const ChatAvatar({
    super.key,
    required this.name,
    this.avatarUrl = '',
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = avatarUrl.trim();
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: trimmed.isEmpty
          ? Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            )
          : Image.network(
              trimmed,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
    );
  }
}
