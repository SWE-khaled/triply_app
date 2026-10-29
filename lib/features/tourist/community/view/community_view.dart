import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/features/common/AuthTourist/cubit/auth_cubit.dart';
import 'package:triply/features/tourist/user_profile/view/profile_screen.dart';
import 'package:triply/features/tourist/home/view/home_screen.dart';
import 'package:triply/features/tourist/map/view/map_view.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../data/community_posts_repository.dart';
import '../data/community_stories_repository.dart';
import '../model/community_post.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/circle_icon_button.dart';
import '../widget/community_posts_empty_state.dart';
import '../widget/my_story_bubble.dart';
import '../widget/post_card.dart';
import '../widget/story_ring.dart';
import 'share_composer_view.dart';
import 'story_viewer_view.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  late final CommunityCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CommunityCubit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.pruneExpiredStories();
    }
  }

  Future<void> _openComposer(BuildContext context) async {
    final result = await Navigator.of(context).push<ComposerResult>(
      MaterialPageRoute(builder: (_) => const NewPostScreen()),
    );
    if (result == null) return;
    if (!context.mounted) return;

    final cubit = context.read<CommunityCubit>();
    try {
      if (result.isStory) {
        final image = result.image;
        if (image == null) return;
        await cubit.publishStory(image);
      } else {
        await cubit.publishPost(
          images: result.images,
          text: result.text ?? '',
          location: result.location,
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_communityErrorMessage(error))));
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Posted!',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  Future<void> _toggleLike(
    BuildContext context,
    CommunityCubit cubit,
    CommunityPost post,
  ) async {
    try {
      await cubit.toggleLike(post);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_communityErrorMessage(error))));
    }
  }

  Future<void> _deletePost(
    BuildContext context,
    CommunityCubit cubit,
    CommunityPost post,
  ) async {
    try {
      await cubit.deletePost(post);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_communityErrorMessage(error))));
    }
  }

  String _communityErrorMessage(Object error) {
    if (error is CommunityPostsException) return error.message;
    if (error is CommunityStoriesException) return error.message;
    return 'Could not update Community. Please try again.';
  }

  /// Quick "+" action on the story bubble itself: opens the gallery directly
  /// and publishes a Story through the same persistent path as the composer.
  Future<void> _pickMyStoryImage(BuildContext context) async {
    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Can't open the gallery: $error")));
      return;
    }
    if (picked == null) return;
    if (!context.mounted) return;

    try {
      await context.read<CommunityCubit>().publishStory(picked);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_communityErrorMessage(error))));
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Posted!',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  /// Opens the viewer with ONLY the tapped user's stories - never mixed.
  void _openStoryViewerForUser(BuildContext context, String authorId) {
    final cubit = context.read<CommunityCubit>();
    final userStories = cubit.storiesOf(authorId);
    if (userStories.isEmpty) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: StoryViewerScreen(stories: userStories),
            ),
          ),
        )
        .then((_) {
          // Refresh rings after possible deletions inside the viewer.
          if (mounted) setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<CommunityCubit, CommunityState>(
        builder: (context, state) {
          final cubit = context.read<CommunityCubit>();
          final currentUserId = context.watch<AuthCubit>().user?.uid ?? '';
          final hasMyStory = cubit.myStories.isNotEmpty;
          final rings = cubit.userRings;

          return Scaffold(
            extendBody: true, // content extends under the glass nav
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom:
                  false, // <-- let the content reach the bottom of the screen
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Community',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CircleIconButton(
                          icon: Icons.add,
                          onTap: () => _openComposer(context),
                          backgroundColor: AppColors.primaryTeal,
                          iconColor: Colors.white,
                          iconSize: 27,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyStoryBubble(
                                        hasStory: hasMyStory,
                                        onAddTap: () =>
                                            _pickMyStoryImage(context),
                                        onViewTap: () {
                                          if (currentUserId.isNotEmpty) {
                                            _openStoryViewerForUser(
                                              context,
                                              currentUserId,
                                            );
                                          }
                                        },
                                      ),
                                      for (
                                        var i = 0;
                                        i < rings.length;
                                        i++
                                      ) ...[
                                        const SizedBox(width: 14),
                                        StoryRing(
                                          story: rings[i],
                                          ringColor: [
                                            AppColors.primaryTeal,
                                            AppColors.starGold,
                                            AppColors.accentOrange,
                                          ][i % 3],
                                          onTap: () => _openStoryViewerForUser(
                                            context,
                                            rings[i].authorId,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (state.storiesError != null)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    0,
                                  ),
                                  child: Text(
                                    state.storiesError!,
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (state.postsError != null)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    0,
                                  ),
                                  child: Text(
                                    state.postsError!,
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (state.showPostsEmptyState)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 100,
                              ), // <-- space for nav
                              child: CommunityPostsEmptyState(),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.only(
                              bottom: 100,
                            ), // <-- space for nav
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final post = cubit.posts[index];
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    16,
                                  ),
                                  child: PostCard(
                                    post: post,
                                    onLike: () {
                                      _toggleLike(context, cubit, post);
                                    },
                                    onDelete: () =>
                                        _deletePost(context, cubit, post),
                                    // Placeholders: no comments/share screens in Figma.
                                    onComments: () {},
                                    onShare: () {},
                                  ),
                                );
                              }, childCount: cubit.posts.length),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: AppBottomNav(
              currentIndex: 3,
              onTap: (index) {
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                } else if (index == 1) {
                  Navigator.of(context).push(AppRoutes.myTrips());
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MapScreen()),
                  ); // map
                } else if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ); // profile
                }
              },
            ),
          );
        },
      ),
    );
  }
}
