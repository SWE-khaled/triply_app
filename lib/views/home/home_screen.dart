import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/community_banner.dart';
import '../../core/widgets/guide_tile.dart';
import '../../core/widgets/place_card.dart';
import '../../core/widgets/search_input.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/trip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = HomeController();
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(context),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: 'Popular Places',
                // TODO(Figma): no destination in Figma yet.
                onSeeAllTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.places.length,
                itemBuilder: (context, i) {
                  final place = controller.places[i];
                  return PlaceCard(
                    place: place,
                    // TODO(Figma): no details screen in Figma yet.
                    onTap: () {},
                    onFavoriteTap: () => controller.toggleFavorite(place.id),
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
                onSeeAllTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final guide in controller.guides)
                    GuideTile(
                      guide: guide,
                      // TODO(Figma): no details screen in Figma yet.
                      onTap: () {},
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: 'Popular Trips',
                // TODO(Figma): no destination in Figma yet.
                onSeeAllTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.trips.length,
                itemBuilder: (context, i) {
                  final trip = controller.trips[i];
                  return TripCard(
                    trip: trip,
                    // TODO(Figma): no details screen in Figma yet.
                    onTap: () {},
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
                  Text('Travelers in Egypt', style: AppTextStyles.sectionTitle),
                  Text('Join >', style: AppTextStyles.seeAll),
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
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: controller.bottomNavIndex,
        onTap: (index) {
          if (index == 0) {
            controller.setBottomNavIndex(index);
          } else {
            // TODO(Figma): Trips/Map/Community/Profile screens not in Figma.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Not in Figma yet (mock only)')),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://picsum.photos/seed/egypt-hero/900/700'),
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
                const Expanded(
                  child: Text('triply',
                      style: TextStyle(
                          fontSize: 32,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                ),
                const CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://picsum.photos/seed/avatar/100/100'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('DISCOVER EGYPT YOUR WAY',
                style: AppTextStyles.heroSubtitle),
            const SizedBox(height: 4),
            const Text('Ready for your\nnext adventure?',
                style: AppTextStyles.heroTitle),
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
