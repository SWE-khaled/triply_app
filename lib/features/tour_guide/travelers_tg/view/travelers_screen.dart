import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../../core/widgets/state_views.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../cubit/travelers_cubit.dart';
import '../widgets/traveler_card.dart';

/// Traveler list for one guide trip. Self-provides its cubit.
/// View Profile has no destination screen in Figma â†’ placeholder toast.
/// Check-in is display-only in this phase (no backend).
class TravelersScreen extends StatelessWidget {
  final GuideTrip trip;

  const TravelersScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TravelersCubit()..loadTrip(trip.id),
      child: _TravelersView(trip: trip),
    );
  }
}

class _TravelersView extends StatelessWidget {
  final GuideTrip trip;

  const _TravelersView({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  CircleBackButton(
                    icon: Icons.chevron_left,
                    iconColor: AppColors.titleDark,
                    backgroundColor: const Color(0xFFF6F1E7),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Travelers',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.priceTeal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tabSelectedBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    BlocBuilder<TravelersCubit, TravelersState>(
                      builder: (context, state) {
                        final count = state is TravelersSuccess
                            ? state.travelers.length
                            : 0;
                        return Text(
                          '${trip.scheduleLabel} · $count traveler${count == 1 ? '' : 's'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'TRAVELER LIST',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.subtitle,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // The builder sits outside the scroll view, so the loading
            // spinner is centered in the screen.
            Expanded(
              child: BlocBuilder<TravelersCubit, TravelersState>(
                builder: (context, state) {
                  return switch (state) {
                    TravelersSuccess(:final travelers) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          if (travelers.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No travelers yet',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.subtitle,
                                  ),
                                ),
                              ),
                            )
                          else
                            for (int i = 0; i < travelers.length; i++) ...[
                              TravelerCard(traveler: travelers[i]),
                              if (i != travelers.length - 1)
                                const SizedBox(height: 10),
                            ],
                          const SizedBox(height: 12),
                          _checkedInCard(travelers.length),
                        ],
                      ),
                    ),
                    TravelersInitial() ||
                    TravelersLoading() => const AppLoadingView(),
                    TravelersError(:final error) => AppErrorView(
                      message: error,
                      onRetry: () =>
                          context.read<TravelersCubit>().loadTrip(trip.id),
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The "checked in" progress card under the traveler list.
  Widget _checkedInCard(int total) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Checked in',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.subtitle,
                ),
              ),
              const Spacer(),
              Text(
                '0 / $total',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0,
              minHeight: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.tabSelectedBg),
            ),
          ),
        ],
      ),
    );
  }
}
