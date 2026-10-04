import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/data/mock/tourist/mock_guides.dart';
import '../../../../core/theme/app_colors.dart';
import '../../guides/view/guide_profile_screen.dart';
import '../../trips/models/trip.dart';
import '../cubit/trip_details_cubit.dart';
import '../cubit/trip_details_state.dart';
import '../widgets/booking_bar.dart';
import '../widgets/details_header.dart';
import '../widgets/details_info.dart';
import '../widgets/details_tab_content.dart';
import '../widgets/details_tabs.dart';
import '../widgets/guide_card.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  /// True when opened from My Trips (already booked): hides Book Now.
  final bool isBooked;

  const TripDetailsScreen({
    super.key,
    required this.trip,
    this.isBooked = false,
  });

  static const List<String> tabs = [
    'About',
    'Highlights',
    'Itinerary',
    'Notes',
  ];

  void _openGuideProfile(BuildContext context, String guideName) {
    final guide = mockGuides.firstWhere(
      (g) => g.name == guideName,
      orElse: () => mockGuides.first,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GuideProfileScreen(guideId: guide.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<TripDetailsCubit, TripDetailsState>(
        builder: (context, state) {
          final details = state.details;
          if (details == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                DetailsHeader(
                  imageUrl: details.imageUrl,
                  onBack: () => Navigator.of(context).pop(),
                ),
                Container(
                  width: double.infinity,
                  transform: Matrix4.translationValues(0, -24, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailsInfo(details: details),
                        const SizedBox(height: 18),
                        DetailsTabs(
                          tabs: tabs,
                          selectedIndex: state.selectedTab,
                          onSelected: (i) =>
                              context.read<TripDetailsCubit>().selectTab(i),
                        ),
                        const SizedBox(height: 14),
                        DetailsTabContent(
                          details: details,
                          selectedTab: state.selectedTab,
                        ),
                        const SizedBox(height: 16),
                        BookingBar(
                          details: details,
                          showBookNow: !isBooked,
                          onBookNow: () => Navigator.of(
                            context,
                          ).push(AppRoutes.booking(trip)),
                        ),
                        const SizedBox(height: 14),
                        GuideCard(
                          details: details,
                          onTap: () =>
                              _openGuideProfile(context, details.guideName),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
