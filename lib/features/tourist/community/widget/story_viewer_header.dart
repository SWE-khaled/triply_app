import 'package:flutter/material.dart';

import 'package:triply/core/theme/app_colors.dart';

/// Header extracted from `story_viewer_view.dart:289`.
class StoryViewerHeader extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final bool isMine;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const StoryViewerHeader({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.isMine,
    required this.onDelete,
    required this.onClose,
  });

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

  @override
  Widget build(BuildContext context) {
    final avatar = _avatarImage(avatarUrl);

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.chipGrey,
          foregroundImage: avatar,
          onForegroundImageError: avatar == null ? null : (_, _) {},
          child:  Icon(Icons.person, size: 18, color: AppColors.textGrey),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            userName,
            style:  TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (isMine)
          IconButton(
            icon:  Icon(Icons.delete_outline, color: AppColors.textPrimary),
            onPressed: onDelete,
          ),
        IconButton(
          icon:  Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: onClose,
        ),
      ],
    );
  }
}
