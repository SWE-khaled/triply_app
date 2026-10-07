import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../../../../core/helper/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../community/view/community_view.dart';
import '../../home/view/home_screen.dart';
import '../../map/view/map_view.dart';
import '../../trips/models/trip.dart';
import '../../trips/widgets/empty_trips.dart';
import '../../trips/widgets/trip_card.dart';
import '../cubit/my_trips_cubit.dart';
import '../cubit/my_trips_state.dart';
import '../widgets/booking_badges.dart';

/// Booked trips only. Opened after booking_public and from the bottom nav.
/// Details opened from here hide Book Now (already booked).
class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  int bottomIndex = 1; // Trips

  static const List<String> tabLabels = [
    'Upcoming',
    'Ongoing',
    'Completed',
    'Cancelled',
  ];

  static const List<TripStatus> tabValues = [
    TripStatus.upcoming,
    TripStatus.ongoing,
    TripStatus.completed,
    TripStatus.cancelled,
  ];

  void _openDetails(Trip trip) {
    Navigator.of(context).push(AppRoutes.tripDetails(trip, isBooked: true));
  }

  Future<void> _confirmDelete(Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete trip'),
        content: const Text(
          'Are you sure you want to delete this trip? '
          'The paid amount will be refunded to your visa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.accentOrange),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final isPrivate = MyBookingsPublic.isPrivate(trip.id);
    final refunded = MyBookingsPublic.cancelBooking(trip.id);
    if (!context.mounted) return;
    context.read<MyTripsCubit>().refresh();
    final amount = isPrivate
        ? '\$${refunded.toStringAsFixed(0)}'
        : 'EGP ${formatEgp(refunded)}';
    showAppSnackBar(
      context,
      'Trip deleted. $amount has been refunded to your visa.',
      icon: Icons.check_circle,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // Transparent slot so no solid container paints behind the floating
      // glass nav; the body container below provides the background.
      backgroundColor: Colors.transparent,
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          // Let the content extend under the floating glass nav bar.
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text('My Trips', style: AppTextStyles.screenTitle),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                child: Text(
                  'Your Egypt journey, tracked',
                  style: AppTextStyles.screenSubtitle,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.tabUnselectedBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BlocBuilder<MyTripsCubit, MyTripsState>(
                    builder: (context, state) {
                      return Row(
                        children: List.generate(tabValues.length, (i) {
                          final selected = tabValues[i] == state.selectedTab;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => context
                                  .read<MyTripsCubit>()
                                  .selectTab(tabValues[i]),
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.tabSelectedBg
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tabLabels[i],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? AppColors.background
                                        : AppColors.subtitle,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<MyTripsCubit, MyTripsState>(
                  builder: (context, state) {
                    final trips = state.trips;
                    if (trips.isEmpty) {
                      return EmptyTrips(
                        tabName:
                            tabLabels[tabValues.indexOf(state.selectedTab)],
                        title: 'No Trips Yet',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: trips.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        final isPrivate = MyBookingsPublic.isPrivate(trip.id);
                        final isPending = MyBookingsPublic.isPending(trip.id);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 4, bottom: 6),
                            child: Row(
                              children: [
                                BookingKindIcon(isPrivate: isPrivate),
                                if (isPending) ...[
                                  const SizedBox(width: 12),
                                  const PendingApprovalLabel(),
                                ],
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _confirmDelete(trip),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      border: Border.all(
                                          color: AppColors.cardBorder),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: AppColors.accentOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TripCard(
                            trip: trip,
                            currencyLabel: isPrivate ? '\$' : 'EGP',
                            onTap: () => _openDetails(trip),
                              onViewDetails: () => _openDetails(trip),
                              // Chat: placeholder — no chat screen exists yet.
                              onChat: () {},
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: bottomIndex,
        onTap: (i) {
          if (i == bottomIndex) return;
          if (i == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapScreen()),
            );
          } else if (i == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityScreen()),
            );
          } else if (i == 4) {
            Navigator.pushNamed(context, AppRoutes.profile);
          }
        },
      ),
    );
  }
}