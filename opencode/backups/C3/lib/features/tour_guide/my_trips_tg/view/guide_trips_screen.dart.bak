import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triply/features/tour_guide/home_and_notification_tg/view/guide_dashboard_screen.dart';
import 'package:triply/features/common/AuthTourist/cubit/auth_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/data/guide_trip_details_source.dart';
import '../../../../core/widgets/state_views.dart';
import '../cubit/guide_trips_cubit.dart';
import '../model/guide_trip.dart';
import '../../home_and_notification_tg/widget/guide_bottom_nav.dart';
import '../widgets/guide_trip_card.dart';
import '../widgets/rejected_guide_trip_card.dart';

/// Guide-side trips: create + manage own trips.
/// Self-provides its cubit so every entry (route table, main, tabs)
/// works â€” never rely on an ancestor provider.
/// Create/View/Manage destinations don't exist in Figma yet â†’ toasts.
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

  /// The status tabs of the screen. `completed` and `cancelled` are not
  /// shown as tabs (the guide cannot act on those trips anymore) — but
  /// the filter itself still accepts them, so the dashboard's
  /// "Completed Trips" card can open the completed list directly.
  static const List<GuideTripStatus> tabValues = [
    GuideTripStatus.active,
    GuideTripStatus.pending,
    GuideTripStatus.rejected,
  ];

  void _openDetails(BuildContext context, GuideTrip trip) {
    // Reload on return: an edit may have changed this trip.
    Navigator.of(context).push(AppRoutes.guideTripDetails(trip)).then((_) {
      if (context.mounted) {
        context.read<GuideTripsCubit>().refresh();
      }
    });
  }

  void _openCreate(BuildContext context) {
    // After a successful submit, land on Pending where the new trip is.
    Navigator.of(context).push(AppRoutes.createTrip()).then((created) {
      if (created == true && context.mounted) {
        context.read<GuideTripsCubit>().selectStatus(GuideTripStatus.pending);
      }
    });
  }

  void _openManage(BuildContext context, GuideTrip trip) {
    final details = const GuideTripDetailsSource().getByTripId(
      trip.id,
      title: trip.title,
      imageUrl: trip.imageUrl,
      priceEgp: trip.priceEgp,
    );
    Navigator.of(
      context,
    ).push(AppRoutes.manageTrip(trip: trip, details: details)).then((_) {
      if (context.mounted) {
        context.read<GuideTripsCubit>().refresh();
      }
    });
  }

  /// Opens the edit form for a rejected trip. Saving it sends the trip
  /// back for review.
  void _openEditResubmit(BuildContext context, GuideTrip trip) {
    final details = const GuideTripDetailsSource().getByTripId(
      trip.id,
      title: trip.title,
      imageUrl: trip.imageUrl,
      priceEgp: trip.priceEgp,
    );
    Navigator.of(
      context,
    ).push(AppRoutes.editTrip(trip: trip, details: details)).then((_) {
      if (context.mounted) {
        context.read<GuideTripsCubit>().refresh();
      }
    });
  }

  /// Asks before deleting: a trip cannot come back from Firestore.
  Future<void> _confirmDelete(BuildContext context, GuideTrip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete trip?',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.title,
            ),
          ),
          content: Text(
            '"${trip.title}" will be removed permanently, together with its details.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.subtitle,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subtitle,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<GuideTripsCubit>().deleteTrip(trip);
    if (!context.mounted) return;
    final state = context.read<GuideTripsCubit>().state;
    if (state is GuideTripsSuccess) {
      showAppSnackBar(context, 'Trip deleted', icon: Icons.check_circle);
    } else if (state is GuideTripsError) {
      showAppSnackBar(context, state.error, icon: Icons.error_outline);
    }
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
                  final selectedStatus = state is GuideTripsSuccess
                      ? state.selectedStatus
                      : GuideTripStatus.active;
                  return Row(
                    children: List.generate(tabValues.length, (i) {
                      final value = tabValues[i];
                      final selected = value == selectedStatus;
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
                  return switch (state) {
                    GuideTripsSuccess(:final trips) =>
                      trips.isEmpty
                          ? Center(
                              child: Text(
                                'No ${GuideTripsCubit.label(state.selectedStatus).toLowerCase()} trips yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.subtitle,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: trips.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final trip = trips[index];
                                if (trip.status == GuideTripStatus.rejected) {
                                  return RejectedGuideTripCard(
                                    trip: trip,
                                    onPreview: () =>
                                        _openDetails(context, trip),
                                    onEditResubmit: () =>
                                        _openEditResubmit(context, trip),
                                  );
                                }
                                return GuideTripCard(
                                  trip: trip,
                                  onView: () => _openDetails(context, trip),
                                  onManage: () => _openManage(context, trip),
                                  onDelete: () => _confirmDelete(context, trip),
                                );
                              },
                            ),
                    GuideTripsInitial() ||
                    GuideTripsLoading() => const AppLoadingView(),
                    GuideTripsError(:final error) => AppErrorView(
                      message: error,
                      onRetry: () => context.read<GuideTripsCubit>().refresh(),
                    ),
                  };
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
            // The guide's own profile — always the signed-in account,
            // never a mock guide id.
            final uid = context.read<AuthCubit>().user?.uid;
            if (uid == null) {
              showAppSnackBar(
                context,
                'Sign in to see your profile',
                icon: Icons.info_outline,
              );
              return;
            }
            Navigator.of(context).push(AppRoutes.guideProfile(uid));
            return;
          }
          if (i == 0) {
            // Back to guide Home. The old screens are removed instead of
            // stacked: every screen owns a live Firestore subscription,
            // so keeping them alive would pile them up.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const GuideDashboardScreen(),
              ),
              (route) => route.isFirst,
            );
            return;
          }
        },
      ),
    );
  }
}
