import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/routing/app_routes.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../common/auth/cubit/auth_cubit.dart';
import '../../community/view/community_view.dart';
import '../../home/view/home_screen.dart';
import '../../map/view/map_view.dart';
import '../../../tourist/community/model/community_post.dart';
import '../../../tourist/community/widget/post_images.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_details_cubit.dart';
import '../cubit/profile_details_state.dart';
import '../cubit/profile_posts_cubit.dart';
import '../cubit/profile_posts_state.dart';
import '../widget/edit_profile_sheet.dart';
import 'my_posts_screen.dart';
import 'settings_screen.dart';

const _ink = Color(0xFF263A40);
const _teal = Color(0xFF0E5865);
const _muted = Color(0xFF62777D);

Color _profileColor(BuildContext context, Color light, Color dark) =>
    AppThemeColors.resolve(context, light: light, dark: dark);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const _ProfileBody();
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();
  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().user;
    return BlocListener<ProfileDetailsCubit, ProfileDetailsState>(
      listener: (context, state) {
        if (state.errorMessage != null) _message(state.errorMessage!);
      },
      child: BlocBuilder<ProfileDetailsCubit, ProfileDetailsState>(
        builder: (context, detailsState) {
          return BlocBuilder<ProfilePostsCubit, ProfilePostsState>(
            builder: (context, postsState) {
              final detailsCubit = context.read<ProfileDetailsCubit>();
              final preferencesCubit = context.read<ProfileCubit>();
              final name = detailsState.name.trim().isNotEmpty
                  ? detailsState.name
                  : (user?.displayName?.trim().isNotEmpty == true
                        ? user!.displayName!
                        : 'Traveler');
              final photo = detailsState.photoUrlWithAuthFallback(
                user?.photoURL,
              );
              final location = [detailsState.city, detailsState.country]
                  .map((value) => value.trim())
                  .where((value) => value.isNotEmpty)
                  .join(', ');
              final mine = context.read<ProfilePostsCubit>().myPosts(user?.uid);
              final initialError = !detailsState.hasLoaded
                  ? detailsState.errorMessage
                  : !postsState.hasLoaded
                  ? postsState.errorMessage
                  : null;

              return Scaffold(
                extendBody: true,
                backgroundColor: _profileColor(
                  context,
                  Colors.white,
                  AppThemeDark.backgroundPrimary,
                ),
                appBar: AppBar(
                  backgroundColor: _profileColor(
                    context,
                    Colors.white,
                    AppThemeDark.backgroundPrimary,
                  ),
                  foregroundColor: _profileColor(
                    context,
                    Colors.black,
                    AppThemeDark.textPrimary,
                  ),
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 19,
                      color: _profileColor(
                        context,
                        _teal,
                        AppThemeDark.iconPrimary,
                      ),
                    ),
                  ),
                  title: Text(
                    'My profile',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _profileColor(
                        context,
                        _ink,
                        AppThemeDark.homeSectionTitle,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Edit profile',
                      onPressed: () =>
                          _edit(context, detailsState, name, photo),
                      icon: Icon(
                        Icons.edit_outlined,
                        color: _profileColor(
                          context,
                          _teal,
                          AppThemeDark.iconPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Settings',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: preferencesCubit,
                            child: const SettingsScreen(),
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.settings_outlined,
                        color: _profileColor(
                          context,
                          _teal,
                          AppThemeDark.iconPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                body: !detailsState.hasLoaded || !postsState.hasLoaded
                    ? initialError != null
                          ? AppErrorView(
                              message: initialError,
                              onRetry: () {
                                if (detailsState.errorMessage != null) {
                                  detailsCubit.retry();
                                }
                                if (postsState.errorMessage != null) {
                                  context.read<ProfilePostsCubit>().retry();
                                }
                              },
                            )
                          : const _ProfileSkeleton()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: ProfileAvatar(imageUrl: photo, size: 66),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _profileColor(
                                          context,
                                          _ink,
                                          AppThemeDark.homeGuideName,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      location.isEmpty
                                          ? 'Location not added'
                                          : location,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _profileColor(
                                          context,
                                          _muted,
                                          AppThemeDark.homeGuideSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _stats(
                            preferencesCubit.stats,
                            postCount: mine.length,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Bio',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: _profileColor(
                                context,
                                _ink,
                                AppThemeDark.homeSectionTitle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            detailsState.isLoading
                                ? 'Loading bio…'
                                : detailsState.bio.isEmpty
                                ? 'No bio added yet.'
                                : detailsState.bio,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: _profileColor(
                                context,
                                _muted,
                                AppThemeDark.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Published posts',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: _profileColor(
                                      context,
                                      _ink,
                                      AppThemeDark.homeSectionTitle,
                                    ),
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
                                child: Row(
                                  children: [
                                    Text(
                                      'View all',
                                      style: TextStyle(
                                        color: _profileColor(
                                          context,
                                          _teal,
                                          AppThemeDark.homeSeeAll,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: _profileColor(
                                        context,
                                        _teal,
                                        AppThemeDark.homeSeeAll,
                                      ),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (postsState.errorMessage != null)
                            _info(postsState.errorMessage!)
                          else if (mine.isEmpty)
                            _info('You have no published posts yet.')
                          else
                            ProfilePostCard(
                              post: mine.first,
                              compact: true,
                              authorAvatarUrl: photo ?? '',
                              onDelete: null,
                              onShare: () =>
                                  shareProfilePost(context, mine.first),
                            ),
                        ],
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
                        MaterialPageRoute(
                          builder: (_) => const CommunityScreen(),
                        ),
                      );
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

  Future<void> _edit(
    BuildContext context,
    ProfileDetailsState state,
    String name,
    String? photo,
  ) async {
    final detailsCubit = context.read<ProfileDetailsCubit>();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileSheet(
          name: name,
          photoUrl: photo,
          city: state.city,
          country: state.country,
          bio: state.bio,
        ),
      ),
    );
    if (saved == true && mounted) {
      detailsCubit.load();
    }
  }

  Widget _stats(Map<String, int> stats, {required int? postCount}) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: _profileColor(
        context,
        const Color(0xFFFAF9F6),
        AppThemeDark.homeGuideSurface,
      ),
      border: Theme.of(context).brightness == Brightness.dark
          ? Border.all(color: AppThemeDark.homeGuideBorder)
          : null,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _profileColor(
                      context,
                      _ink,
                      AppThemeDark.homeGuideName,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.$1,
                  style: TextStyle(
                    fontSize: 10,
                    color: _profileColor(
                      context,
                      _muted,
                      AppThemeDark.homeGuideSecondary,
                    ),
                  ),
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
      border: Border.all(
        color: _profileColor(
          context,
          const Color(0xFFE5EAEB),
          AppThemeDark.homeGuideBorder,
        ),
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _profileColor(
            context,
            _muted,
            AppThemeDark.homeGuideSecondary,
          ),
          fontSize: 13,
        ),
      ),
    ),
  );

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Row(
          children: [
            ShimmerCircle(size: 66),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLine(width: 130, height: 16),
                  SizedBox(height: 8),
                  ShimmerLine(width: 96, height: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const ShimmerCard(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(child: Center(child: ShimmerLine(width: 32))),
              Expanded(child: Center(child: ShimmerLine(width: 32))),
              Expanded(child: Center(child: ShimmerLine(width: 32))),
              Expanded(child: Center(child: ShimmerLine(width: 32))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const ShimmerLine(width: 44, height: 16),
        const SizedBox(height: 10),
        const ShimmerLine(height: 12),
        const SizedBox(height: 7),
        const ShimmerLine(width: 230, height: 12),
        const SizedBox(height: 20),
        const ShimmerLine(width: 150, height: 16),
        const SizedBox(height: 12),
        const ShimmerCard(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(
                width: double.infinity,
                height: 120,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              SizedBox(height: 12),
              ShimmerLine(width: 120, height: 13),
              SizedBox(height: 8),
              ShimmerLine(width: 190, height: 12),
            ],
          ),
        ),
      ],
    ),
  );
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
        color: _profileColor(
          context,
          Colors.transparent,
          AppThemeDark.homeGuideSurface,
        ),
        border: Border.all(
          color: _profileColor(
            context,
            const Color(0xFFE5EAEB),
            AppThemeDark.homeGuideBorder,
          ),
        ),
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
                color: _profileColor(
                  context,
                  const Color(0xFFF7F6F2),
                  AppThemeDark.surfaceElevated,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  color: _profileColor(
                    context,
                    _teal,
                    AppThemeDark.homeGuideSecondary,
                  ),
                ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _profileColor(
                          context,
                          _ink,
                          AppThemeDark.homeGuideName,
                        ),
                      ),
                    ),
                    Text(
                      post.createdAt == null
                          ? 'Published post'
                          : 'Published ${_date(post.createdAt!)} · Public',
                      style: TextStyle(
                        fontSize: 10,
                        color: _profileColor(
                          context,
                          _muted,
                          AppThemeDark.homeGuideSecondary,
                        ),
                      ),
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _profileColor(
                    context,
                    _ink,
                    AppThemeDark.homeGuideName,
                  ),
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
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: _profileColor(
                    context,
                    _muted,
                    AppThemeDark.textSecondary,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                size: 20,
                color: _profileColor(
                  context,
                  _teal,
                  AppThemeDark.homeGuidePrice,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${post.likesCount}',
                style: TextStyle(
                  fontSize: 11,
                  color: _profileColor(
                    context,
                    _muted,
                    AppThemeDark.homeGuideSecondary,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onShare,
                icon: Icon(
                  Icons.share_outlined,
                  size: 16,
                  color: _profileColor(context, _teal, AppThemeDark.homeSeeAll),
                ),
                label: Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 11,
                    color: _profileColor(
                      context,
                      _muted,
                      AppThemeDark.homeGuideSecondary,
                    ),
                  ),
                ),
              ),
              if (onDelete != null && compact)
                TextButton(
                  onPressed: onDelete,
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: _profileColor(
                        context,
                        const Color(0xFFC33B25),
                        AppThemeDark.statusError,
                      ),
                      fontSize: 11,
                    ),
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
