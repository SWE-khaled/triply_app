import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triply/features/UserProfile/view/profile_screen.dart';
import 'package:triply/features/community/view/community_view.dart';
import 'package:triply/features/guides/view/guides_list_screen.dart';
import 'package:triply/features/map/view/map_view.dart';
import 'package:triply/features/my_trips/view/my_trips_screen.dart';
import 'package:triply/features/popular/view/popular_trips_screen.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../auth/providers/auth_provider.dart';
import '../controller/home_controller.dart';
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
    final user = context.watch<AuthProvider>().user;
    final photoUrl = user?.photoURL;
    final name = user?.displayName ?? '';

    return Scaffold(
      body: SingleChildScrollView(
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
         
            Navigator.push(context,MaterialPageRoute(builder: ((context)=>MapScreen())));
                },
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
                onSeeAllTap: () {
                Navigator.push(context,MaterialPageRoute(builder: ((context)=>GuidesListScreen())));

                },
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
                onSeeAllTap: () {
                  
                },
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
          }
          //else if (index == 1) {
          //  Navigator.push(context,MaterialPageRoute(builder: ((context)=>MyTripsScreen())));//My trip
          //}
           else if (index == 2) {
            Navigator.push(context,MaterialPageRoute(builder: ((context)=>MapScreen()))); //map
          }
           else if (index == 3) {
            Navigator.push(context,MaterialPageRoute(builder: ((context)=>CommunityScreen())));//community
         }           
           else if (index == 4) {
            Navigator.pushNamed(context, AppRoutes.profile);
          } 
        },
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, String? photoUrl, String name) {
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSBQ8iDG5Hk8guqcSGPtMI6kq6YchZ67Ig8j5hvwBSiHA&s=10',
          ),
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
                  child: Text(
                    'Triply',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
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
            const SizedBox(height: 8),
            const Text(
              'DISCOVER EGYPT YOUR WAY',
              style: AppTextStyles.heroSubtitle,
            ),
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
