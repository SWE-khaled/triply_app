import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/features/common/auth/cubit/auth_cubit.dart';
import 'package:triply/features/tourist/user_profile/view/profile_screen.dart';
import 'package:triply/features/tourist/home/view/home_screen.dart';
import 'package:triply/features/tourist/map/view/map_view.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../cubit/community_stories_cubit.dart';
import '../cubit/community_stories_state.dart';
import '../cubit/post_actions_cubit.dart';
import '../cubit/publish_content_cubit.dart';
import '../cubit/publish_content_state.dart';
import '../cubit/story_actions_cubit.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/routing/app_routes.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/circle_icon_button.dart';
import '../widget/community_posts_empty_state.dart';
import '../widget/my_story_bubble.dart';
import '../widget/post_card.dart';
import '../widget/story_ring.dart';
import 'share_composer_view.dart';
import 'story_viewer_view.dart';

class CommunityScreen extends StatefulWidget {
  /// Set by post notifications so the feed highlights and scrolls to a post.
  final String? focusPostId;

  const CommunityScreen({super.key, this.focusPostId});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _focusedPostKey = GlobalKey();
  int _focusAttempts = 0;
  bool _didScrollToFocus = false;
  late final CommunityStoriesCubit _storiesCubit;

  @override
  void initState() {
    super.initState();
    _storiesCubit = context.read<CommunityStoriesCubit>();
    WidgetsBinding.instance.addObserver(this);
    if (widget.focusPostId != null) _scheduleFocusScroll();
  }

  /// Posts may still be loading when the screen opens from a notification.
  void _scheduleFocusScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didScrollToFocus) return;
      final target = _focusedPostKey.currentContext;
      if (target != null) {
        _didScrollToFocus = true;
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 400),
          alignment: 0.2,
        );
        return;
      }
      if (_focusAttempts++ < 180) _scheduleFocusScroll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _storiesCubit.pruneExpiredStories();
    }
  }

  Future<void> _openComposer(BuildContext context) async {
    final result = await Navigator.of(context).push<ComposerResult>(
      MaterialPageRoute(builder: (_) => const NewPostScreen()),
    );
    if (result == null || !context.mounted) return;

    final publish = context.read<PublishContentCubit>();
    if (result.isStory) {
      await publish.publishStory(result.image);
    } else {
      await publish.publishPost(
        images: result.images,
        text: result.text ?? '',
        location: result.location,
      );
    }
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
    if (picked == null || !context.mounted) return;
    await context.read<PublishContentCubit>().publishStory(picked);
  }

  /// Opens the viewer with ONLY the tapped user's stories - never mixed.
  void _openStoryViewerForUser(BuildContext context, String authorId) {
    final userStories = _storiesCubit.storiesOf(authorId);
    if (userStories.isEmpty) return;
    final actionsCubit = StoryActionsCubit(stories: userStories);
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => BlocProvider.value(
              value: actionsCubit,
              child: StoryViewerScreen(stories: userStories),
            ),
          ),
        )
        .then((_) {
          unawaited(actionsCubit.close());
          // Refresh rings after possible deletions inside the viewer.
          if (mounted) setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PublishContentCubit, PublishContentState>(
      listener: (context, state) {
        if (!mounted) return;
        if (state is ContentPublished) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Posted!',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          );
        } else if (state is PublishFailed && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: BlocBuilder<CommunityStoriesCubit, CommunityStoriesState>(
        builder: (context, storyState) {
          return BlocBuilder<CommunityPostsCubit, CommunityPostsState>(
            builder: (context, postState) {
              final currentUserId = context.watch<AuthCubit>().user?.uid ?? '';
              final hasMyStory = storyState.myStories.isNotEmpty;
              final rings = _storiesCubit.userRings;
              final initialError = !postState.hasLoaded
                  ? postState.errorMessage
                  : !storyState.hasLoaded
                  ? storyState.errorMessage
                  : null;

              return Scaffold(
                extendBody: true, // content extends under the glass nav
                backgroundColor: Colors.white,
                body: SafeArea(
                  bottom:
                      false, // <-- let the content reach the bottom of the screen
                  child: initialError != null
                      ? AppErrorView(
                          message: initialError,
                          onRetry: () {
                            if (postState.errorMessage == initialError) {
                              context.read<CommunityPostsCubit>().retry();
                            } else {
                              _storiesCubit.retry();
                            }
                          },
                        )
                      : !postState.hasLoaded || !storyState.hasLoaded
                      ? const _CommunitySkeleton()
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 5,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                MyStoryBubble(
                                                  hasStory: hasMyStory,
                                                  onAddTap: () =>
                                                      _pickMyStoryImage(
                                                        context,
                                                      ),
                                                  onViewTap: () {
                                                    if (currentUserId
                                                        .isNotEmpty) {
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
                                                    onTap: () =>
                                                        _openStoryViewerForUser(
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
                                        if (storyState.errorMessage != null)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              4,
                                              16,
                                              0,
                                            ),
                                            child: Text(
                                              storyState.errorMessage!,
                                              style: const TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        if (postState.errorMessage != null)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              4,
                                              16,
                                              0,
                                            ),
                                            child: Text(
                                              postState.errorMessage!,
                                              style: const TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (postState.showPostsEmptyState)
                                    const SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 100),
                                        child: CommunityPostsEmptyState(),
                                      ),
                                    )
                                  else
                                    SliverPadding(
                                      padding: const EdgeInsets.only(
                                        bottom: 100,
                                      ),
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate((
                                          context,
                                          index,
                                        ) {
                                          final post = postState.posts[index];
                                          final isFocused =
                                              widget.focusPostId == post.id;
                                          return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              12,
                                              8,
                                              12,
                                              16,
                                            ),
                                            child: BlocProvider<PostActionsCubit>(
                                              key: isFocused
                                                  ? _focusedPostKey
                                                  : ValueKey(post.id),
                                              create: (_) => PostActionsCubit(
                                                post: post,
                                                onDeleted: () => context
                                                    .read<CommunityPostsCubit>()
                                                    .removePost(post),
                                              ),
                                              child: DecoratedBox(
                                                decoration: isFocused
                                                    ? BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .primaryTeal,
                                                          width: 2,
                                                        ),
                                                      )
                                                    : const BoxDecoration(),
                                                child: PostCard(
                                                  post: post,
                                                  // Placeholders: no
                                                  // comments/share screens.
                                                  onComments: () {},
                                                  onShare: () {},
                                                ),
                                              ),
                                            ),
                                          );
                                        }, childCount: postState.posts.length),
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
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ); // profile
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CommunitySkeleton extends StatelessWidget {
  const _CommunitySkeleton();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Row(
              children: const [
                ShimmerLine(width: 150, height: 28),
                Spacer(),
                ShimmerCircle(size: 38),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, _) => const Column(
                children: [
                  ShimmerCircle(size: 66),
                  SizedBox(height: 8),
                  ShimmerLine(width: 56, height: 10),
                ],
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, _) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: ShimmerCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(
                      width: double.infinity,
                      height: 210,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        ShimmerCircle(size: 38),
                        SizedBox(width: 10),
                        Expanded(child: ShimmerLine(width: 150)),
                      ],
                    ),
                    SizedBox(height: 14),
                    ShimmerLine(width: 200, height: 13),
                    SizedBox(height: 8),
                    ShimmerLine(height: 11),
                    SizedBox(height: 8),
                    ShimmerLine(width: 240, height: 11),
                  ],
                ),
              ),
            ),
            childCount: 2,
          ),
        ),
      ],
    ),
  );
}
