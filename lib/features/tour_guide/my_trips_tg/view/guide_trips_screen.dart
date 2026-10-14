import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/view/guide_dashboard_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/data/guide_trip_details_source.dart';
import '../../../../data/firestore/datasources/firestore_query_helper.dart';
import '../../../../data/firestore/datasources/trips_datasource.dart';
import '../../../../data/firestore/mappers/firestore_mappers.dart';
import '../../trip_details_tg/model/guide_trip_details.dart';
import '../cubit/guide_trips_cubit.dart';
import '../cubit/guide_trips_state.dart';
import '../model/guide_trip.dart';
import '../../homeandNotificationTr/widget/guide_bottom_nav.dart';
import '../widgets/guide_trip_card.dart';
import '../widgets/rejected_guide_trip_card.dart';

/// Guide-side trips: create + manage own trips.
/// Self-provides its cubit so every entry (route table, main, tabs)
/// works — never rely on an ancestor provider.
/// Create/View/Manage destinations don't exist in Figma yet → toasts.
class GuideTripsScreen extends StatelessWidget {
  /// Tab pre-selected on entry (e.g. from Dashboard cards).
  final GuideTripStatus initialStatus;

  const GuideTripsScreen({
    super.key,
    this.initialStatus = GuideTripStatus.active,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuideTripsCubit(initialStatus: initialStatus),
      child: const _GuideTripsView(),
    );
  }
}

class _GuideTripsView extends StatefulWidget {
  const _GuideTripsView();

  @override
  State<_GuideTripsView> createState() => _GuideTripsViewState();
}

class _GuideTripsViewState extends State<_GuideTripsView> {
  int bottomIndex = 1; // My Trips

  static const List<GuideTripStatus> tabValues = [
    GuideTripStatus.active,
    GuideTripStatus.pending,
    GuideTripStatus.rejected,
    GuideTripStatus.completed,
    GuideTripStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    // Initial load: spinner first (never mock/session rows), then the
    // guide's Firebase trips. Session/mock list stays only when signed
    // out or when remote fails (with an explicit notice).
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  /// First load for this screen. Shows a failure notice only when a
  /// signed-in guide's remote fetch fails.
  Future<void> _loadInitial() async {
    if (!mounted) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ok = await context.read<GuideTripsCubit>().loadInitial(uid);
    if (!ok && mounted && uid != null && uid.isNotEmpty) {
      showAppSnackBar(
        context,
        'Could not load trips. Please try again.',
        icon: Icons.info_outline,
      );
    }
  }

  /// Loads the signed-in guide's trips through the existing
  /// repository/datasource bridge. A failure keeps the current
  /// session/mock list with an explicit notice — never presented
  /// as a successful remote fetch.
  Future<void> _refreshRemote() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    if (!mounted) return;
    final ok = await context.read<GuideTripsCubit>().loadRemote(uid);
    if (!ok && mounted) {
      showAppSnackBar(
        context,
        'Could not refresh trips. Showing saved trips.',
        icon: Icons.info_outline,
      );
    }
  }

  void _openDetails(BuildContext context, GuideTrip trip) {
    // Reload on return: an edit may have changed this trip.
    Navigator.of(context).push(AppRoutes.guideTripDetails(trip)).then((_) {
      if (context.mounted) {
        context.read<GuideTripsCubit>().refresh();
      }
    });
  }

  void _openCreate(BuildContext context) {
    // After a successful submit, land on Pending where the new trip is,
    // then refresh from Firebase so the saved document (not just the
    // session copy) backs the list.
    Navigator.of(context).push(AppRoutes.createTrip()).then((created) async {
      if (created == true && context.mounted) {
        context.read<GuideTripsCubit>().selectStatus(GuideTripStatus.pending);
        await _refreshRemote();
      }
    });
  }

  void _openManage(BuildContext context, GuideTrip trip) async {
    // Exact session/mock match first (sync): offline and mock flows keep
    // working with no network and no design change.
    final local = const GuideTripDetailsSource().getByTripId(
      trip.id,
      title: trip.title,
      imageUrl: trip.imageUrl,
      priceEgp: trip.priceEgp,
    );
    if (local.id != 'fallback') {
      _pushManage(context, trip, local);
      return;
    }
    // Real Firestore document: loading dialog first, never mock filler.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator()),
    );
    try {
      final doc = await TripsDatasource().getById(trip.id);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Dismiss the loader.
      if (doc == null) {
        _manageError(
          context,
          trip,
          'Trip not found. It may have been deleted.',
        );
        return;
      }
      _pushManage(
        context,
        trip,
        FirestoreMappers.tripDocToGuideTripDetails(doc),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Dismiss the loader.
      _manageError(
        context,
        trip,
        FirestoreQueryHelper.friendlyError(e),
      );
    }
  }

  void _pushManage(
    BuildContext context,
    GuideTrip trip,
    GuideTripDetails details,
  ) {
    Navigator.of(
      context,
    ).push(AppRoutes.manageTrip(trip: trip, details: details)).then((_) {
      if (context.mounted) {
        context.read<GuideTripsCubit>().refresh();
      }
    });
  }

  /// Error with a Retry action that re-runs the manage flow.
  void _manageError(BuildContext context, GuideTrip trip, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              if (context.mounted) _openManage(context, trip);
            },
          ),
        ),
      );
  }

  void _todo(String what) {
    showAppSnackBar(
      context,
      '$what is not available yet',
      icon: Icons.info_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text('My Trips', style: AppTextStyles.screenTitle),
                  Text(
                    'Create and manage all your trips.',
                    style: AppTextStyles.screenSubtitle,
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => _openCreate(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.tabSelectedBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create a new trip',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Add details, itinerary, availability and pricing',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openCreate(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<GuideTripsCubit, GuideTripsState>(
                builder: (context, state) {
                  return Row(
                    children: List.generate(tabValues.length, (i) {
                      final value = tabValues[i];
                      final selected = value == state.selectedStatus;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => context
                              .read<GuideTripsCubit>()
                              .selectStatus(value),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.tabSelectedBg
                                  : AppColors.tabUnselected,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              GuideTripsCubit.label(value),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.primary,
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
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<GuideTripsCubit, GuideTripsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final trips = state.trips;
                  if (trips.isEmpty) {
                    return Center(
                      child: Text(
                        'No ${GuideTripsCubit.label(state.selectedStatus).toLowerCase()} trips yet',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.subtitle,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: trips.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      if (trip.status == GuideTripStatus.rejected) {
                        return RejectedGuideTripCard(
                          trip: trip,
                          onPreview: () => _openDetails(context, trip),
                          onEditResubmit: () =>
                              _todo('Editing and resubmitting'),
                        );
                      }
                      return GuideTripCard(
                        trip: trip,
                        onMenu: () => _todo('Trip options'),
                        onView: () => _openDetails(context, trip),
                        onManage: () => _openManage(context, trip),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GuideBottomNav(
        currentIndex: bottomIndex,
        onTap: (i) {
          if (i == bottomIndex) return;
          if (i == 2) {
            // Guide's own profile_tg (Nour Abdallah in mock data).
            Navigator.of(context).push(AppRoutes.guideProfile('g2'));
            return;
          }
          if (i == 0) {
            // Back to guide Home (dashboard pushed this screen).
            Navigator.push(context, MaterialPageRoute(builder: (context)=>GuideDashboardScreen()));
            return;
          }
        },
      ),
    );
  }
}
