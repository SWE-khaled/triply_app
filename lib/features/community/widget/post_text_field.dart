import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Composer text field extracted from `share_composer_view.dart:236`.
class PostTextField extends StatelessWidget {
  final TextEditingController controller;

  const PostTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        minLines: 3,
        onChanged: (_) {},
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText:
              "What's on your mind? Share your magical travel moment... ✨🇪🇬",
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            letterSpacing: 0,
            color: AppColors.textGrey,
          ),
        ),
      ),
    );
  }
}
