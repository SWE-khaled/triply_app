import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../community/view/community_view.dart';
import '../../home/view/home_screen.dart';
import '../../map/view/map_view.dart';
import '../../trips/models/trip.dart';
import '../../trips/widgets/empty_trips.dart';
import '../../trips/widgets/trip_card.dart';
import '../cubit/booking_cancellation_cubit.dart';
import '../cubit/booking_cancellation_state.dart';
import '../cubit/my_trips_cubit.dart';
import '../widgets/booking_badges.dart';

/// Booked trips only. Opened after booking_public and from the bottom nav.
/// Details opened from here hide Book Now (already booked).
class MyTripsScreen extends StatefulWidget {
  /// Set by the post-booking route so a newly confirmed booking is shown
  /// under Upcoming instead of a tab left selected from an earlier visit.
  final bool resetToUpcoming;

  const MyTripsScreen({super.key, this.resetToUpcoming = false});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  int bottomIndex = 1; // Trips

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<MyTripsCubit>();
      if (widget.resetToUpcoming) {
        cubit.refreshUpcoming();
      } else {
        cubit.refresh();
      }
    });
  }

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
        title: const Text('Cancel booking'),
        content: const Text(
          'booking cancelled; the team will handle the refund (test payment)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child:  Text(
              'Cancel booking',
              style: TextStyle(color: AppColors.accentOrange),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<BookingCancellationCubit>().cancel(trip);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCancellationCubit, BookingCancellationState>(
      listener: (context, state) {
        if (!mounted) return;
        if (state is BookingCancelled) {
          showAppSnackBar(
            context,
            'booking cancelled; the team will handle the refund (test payment)',
            icon: Icons.check_circle,
            duration: const Duration(seconds: 5),
          );
        } else if (state is BookingCancelError) {
          showAppSnackBar(context, state.message, icon: Icons.error_outline);
        }
      },
      child: Scaffold(
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
                        final selectedTab = state is MyTripsSuccess
                            ? state.selectedTab
                            : TripStatus.upcoming;
                        return Row(
                          children: List.generate(tabValues.length, (i) {
                            final selected = tabValues[i] == selectedTab;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => context
                                    .read<MyTripsCubit>()
                                    .selectTab(tabValues[i]),
                                behavior: HitTestBehavior.opaque,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
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
                      if (state is! MyTripsSuccess) {
                        if (state is MyTripsError) {
                          return Column(
                            children: [
                              Expanded(
                                child: EmptyTrips(
                                  tabName: 'Upcoming',
                                  title: 'No Trips Yet',
                                  message:
                                      'Could not load your trips. ${state.error}',
                                ),
                              ),
                              TextButton(
                                onPressed: context.read<MyTripsCubit>().refresh,
                                child: const Text('Try again'),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                        return const _MyTripsSkeleton();
                      }
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
                          final isPrivate =
                              trip.category == 'private' ||
                              MyBookingsPublic.isPrivate(trip.id);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 6,
                                ),
                                child: BookingKindIcon(isPrivate: isPrivate),
                              ),
                              Stack(
                                children: [
                                  TripCard(
                                    trip: trip,
                                    currencyLabel: isPrivate ? '\$' : 'EGP',
                                    onTap: () => _openDetails(trip),
                                    onViewDetails: () => _openDetails(trip),
                                    // Chat: placeholder — no chat screen exists yet.
                                    onChat: () {},
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: PopupMenuButton<String>(
                                      tooltip: 'Trip options',
                                      padding: const EdgeInsets.all(8),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _confirmDelete(trip);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppColors.accentOrange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                      icon:  Icon(
                                        Icons.more_vert,
                                        size: 20,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ],
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
      ),
    );
  }
}

class _MyTripsSkeleton extends StatelessWidget {
  const _MyTripsSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Row(
                children: const [
                  ShimmerBox(width: 92, height: 26),
                  Spacer(),
                  ShimmerBox(width: 34, height: 34),
                ],
              ),
            ),
            ShimmerCard(
              radius: 16,
              child: Row(
                children: [
                  const ShimmerBox(
                    width: 105,
                    height: 148,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          ShimmerLine(width: 130, height: 14),
                          SizedBox(height: 10),
                          ShimmerLine(width: 100, height: 11),
                          SizedBox(height: 8),
                          ShimmerLine(width: 120, height: 11),
                          SizedBox(height: 18),
                          ShimmerLine(width: 70, height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
