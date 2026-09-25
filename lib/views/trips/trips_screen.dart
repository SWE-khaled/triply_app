import 'package:flutter/material.dart';
import '../../controllers/trips_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/trip.dart';
import '../trip_details/trip_details_screen.dart';
import 'widgets/trip_card.dart';
import 'package:google_fonts/google_fonts.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final TripsController controller = TripsController();
  TripStatus selectedTab = TripStatus.upcoming;
  int bottomIndex = 1; // My Trips

  //todo this tab
  // static const List<String> tabLabels = [
  //   'Upcoming',
  //   'Ongoing',
  //   'Completed',
  //   'Cancelled',
  // ];
  //
  // static const List<TripStatus> tabValues = [
  //   TripStatus.upcoming,
  //   TripStatus.ongoing,
  //   TripStatus.completed,
  //   TripStatus.cancelled,
  // ];

  void _openDetails(Trip trip) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TripDetailsScreen(trip: trip)));
  }

  @override
  Widget build(BuildContext context) {
    final trips = controller.getTripsByStatus(selectedTab);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Trips',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.title,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Text(
                'Your Egypt journey, tracked',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.subtitle,
                ),
              ),
            ),
            const SizedBox(height: 16),
            //todo delete this tab
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Container(
            //     padding: const EdgeInsets.all(5),
            //     decoration: BoxDecoration(
            //       color: AppColors.tabUnselectedBg,
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Row(
            //       children:
            //           List.generate(tabValues.length, (i) {
            //         final selected =
            //             tabValues[i] == selectedTab;
            //         return Expanded(
            //           child: GestureDetector(
            //             onTap: () {
            //               setState(
            //                   () => selectedTab = tabValues[i]);
            //             },
            //             behavior: HitTestBehavior.opaque,
            //             child: AnimatedContainer(
            //               duration: const Duration(milliseconds: 200),
            //               alignment: Alignment.center,
            //               padding: const EdgeInsets.symmetric(
            //                   vertical: 10),
            //               decoration: BoxDecoration(
            //                 color: selected
            //                     ? AppColors.tabSelectedBg
            //                     : Colors.transparent,
            //                 borderRadius:
            //                     BorderRadius.circular(12),
            //               ),
            //               child: Text(
            //                 tabLabels[i],
            //                 style: GoogleFonts.poppins(
            //                   fontSize: 12,
            //                   fontWeight: FontWeight.w600,
            //                   color: selected
            //                       ? AppColors.background
            //                       : AppColors.subtitle,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         );
            //       }),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 12),
            Expanded(
              child: trips.isEmpty
                  ? const Center(
                      child: Text(
                        'No trips here yet',
                        style: TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: trips.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return TripCard(
                          trip: trip,
                          onTap: () => _openDetails(trip),
                          onViewDetails: () => _openDetails(trip),
                          // Chat: placeholder — no chat screen exists yet.
                          onChat: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: bottomIndex,
        // Only My Trips exists; other tabs are placeholders.
        onTap: (i) {
          if (i == bottomIndex) return;
          // TODO: navigate when Home/Map/Community/Profile screens exist.
          showAppSnackBar(
            context,
            'Screen not available yet',
            icon: Icons.info_outline,
          );
        },
      ),
    );
  }
}
