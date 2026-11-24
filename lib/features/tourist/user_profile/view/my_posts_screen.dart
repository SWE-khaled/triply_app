import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../common/auth/cubit/auth_cubit.dart';
import '../../community/cubit/post_actions_cubit.dart';
import '../../community/cubit/post_actions_state.dart';
import '../../community/model/community_post.dart';
import '../cubit/profile_posts_cubit.dart';
import '../cubit/profile_posts_state.dart';
import 'profile_screen.dart' show ProfilePostCard, shareProfilePost;

Color _myPostsColor(BuildContext context, Color light, Color dark) =>
    AppThemeColors.resolve(context, light: light, dark: dark);

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _myPostsColor(
      context,
      Colors.white,
      AppThemeDark.backgroundPrimary,
    ),
    appBar: AppBar(
      backgroundColor: _myPostsColor(
        context,
        Colors.white,
        AppThemeDark.backgroundPrimary,
      ),
      scrolledUnderElevation: 0.0,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: _myPostsColor(
            context,
            const Color(0xFF0E5865),
            AppThemeDark.iconPrimary,
          ),
        ),
      ),
      title: Text(
        'My posts',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _myPostsColor(
            context,
            const Color(0xFF263A40),
            AppThemeDark.homeSectionTitle,
          ),
        ),
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
          child: Text(
            'Your published travel moments, all in one place. View or remove a post.',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: _myPostsColor(
                context,
                const Color(0xFF62777D),
                AppThemeDark.homeGuideSecondary,
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<ProfilePostsCubit, ProfilePostsState>(
            builder: (context, state) {
              if (state.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      'Could not load your posts. Please try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _myPostsColor(
                          context,
                          Theme.of(context).textTheme.bodyMedium?.color ??
                              Colors.black87,
                          AppThemeDark.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }
              if (!state.hasLoaded) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppThemeDark.iconPrimary
                        : null,
                  ),
                );
              }
              final posts = context.read<ProfilePostsCubit>().myPosts(
                context.read<AuthCubit>().user?.uid,
              );
              if (posts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      'You have no published travel moments yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _myPostsColor(
                          context,
                          const Color(0xFF62777D),
                          AppThemeDark.homeGuideSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 24),
                children: [
                  for (final post in posts) ...[
                    BlocProvider<PostActionsCubit>(
                      key: ValueKey(post.id),
                      create: (_) => PostActionsCubit(
                        post: post,
                        onDeleted: () =>
                            context.read<ProfilePostsCubit>().removePost(post),
                      ),
                      child: _MyPostItem(post: post),
                    ),
                  ],
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "You're all caught up with your travel moments.",
                        style: TextStyle(
                          fontSize: 10,
                          color: _myPostsColor(
                            context,
                            const Color(0xFF62777D),
                            AppThemeDark.homeGuideSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _MyPostItem extends StatelessWidget {
  const _MyPostItem({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostActionsCubit, PostActionsState>(
      listener: (context, state) {
        if (!context.mounted || state.action != PostActionsCubit.deleteAction) {
          return;
        }
        if (state is PostActionSucceeded) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Post deleted.')));
        } else if (state is PostActionFailed && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfilePostCard(
            post: post,
            compact: false,
            authorAvatarUrl: context.watch<AuthCubit>().user?.photoURL ?? '',
            onDelete: () => context.read<PostActionsCubit>().delete(),
            onShare: () => shareProfilePost(context, post),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 8, 2, 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    post.location,
                    style: TextStyle(
                      fontSize: 10,
                      color: _myPostsColor(
                        context,
                        const Color(0xFF62777D),
                        AppThemeDark.homeGuideSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.read<PostActionsCubit>().delete(),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _myPostsColor(
                        context,
                        const Color(0xFF0E5865),
                        AppThemeDark.homeSeeAll,
                      ),
                    ),
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
