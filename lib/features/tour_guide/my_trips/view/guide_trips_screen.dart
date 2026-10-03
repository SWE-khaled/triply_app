import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../data/guide_trip_details_source.dart';
import '../cubit/guide_trips_cubit.dart';
import '../cubit/guide_trips_state.dart';
import '../model/guide_trip.dart';
import '../widgets/guide_bottom_nav.dart';
import '../widgets/guide_trip_card.dart';
import '../widgets/rejected_guide_trip_card.dart';

/// Guide-side trips: create + manage own trips.
/// Self-provides its cubit so every entry (route table, main, tabs)
/// works — never rely on an ancestor provider.
/// Create/View/Manage destinations don't exist in Figma yet → toasts.
class GuideTripsScreen extends StatelessWidget {
  const GuideTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuideTripsCubit(),
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
              child: Expanded(
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
            Navigator.of(context).push(AppRoutes.guideProfile());
            return;
          }
          // TODO: navigate when guide Home exists.
          _todo('This section');
        },
      ),
    );
  }
}
