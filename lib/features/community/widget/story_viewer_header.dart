import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Header extracted from `story_viewer_view.dart:289`.
class StoryViewerHeader extends StatelessWidget {
  final String userName;
  final String imageUrl;
  final bool isMine;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const StoryViewerHeader({
    super.key,
    required this.userName,
    required this.imageUrl,
    required this.isMine,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.chipGrey,
          backgroundImage: isMine ? null : NetworkImage(imageUrl),
          child: isMine
              ? const Icon(
                  Icons.person,
                  size: 18,
                  color: AppColors.textGrey,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (isMine)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: onDelete,
          ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: onClose,
        ),
      ],
    );
  }
}
