import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/tourist/community/view/community_view.dart';
import 'package:triply/features/tourist/guides/view/guides_list_screen.dart';
import 'package:triply/features/tourist/guides/view/guide_profile_screen.dart';
import 'package:triply/features/tourist/map/view/map_view.dart';
import 'package:triply/features/tourist/place_details/view/place_details_view.dart';
import 'package:triply/features/chat/widgets/chat_unread_builder.dart';
import 'package:triply/features/tourist/trips/models/trip.dart' as trips_model;
import 'package:triply/core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../common/auth/cubit/auth_cubit.dart';
import '../../user_profile/view/profile_screen.dart';
import '../cubit/home_cubit.dart';

import '../model/trip.dart';
import '../widget/community_banner.dart';
import '../widget/guide_tile.dart';
import '../widget/place_card.dart';
import '../widget/search_input.dart';
import '../widget/section_header.dart';
import '../widget/trip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeCubit get controller => context.read<HomeCubit>();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().user;
    final photoUrl = user?.photoURL;
    final name = user?.displayName ?? '';

    return Scaffold(
      extendBody: true,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return const _HomeSkeleton();
          }
          if (state is HomeError) {
            return AppErrorView(message: state.error, onRetry: controller.load);
          }
          if (state is! HomeSuccess) return const _HomeSkeleton();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(context, photoUrl, name),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(
                    title: 'Popular Places',
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: ((context) => MapScreen())),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.places.length,
                    itemBuilder: (context, i) {
                      final place = state.places[i];
                      return PlaceCard(
                        place: place,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PlaceDetailScreen(placeId: place.id),
                            ),
                          );
                        },
                        onFavoriteTap: () =>
                            controller.toggleFavorite(place.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(
                    title: 'Local Guides',
                    // TODO(Figma): no destination in Figma yet.
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => GuidesListScreen()),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: state.guides.isEmpty
                      ? const _SectionEmpty(
                          icon: Icons.person_search_outlined,
                          message: 'No guides published yet — check back soon!',
                        )
                      : Column(
                          children: [
                            for (final guide in state.guides)
                              GuideTile(
                                guide: guide,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          GuideProfileScreen(guideId: guide.id),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(
                    title: 'Popular Trips',
                    onSeeAllTap: () {
                      Navigator.of(context).push(AppRoutes.allTrips());
                    },
                  ),
                ),
                const SizedBox(height: 12),
                state.trips.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _SectionEmpty(
                          icon: Icons.map_outlined,
                          message:
                              'No trips published yet — guides are adding new trips!',
                        ),
                      )
                    : SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.trips.length > 5
                              ? 5
                              : state.trips.length,
                          itemBuilder: (context, i) {
                            final trip = state.trips[i];
                            return TripCard(
                              trip: trip,
                              onTap: () => _openTripDetails(context, trip),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Travelers in Egypt',
                        style: AppTextStyles.sectionTitle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CommunityBanner(
                    // TODO(Figma): no destination in Figma yet.
                    onJoinTap: () {},
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CommunityStatsRow(),
                ),
                const SizedBox(height: 84),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ChatUnreadBuilder(
        builder: (context, unread) => Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                key: const Key('home-chat-button'),
                tooltip: 'Messages',
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 8,
                shape: const CircleBorder(),
                onPressed: () =>
                    Navigator.of(context).push(AppRoutes.chatList()),
                child: const Icon(Icons.chat_bubble_outline, size: 25),
              ),
            ),
            if (unread > 0)
              Positioned(
                top: -6,
                right: -6,
                child: IgnorePointer(
                  child: Container(
                    key: const Key('home-chat-badge'),
                    constraints: const BoxConstraints(
                      minWidth: 26,
                      minHeight: 26,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      shape: unread > 99 ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: unread > 99
                          ? BorderRadius.circular(13)
                          : null,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, _) => AppBottomNav(
          currentIndex: controller.bottomNavIndex,
          onTap: (index) {
            if (index == 0) {
              controller.setBottomNavIndex(index);
            } else if (index == 1) {
              Navigator.of(context).push(AppRoutes.myTrips());
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: ((context) => MapScreen())),
              ); //map
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: ((context) => CommunityScreen())),
              ); //community
            } else if (index == 4) {
              Navigator.pushNamed(context, AppRoutes.profile);
            }
          },
        ),
      ),
    );
  }

  void _openTripDetails(BuildContext context, Trip trip) {
    // Open the real trip — no mock lookup. The details cubit re-reads
    // the trip from Firestore by its id; the card fields carry over as
    // the offline fallback so a trip never shows another trip's content.
    Navigator.of(context).push(
      AppRoutes.tripDetails(
        trips_model.Trip(
          id: trip.id,
          title: trip.title,
          dateLabel: trip.dateLabel,
          guideName: trip.guideName,
          peopleCount: trip.bookedSeats,
          priceEgp: trip.price,
          imageUrl: trip.imageUrl,
          status: trips_model.TripStatus.upcoming,
          category: '',
          capacity: trip.capacity,
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, String? photoUrl, String name) {
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/edits/home_image.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/edits/Frame 1.png',
                    width: 27,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 6),
                Image.asset(
                  'assets/images/edits/Frame 2.png',
                  height: 28,
                  width: 64,
                  fit: BoxFit.contain,
                ),
                Spacer(),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.notifications);
                      },
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                    ),
                    if (controller.unreadNotifications > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 16),
                          height: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            controller.unreadNotifications > 9
                                ? '9+'
                                : '${controller.unreadNotifications}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                    child: hasPhoto
                        ? null
                        : Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('DISCOVER EGYPT YOUR WAY', style: AppTextStyles.heroSubtitle),
            const SizedBox(height: 4),
            const Text(
              'Ready for your\nnext adventure?',
              style: AppTextStyles.heroTitle,
            ),
            const SizedBox(height: 16),
            SearchInput(
              hint: 'Search for places, trips, or guides...',
              readOnly: true,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.search);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(
            radius: 24,
            child: SizedBox(
              height: 245,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerLine(width: 145, height: 28),
                    SizedBox(height: 48),
                    ShimmerLine(width: 190, height: 12),
                    SizedBox(height: 8),
                    ShimmerLine(width: 230, height: 22),
                    SizedBox(height: 18),
                    ShimmerBox(
                      width: double.infinity,
                      height: 44,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _HomeSectionSkeleton(titleWidth: 140),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => const SizedBox(
                width: 150,
                child: ShimmerCard(
                  child: ShimmerBox(
                    width: 150,
                    height: 190,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const _HomeSectionSkeleton(titleWidth: 110),
          const SizedBox(height: 12),
          for (var i = 0; i < 2; i++)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ShimmerCard(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    ShimmerCircle(size: 44),
                    SizedBox(width: 12),
                    Expanded(child: ShimmerLine(height: 13)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 22),
          const _HomeSectionSkeleton(titleWidth: 130),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 2,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => const SizedBox(
                width: 220,
                child: ShimmerCard(
                  child: ShimmerBox(
                    width: 220,
                    height: 180,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(
              width: double.infinity,
              height: 120,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    ),
  );
}

class _HomeSectionSkeleton extends StatelessWidget {
  const _HomeSectionSkeleton({required this.titleWidth});

  final double titleWidth;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        ShimmerLine(width: titleWidth, height: 18),
        const Spacer(),
        const ShimmerLine(width: 48, height: 12),
      ],
    ),
  );
}

/// The friendly placeholder shown when a home section has no data yet
/// (no approved guides / no approved trips) — instead of blank space.
class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 30),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textDark.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
