import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../trips/models/trip.dart';
import '../../trips/widgets/trip_card.dart';
import '../cubit/popular_cubit.dart';
import '../cubit/popular_state.dart';

class PopularTripsScreen extends StatelessWidget {
  const PopularTripsScreen({super.key});

  void _openDetails(BuildContext context, Trip trip) {
    Navigator.of(context).push(AppRoutes.tripDetails(trip));
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
              padding: const EdgeInsets.fromLTRB(16, 20, 20, 0),
              child: Row(
                children: [
                  const CircleBackButton(),
                  const SizedBox(width: 12),
                  Text(
                    'Popular Trips',
                    style: AppTextStyles.screenTitle,
                  ),
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
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<PopularCubit, PopularState>(
                builder: (context, state) {
                  return Row(
                    children: List.generate(
                      PopularCubit.categories.length,
                      (i) {
                        final label =
                            PopularCubit.categories[i];
                        final selected =
                            label == state.selectedCategory;
                        return Padding(
                          padding:
                              const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => context
                                .read<PopularCubit>()
                                .selectCategory(label),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.tabSelectedBg
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.tabSelectedBg
                                      : AppColors.cardBorder,
                                ),
                              ),
                              child: Text(
                                label,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.subtitle,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<PopularCubit, PopularState>(
                builder: (context, state) {
                  final trips = state.trips;
                  if (trips.isEmpty) {
                    return const Center(
                      child: Text(
                        'No trips here yet',
                        style: TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: trips.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return TripCard(
                        trip: trip,
                        onTap: () =>
                            _openDetails(context, trip),
                        onViewDetails: () =>
                            _openDetails(context, trip),
                        // Chat: placeholder — no chat screen exists yet.
                        onChat: () => showAppSnackBar(
                          context,
                          'Chat not available yet',
                          icon: Icons.info_outline,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
