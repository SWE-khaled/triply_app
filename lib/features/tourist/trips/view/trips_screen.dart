import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triply/core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../../core/widgets/state_views.dart';
import '../cubit/trips_cubit.dart';
import '../cubit/trips_state.dart';
import '../models/trip.dart';
import '../widgets/empty_trips.dart';
import '../widgets/trip_card.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  int bottomIndex = 1; // Trips

  static const List<String> tabLabels = ['Upcoming', 'Completed'];

  static const List<TripStatus> tabValues = [
    TripStatus.upcoming,
    TripStatus.completed,
  ];

  void _openDetails(Trip trip) {
    Navigator.of(context).push(AppRoutes.tripDetails(trip));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<TripsCubit, TripsState>(
          builder: (context, state) {
            if (state.isLoading) return const _TripsScreenSkeleton();
            if (state.error != null) {
              return AppErrorView(
                message: state.error!,
                onRetry: context.read<TripsCubit>().load,
              );
            }
            final trips = state.trips;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildTabs(context, state.selectedTab),
                const SizedBox(height: 12),
                Expanded(
                  child: trips.isEmpty
                      ? EmptyTrips(
                          tabName:
                              tabLabels[tabValues.indexOf(state.selectedTab)],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: trips.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final trip = trips[index];
                            return TripCard(
                              trip: trip,
                              onTap: () => _openDetails(trip),
                              onViewDetails: () => _openDetails(trip),
                              onChat: () {},
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 20, 0),
        child: Row(
          children: [
            const CircleBackButton(),
            const SizedBox(width: 12),
            Text('Trips', style: AppTextStyles.screenTitle),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
        child: Text(
          'Your Egypt journey, tracked',
          style: AppTextStyles.screenSubtitle,
        ),
      ),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildTabs(BuildContext context, TripStatus selectedTab) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.tabUnselectedBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabValues.length, (i) {
          final selected = tabValues[i] == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => context.read<TripsCubit>().selectTab(tabValues[i]),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                    color: selected ? AppColors.background : AppColors.subtitle,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}

class _TripsScreenSkeleton extends StatelessWidget {
  const _TripsScreenSkeleton();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 20, 0),
          child: Row(
            children: [
              const ShimmerCircle(size: 41),
              const SizedBox(width: 12),
              const ShimmerLine(width: 72, height: 22),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: ShimmerLine(width: 185, height: 13),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerBox(
            width: double.infinity,
            height: 46,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, _) => const _TripCardSkeleton(),
          ),
        ),
      ],
    ),
  );
}

class _TripCardSkeleton extends StatelessWidget {
  const _TripCardSkeleton();

  @override
  Widget build(BuildContext context) => ShimmerCard(
    radius: 16,
    child: const SizedBox(
      height: 148,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShimmerBox(
            width: 105,
            height: 148,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 12, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLine(width: 145, height: 14),
                      SizedBox(height: 7),
                      ShimmerLine(width: 105, height: 12),
                      SizedBox(height: 7),
                      ShimmerLine(width: 120, height: 12),
                    ],
                  ),
                  Row(
                    children: [
                      ShimmerCircle(size: 14),
                      SizedBox(width: 8),
                      ShimmerLine(width: 46, height: 12),
                      Spacer(),
                      ShimmerLine(width: 72, height: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
