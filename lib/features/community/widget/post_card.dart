import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../core/widgets/location_tag_chip.dart';
import '../model/community_post.dart';
import 'post_images.dart';

/// Post card extracted from `_PostCard` in `community_view.dart`.
/// Moved as-is (no core swap here — Step 5 handles that separately).
class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onDelete;
  final VoidCallback onComments;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onDelete,
    required this.onComments,
    required this.onShare,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await ConfirmDeleteDialog.show(context);
    if (confirmed) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.chipGrey,
                  backgroundImage: post.authorAvatarUrl.isEmpty
                      ? null
                      : NetworkImage(post.authorAvatarUrl),
                  onBackgroundImageError:
                      post.authorAvatarUrl.isEmpty ? null : (_, _) {},
                  child: post.authorAvatarUrl.isEmpty
                      ? const Icon(Icons.person, color: AppColors.textGrey)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          color: Color(0xFF17343B),
                        ),
                      ),
                      Text(
                        post.timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.location.isNotEmpty)
                  LocationTagChip(label: post.location),
                if (post.isMine) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (post.imageUrls.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: PostImages(post: post),
            ),
            if (post.imageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Text(
                  '${post.imageUrls.length} photos',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
          ],
          if (post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                post.text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                  height: 1.5,
                  color: AppColors.chipTextGrey,
                ),
              ),
            ),
          const Divider(height: 20, indent: 12, endIndent: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: AppColors.accentOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: onComments,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 15,
                        color: AppColors.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentsCount} Comments',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onShare,
                  child: const Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
