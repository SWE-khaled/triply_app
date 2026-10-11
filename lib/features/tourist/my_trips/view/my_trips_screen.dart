import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_routes.dart';
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
  String? _uid;
  bool _loadRequested = false;

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

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    // Server list is primary ([MyTripsCubit.useRemote]); an empty server
    // response stays honestly empty — never mock fallback.
    if (MyTripsCubit.useRemote) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTrips());
    }
  }

  /// Best-effort server load, guarded so rebuilds never duplicate it.
  /// Failures surface in the error view/banner (never as mock trips).
  Future<void> _loadTrips() async {
    if (!mounted || _loadRequested) return;
    _loadRequested = true;
    try {
      await context.read<MyTripsCubit>().loadRemote(_uid);
    } finally {
      _loadRequested = false;
    }
  }

  void _openDetails(Trip trip) {
    Navigator.of(context).push(AppRoutes.tripDetails(trip, isBooked: true));
  }

  /// Server-side cancellation. The UI updates only after the callable
  /// confirms; refund wording follows the server `refundStatus` exactly —
  /// no amounts and no visa claims are ever invented here.
  Future<void> _cancelBooking(Trip trip) async {
    final cubit = context.read<MyTripsCubit>();
    final bookingId = trip.bookingId;
    if (bookingId == null || cubit.state.cancellingIds.contains(bookingId)) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Cancel booking',
              style: TextStyle(color: AppColors.accentOrange),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final refundStatus = await cubit.cancelBooking(
        uid: _uid,
        bookingId: bookingId,
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        refundStatus == 'owed'
            ? 'Booking cancelled. Our team will process your refund manually.'
            : 'Booking cancelled.',
        icon: Icons.check_circle,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, _cancelError(e));
    }
  }

  /// Server/callable errors already carry user-facing messages behind an
  /// `Exception:` prefix; anything else becomes a generic failure.
  /// Never logs tokens, payment data, or user identifiers.
  String _cancelError(Object e) {
    final text = e.toString();
    const prefix = 'Exception: ';
    final msg = text.startsWith(prefix) ? text.substring(prefix.length) : text;
    return msg.isEmpty ? 'Cancellation failed. Please try again.' : msg;
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
                    final cubit = context.read<MyTripsCubit>();
                    if (state.isLoading && state.trips.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.error != null && state.trips.isEmpty) {
                      return _ErrorView(
                        message: state.error!,
                        onRetry: _loadTrips,
                      );
                    }
                    final trips = state.trips;
                    if (trips.isEmpty) {
                      return EmptyTrips(
                        tabName:
                            tabLabels[tabValues.indexOf(state.selectedTab)],
                        title: 'No Trips Yet',
                      );
                    }
                    return Column(
                      children: [
                        if (state.error != null)
                          _ErrorBanner(
                            message: state.error!,
                            onRetry: _loadTrips,
                          ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                            itemCount: trips.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final trip = trips[index];
                              final bookingId = trip.bookingId;
                              final isPrivate = cubit.isPrivateBooking(
                                bookingId,
                              );
                              final isPending = cubit.isPendingApproval(
                                bookingId,
                              );
                              final cancellable = cubit.isCancellable(
                                bookingId,
                              );
                              final cancelling =
                                  bookingId != null &&
                                  state.cancellingIds.contains(bookingId);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        BookingKindIcon(isPrivate: isPrivate),
                                        if (isPending) ...[
                                          const SizedBox(width: 12),
                                          const PendingApprovalLabel(),
                                        ],
                                        const Spacer(),
                                        // Cancel is offered only for active
                                        // bookings; history tabs have no
                                        // action that could not succeed.
                                        if (cancellable)
                                          GestureDetector(
                                            onTap: cancelling
                                                ? null
                                                : () => _cancelBooking(trip),
                                            behavior: HitTestBehavior.opaque,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.background,
                                                border: Border.all(
                                                  color: AppColors.cardBorder,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: cancelling
                                                  ? const SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    )
                                                  : const Icon(
                                                      Icons.delete_outline,
                                                      size: 18,
                                                      color: AppColors
                                                          .accentOrange,
                                                    ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  TripCard(
                                    trip: trip,
                                    currencyLabel: cubit.currencyFor(bookingId),
                                    onTap: () => _openDetails(trip),
                                    onViewDetails: () => _openDetails(trip),
                                    // Chat: placeholder — no chat screen exists yet.
                                    onChat: () {},
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
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

/// Full-screen load failure with retry. Shown only when no cached trips
/// exist; a failed refresh over a live list uses [_ErrorBanner] instead.
class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: AppColors.subtitle,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.subtitle,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onRetry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tabSelectedBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline failure notice above a stale-but-visible list, with retry.
class _ErrorBanner extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtitle,
              ),
            ),
          ),
          TextButton(onPressed: () => onRetry(), child: const Text('Retry')),
        ],
      ),
    );
  }
}
