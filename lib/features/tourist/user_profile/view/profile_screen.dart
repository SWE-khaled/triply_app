import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../common/AuthTourist/cubit/auth_cubit.dart';
import '../../../common/AuthTourist/data/auth_repository.dart';
import '../../community/view/community_view.dart';
import '../../home/view/home_screen.dart';
import '../../map/view/map_view.dart';
import '../../../tourist/community/data/community_posts_repository.dart';
import '../../../tourist/community/model/community_post.dart';
import '../../../tourist/community/widget/post_images.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widget/edit_profile_sheet.dart';
import 'my_posts_screen.dart';
import 'settings_screen.dart';

const _ink = Color(0xFF263A40);
const _teal = Color(0xFF0E5865);
const _muted = Color(0xFF62777D);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) {
      final uid =
          context.read<AuthCubit>().user?.uid ??
          AuthRepository().currentUser?.uid;
      return ProfileCubit(userId: uid);
    },
    child: const _ProfileBody(),
  );
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();
  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  late final Stream<List<CommunityPost>> _posts =
      FirestoreCommunityPostsRepository().watchMyPosts();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().user;
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (a, b) => a.profileError != b.profileError,
      listener: (context, state) {
        if (state.profileError != null) _message(state.profileError!);
      },
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        final name = state.profileName?.trim().isNotEmpty == true
            ? state.profileName!
            : (user?.displayName?.trim().isNotEmpty == true
                  ? user!.displayName!
                  : 'Traveler');
        final photo = state.profilePhotoUrl?.trim().isNotEmpty == true
            ? state.profilePhotoUrl
            : user?.photoURL;
        final location = [state.city, state.country]
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .join(', ');
        final bio = state.bio?.trim() ?? '';
        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 19,
                color: _teal,
              ),
            ),
            title: const Text(
              'My profile',
              style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit profile',
                onPressed: () => _edit(context, state, name, photo),
                icon: const Icon(Icons.edit_outlined, color: _teal),
              ),
              IconButton(
                tooltip: 'Settings',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const SettingsScreen(),
                    ),
                  ),
                ),
                icon: const Icon(Icons.settings_outlined, color: _teal),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: StreamBuilder<List<CommunityPost>>(
            stream: _posts,
            builder: (context, postsSnapshot) {
              final posts = postsSnapshot.data ?? const <CommunityPost>[];
              final mine = user == null
                  ? <CommunityPost>[]
                  : posts
                        .where(
                          (post) =>
                              post.authorId.isNotEmpty &&
                              post.authorId == user.uid,
                        )
                        .toList();
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  Row(
                    children: [
                      ClipOval(child: ProfileAvatar(imageUrl: photo, size: 66)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              location.isEmpty
                                  ? 'Location not added'
                                  : location,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _stats(
                    cubit.stats,
                    postCount: postsSnapshot.hasData && !postsSnapshot.hasError
                        ? mine.length
                        : null,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Bio',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    state.isLoadingProfile
                        ? 'Loading bio…'
                        : bio.isEmpty
                        ? 'No bio added yet.'
                        : bio,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Published posts',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _ink,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyPostsScreen(),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'View all',
                              style: TextStyle(color: _teal, fontSize: 12),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward, color: _teal, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (postsSnapshot.hasError)
                    _info('Could not load published posts.')
                  else if (!postsSnapshot.hasData)
                    const Padding(
                      padding: EdgeInsets.all(22),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (mine.isEmpty)
                    _info('You have no published posts yet.')
                  else
                    ProfilePostCard(
                      post: mine.first,
                      compact: true,
                      authorAvatarUrl: photo ?? '',
                      onDelete: null,
                      onShare: () => shareProfilePost(context, mine.first),
                    ),
                ],
              );
            },
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: 4,
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
                );
              } else if (index == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CommunityScreen()),
                );
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _edit(
    BuildContext context,
    ProfileState state,
    String name,
    String? photo,
  ) async {
    final profileCubit = context.read<ProfileCubit>();
    final userId = context.read<AuthCubit>().user?.uid;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileSheet(
          name: name,
          photoUrl: photo,
          city: state.city ?? '',
          country: state.country ?? '',
          bio: state.bio ?? '',
        ),
      ),
    );
    if (saved == true && mounted) {
      if (userId != null) profileCubit.loadUserProfile(userId);
    }
  }

  Widget _stats(Map<String, int> stats, {required int? postCount}) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFFAF9F6),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        for (final entry in [
          ('Trips', MyBookingsPublic.count),
          ('Places', stats['places'] ?? 0),
          ('Posts', postCount),
          ('Reviews', stats['reviews'] ?? 0),
        ])
          Expanded(
            child: Column(
              children: [
                Text(
                  entry.$2 == null ? '—' : '${entry.$2}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.$1,
                  style: const TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
      ],
    ),
  );
  Widget _info(String text) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE5EAEB)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _muted, fontSize: 13),
      ),
    ),
  );
  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class ProfilePostCard extends StatelessWidget {
  const ProfilePostCard({
    super.key,
    required this.post,
    required this.compact,
    this.authorAvatarUrl,
    required this.onDelete,
    required this.onShare,
  });
  final CommunityPost post;
  final bool compact;
  final String? authorAvatarUrl;
  final VoidCallback? onDelete;
  final VoidCallback onShare;
  @override
  Widget build(BuildContext context) {
    final lines = post.text.split('\n');
    final title = lines.first.trim();
    final description = lines.skip(1).join('\n').trim();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5EAEB)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: compact ? 120 : 170,
                width: double.infinity,
                child: PostImages(post: post),
              ),
            )
          else
            Container(
              height: compact ? 120 : 150,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F6F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined, color: _teal),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              ClipOval(
                child: ProfileAvatar(
                  imageUrl: authorAvatarUrl ?? post.authorAvatarUrl,
                  size: 36,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _ink,
                      ),
                    ),
                    Text(
                      post.createdAt == null
                          ? 'Published post'
                          : 'Published ${_date(post.createdAt!)} · Public',
                      style: const TextStyle(fontSize: 10, color: _muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                description,
                maxLines: compact ? 3 : 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: _muted,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 20, color: _teal),
              const SizedBox(width: 4),
              Text(
                '${post.likesCount}',
                style: const TextStyle(fontSize: 11, color: _muted),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined, size: 16, color: _teal),
                label: const Text(
                  'Share',
                  style: TextStyle(fontSize: 11, color: _muted),
                ),
              ),
              if (onDelete != null && compact)
                TextButton(
                  onPressed: onDelete,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Color(0xFFC33B25), fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _date(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

Future<void> shareProfilePost(BuildContext context, CommunityPost post) async {
  await Clipboard.setData(
    ClipboardData(text: '${post.text}\n${post.location}'.trim()),
  );
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post details copied to clipboard.')),
    );
  }
}

Future<void> deleteCommunityPost(
  BuildContext context,
  CommunityPost post,
) async {
  if (!await ConfirmDeleteDialog.show(context)) {
    return;
  }
  try {
    await FirestoreCommunityPostsRepository().deletePost(post);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post deleted.')));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}
