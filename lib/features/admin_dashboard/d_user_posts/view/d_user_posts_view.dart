import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../d_home/view/d_home_view.dart';
import '../cubit/user_posts_cubit.dart';

class UserPostsView extends StatelessWidget {
  const UserPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserPostsCubit()..start(),
      child: const _UserPostsBody(),
    );
  }
}

class _UserPostsBody extends StatelessWidget {
  const _UserPostsBody();

  Future<void> _removePost(
    BuildContext context,
    CommunityPost post, {
    bool skipConfirmation = false,
  }) async {
    if (!skipConfirmation) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Post'),
          content: Text(
            'Are you sure you want to delete this post by ${post.authorName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adminDanger,
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) return;
    }

    // Capture the messenger before the await: the view can be rebuilt while
    // the request is in flight.
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<UserPostsCubit>().removePost(post);

    messenger.showSnackBar(
      error == null
          ? const SnackBar(content: Text('Post deleted successfully.'))
          : SnackBar(
              content: Text(error),
              backgroundColor: AppColors.adminDanger,
            ),
    );
  }

  /// Opens the details dialog and deletes the post when the dialog asks for
  /// it. The deletion happens only after the dialog is fully dismissed, so the
  /// parent never mutates the list while a route is still being disposed.
  Future<void> _viewPost(BuildContext context, CommunityPost post) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => _ViewUserPostDialog(
        post: post,
        imageBuilder: _buildPostImage,
      ),
    );
    if (shouldDelete == true && context.mounted) {
      await _removePost(context, post, skipConfirmation: true);
    }
  }

  Widget _buildPostImage(String url, {double height = 180}) {
    if (url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('blob:')) {
      return Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(height),
      );
    } else if (!kIsWeb && url.isNotEmpty) {
      try {
        if (File(url).existsSync()) {
          return Image.file(
            File(url),
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _imagePlaceholder(height),
          );
        }
      } catch (_) {}
    }
    return _imagePlaceholder(height);
  }

  Widget _imagePlaceholder(double height) {
    return Container(
      height: height,
      color: AppColors.adminStatBadgeBg,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppColors.adminTextMuted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CardSectionHeader(
                    title: 'Manage User Posts',
                    subtitle:
                        'Search, review and control all live user posts from the community feed.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SearchFilterRow(
              hintText: 'Search user posts...',
              onChanged: context.read<UserPostsCubit>().search,
            ),
            const SizedBox(height: 24),

            BlocBuilder<UserPostsCubit, UserPostsState>(
              builder: (context, state) {
                if (state is UserPostsInitial || state is UserPostsLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is UserPostsError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text(state.message)),
                  );
                }

                final posts = state is UserPostsSuccess
                    ? state.filtered
                    : const <CommunityPost>[];
                if (posts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No posts found.')),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final isTablet = constraints.maxWidth < 900;
                    final columns = isMobile ? 1 : (isTablet ? 2 : 3);
                    final availableWidth = constraints.maxWidth.clamp(
                      300.0,
                      double.infinity,
                    );
                    final cardW =
                        (availableWidth - (16 * (columns - 1))) / columns;
                    final safeCardW = cardW.clamp(200.0, double.infinity);

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final post in posts)
                          SizedBox(
                            width: safeCardW,
                            child: _PostCard(
                              post: post,
                              onRemove: () => _removePost(context, post),
                              onView: () => _viewPost(context, post),
                              imageBuilder: _buildPostImage,
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onRemove;
  final VoidCallback onView;
  final Widget Function(String, {double height}) imageBuilder;

  const _PostCard({
    required this.post,
    required this.onRemove,
    required this.onView,
    required this.imageBuilder,
  });

  String get _title {
    final text = post.text.trim();
    if (text.isNotEmpty) {
      return text.length > 40 ? '${text.substring(0, 37)}...' : text;
    }
    return 'Post by ${post.authorName}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.adminBorderLight),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: imageBuilder(post.imageUrl, height: 180),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: AppTextStyles.adminPostCardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'By ${post.authorName}',
                  style: AppTextStyles.adminPostCardAuthor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onView,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.adminDivider),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'View',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.adminButtonSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: onRemove,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.adminDangerLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Remove',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.adminButtonDanger,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal dialog for reviewing a community user post in full detail.
class _ViewUserPostDialog extends StatelessWidget {
  final CommunityPost post;
  final Widget Function(String, {double height}) imageBuilder;

  const _ViewUserPostDialog({
    required this.post,
    required this.imageBuilder,
  });

  String get _title {
    final text = post.text.trim();
    if (text.isNotEmpty) {
      return text.length > 40 ? '${text.substring(0, 37)}...' : text;
    }
    return 'Post by ${post.authorName}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: AppTextStyles.adminDialogTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Community User Post',
                          style: AppTextStyles.adminDialogSubtitle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.adminDivider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Close',
                        style: AppTextStyles.adminButtonSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Image preview if available
              if (post.imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageBuilder(post.imageUrl, height: 220),
                ),
                const SizedBox(height: 18),
              ],

              // Author & Post Metadata
              _buildDetailRow('Author:', post.authorName),
              if (post.location.isNotEmpty)
                _buildDetailRow('Location:', post.location),
              if (post.createdAt != null)
                _buildDetailRow(
                  'Posted:',
                  '${post.createdAt!.day}/${post.createdAt!.month}/${post.createdAt!.year}',
                ),
              _buildDetailRow('Likes:', '${post.likesCount}'),
              _buildDetailRow('Comments:', '${post.commentsCount}'),
              const SizedBox(height: 6),
              const Divider(color: AppColors.adminDivider),
              const SizedBox(height: 10),

              // Content text
              Text('Content:', style: AppTextStyles.adminFieldLabel),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.adminStatBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.adminDivider),
                ),
                child: Text(
                  post.text.isNotEmpty
                      ? post.text
                      : 'No text content in this post.',
                  style: AppTextStyles.adminTableCell.copyWith(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.adminDivider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Close',
                        style: AppTextStyles.adminButtonSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (confirmCtx) => AlertDialog(
                          scrollable: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Delete Post'),
                          content: const Text(
                            'Are you sure you want to permanently delete this post?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(confirmCtx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(confirmCtx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.adminDanger,
                              ),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );

                      // Only close the details dialog here. The post itself is
                      // deleted by the parent once this route has been popped.
                      if (confirmed == true && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Delete Post',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.adminDanger,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.adminFieldLabel),
          ),
          Expanded(child: Text(value, style: AppTextStyles.adminTableCell)),
        ],
      ),
    );
  }
}

