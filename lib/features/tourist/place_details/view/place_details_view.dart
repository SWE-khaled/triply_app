import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/place_detail_cubit.dart';
import '../cubit/place_detail_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../../core/widgets/network_image_fallback.dart';
import '../../guides/view/guide_profile_screen.dart';
import '../widget/about_tab.dart';
import '../widget/guides_tab.dart';
import '../widget/stories_tab.dart';
import '../widget/trips_tab.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late final PlaceDetailCubit controller;
  final List<String> tabs = const ['About', 'Guides', 'Trips', 'Stories'];

  @override
  void initState() {
    super.initState();
    // Owned here (like the old controller) so the body below keeps working
    // unchanged; provided below for BlocBuilder rebuilds.
    controller = PlaceDetailCubit(placeId: widget.placeId);
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: controller,
      child: BlocBuilder<PlaceDetailCubit, PlaceDetailState>(
        builder: (context, _) {
    final place = controller.place;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                NetworkImageFallback(
                  imageUrl: place.imageUrl,
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.cover,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CircleBackButton(),
                        ],
                      ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${place.city}  ·  ${place.category}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 15,
                          color: AppColors.starGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place.rating.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          ' (${place.reviewsCount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} reviews)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: AppColors.textGrey,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      place.shortDescription,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        letterSpacing: 0,
                        height: 2,
                        color: Color(0xFF526B72),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(tabs.length, (i) {
                          final selected = controller.selectedTabIndex == i;
                          return Padding(
                            padding: EdgeInsets.only(
                              right: i == tabs.length - 1 ? 0 : 8,
                            ),
                            child: ChoiceChip(
                              label: Text(tabs[i]),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  controller.selectTab(i);
                                });
                              },
                              selectedColor: AppColors.primaryTeal,
                              backgroundColor: AppColors.chipGrey,
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.chipTextGrey,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                letterSpacing: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide.none,
                              ),
                              showCheckmark: false,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (controller.selectedTabIndex == 0)
                      AboutTab(place: place)
                    else if (controller.selectedTabIndex == 1)
                      GuidesTab(
                        guides: controller.guides,
                        onGuideTap: (guide) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GuideProfileScreen(
                                guideId:
                                    controller.guideProfileIdFor(guide),
                              ),
                            ),
                          );
                        },
                      )
                    else if (controller.selectedTabIndex == 2)
                      TripsTab(
                        trips: controller.trips,
                        onViewDetails: (trip) {
                          Navigator.of(context).push(
                            AppRoutes.tripDetails(
                              controller.publicTripFor(trip),
                            ),
                          );
                        },
                        onChat: (_) {},
                      )
                    else
                      StoriesTab(
                        stories: controller.stories,
                        // Placeholder: no Story-detail in Figma.
                        onStoryTap: (_) {
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
        },
      ),
    );
  }
}
