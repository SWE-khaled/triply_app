import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/features/tourist/UserProfile/view/profile_screen.dart';
import 'package:triply/features/tourist/home/view/home_screen.dart';
import 'package:triply/features/tourist/map/view/map_view.dart';

import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/circle_icon_button.dart';
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

class _CommunityScreenState extends State<CommunityScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openComposer(BuildContext context) async {
    final result = await Navigator.of(context).push<ComposerResult>(
      MaterialPageRoute(builder: (_) => const NewPostScreen()),
    );
    if (result == null) return;
    if (!mounted) return;

    final cubit = context.read<CommunityCubit>();
    if (result.isStory) {
      if (result.image != null) {
        cubit.addMyStory(result.image!.path);
      }
    } else {
      cubit.addPost(
        imagePaths: result.images.map((e) => e.path).toList(),
        text: result.text,
        location: result.location,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Posted!',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  /// Quick "+" action on the story bubble itself: opens the gallery directly
  /// and publishes a story right away, without going through the composer.
  Future<void> _pickMyStoryImage(BuildContext context) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      if (!mounted) return;
      context.read<CommunityCubit>().addMyStory(picked.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Posted!',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Can't open the gallery: $e")),
      );
    }
  }

  /// Opens the viewer with ONLY the tapped user's stories - never mixed.
  void _openStoryViewerForUser(BuildContext context, String userId) {
    final cubit = context.read<CommunityCubit>();
    final userStories = cubit.storiesOf(userId);
    if (userStories.isEmpty) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: StoryViewerScreen(
                stories: userStories,
              ),
            ),
          ),
        )
        .then((_) {
      // Refresh rings after possible deletions inside the viewer.
      // (Cubit emits rebuild this screen automatically; kept for parity.)
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityCubit(),
      child: BlocBuilder<CommunityCubit, CommunityState>(
        builder: (context, state) {
          final cubit = context.read<CommunityCubit>();
          final hasMyStory = cubit.myStories.isNotEmpty;
          final rings = cubit.userRings;

          return Scaffold(
            extendBody: true, // content extends under the glass nav
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false, // <-- let the content reach the bottom of the screen
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
                              fontSize: 28, fontWeight: FontWeight.w700),
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
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 100), // <-- space for nav
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyStoryBubble(
                                  hasStory: hasMyStory,
                                  onAddTap: () => _pickMyStoryImage(context),
                                  onViewTap: () =>
                                      _openStoryViewerForUser(
                                          context, currentUserId),
                                ),
                                for (var i = 0; i < rings.length; i++) ...[
                                  const SizedBox(width: 14),
                                  StoryRing(
                                    story: rings[i],
                                    ringColor: [
                                      AppColors.primaryTeal,
                                      AppColors.starGold,
                                      AppColors.accentOrange,
                                    ][i % 3],
                                    onTap: () => _openStoryViewerForUser(
                                        context, rings[i].userId),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final post in cubit.posts) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                            child: PostCard(
                              post: post,
                              onLike: () {
                                cubit.toggleLike(post);
                              },
                              onDelete: () {
                                final deleted = cubit.deletePost(post);
                                if (!deleted && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColors.primaryTeal,
                                      content: Text("You can't delete others post!",style: TextStyle(color: Colors.white),),
                                    ),
                                  );
                                }
                              },
                              // Placeholders: no comments/share screens in Figma.
                              onComments: () {},
                              onShare: () {},
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
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
