import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../../core/widgets/location_tag_chip.dart';
import '../../../common/auth/cubit/auth_cubit.dart';
import '../cubit/post_actions_cubit.dart';
import '../cubit/post_actions_state.dart';
import '../model/community_post.dart';
import 'post_images.dart';

class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onComments;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onComments,
    required this.onShare,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await ConfirmDeleteDialog.show(context);
    if (confirmed && context.mounted) {
      await context.read<PostActionsCubit>().delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthCubit>().user;
    final avatarUrl = post.isMine
        ? (currentUser?.photoURL ?? '')
        : post.authorAvatarUrl;
    final hasAvatar = avatarUrl.isNotEmpty;

    return BlocListener<PostActionsCubit, PostActionsState>(
      listener: (context, state) {
        if (!context.mounted || state.errorMessage == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeColors.resolve(
            context,
            light: Colors.white,
            dark: AppThemeDark.surfaceDefault,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppThemeColors.resolve(
              context,
              light: AppColors.cardBorder,
              dark: AppThemeDark.borderSubtle,
            ),
          ),
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
                    backgroundColor: AppThemeColors.resolve(
                      context,
                      light: AppColors.chipGrey,
                      dark: AppThemeDark.surfaceElevated,
                    ),
                    backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                    onBackgroundImageError: hasAvatar ? (_, _) {} : null,
                    child: hasAvatar
                        ? null
                        : Icon(
                            Icons.person,
                            color: AppThemeColors.resolve(
                              context,
                              light: AppColors.textGrey,
                              dark: AppThemeDark.textSecondary,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                            color: AppThemeColors.resolve(
                              context,
                              light: const Color(0xFF17343B),
                              dark: AppThemeDark.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          post.timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                            color: AppThemeColors.resolve(
                              context,
                              light: AppColors.textGrey,
                              dark: AppThemeDark.textSecondary,
                            ),
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
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.textGrey,
                          dark: AppThemeDark.textSecondary,
                        ),
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
                    style: TextStyle(
                      fontSize: 11,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.textGrey,
                        dark: AppThemeDark.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
            if (post.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Text(
                  post.text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    height: 1.5,
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.chipTextGrey,
                      dark: AppThemeDark.textSecondary,
                    ),
                  ),
                ),
              ),
            const Divider(height: 20, indent: 12, endIndent: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  BlocBuilder<PostActionsCubit, PostActionsState>(
                    builder: (context, state) {
                      final isLiked = state.isLiked ?? post.isLiked;
                      final likesCount = state.likesCount ?? post.likesCount;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            context.read<PostActionsCubit>().toggleLike(),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: AppColors.accentOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$likesCount',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
