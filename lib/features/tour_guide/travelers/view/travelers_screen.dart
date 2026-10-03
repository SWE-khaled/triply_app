import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../my_trips/model/guide_trip.dart';
import '../cubit/travelers_cubit.dart';
import '../cubit/travelers_state.dart';
import '../widgets/traveler_card.dart';

/// Traveler list for one guide trip. Self-provides its cubit.
/// View Profile has no destination screen in Figma → placeholder toast.
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              const SizedBox(height: 14),
              Container(
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
                        return Text(
                          '${trip.scheduleLabel} · ${state.travelers.length} travelers',
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
              const SizedBox(height: 14),
              Text(
                'TRAVELER LIST',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.subtitle,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<TravelersCubit, TravelersState>(
                builder: (context, state) {
                  if (state.travelers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No travelers yet',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (int i = 0; i < state.travelers.length; i++) ...[
                        TravelerCard(
                          traveler: state.travelers[i],
                          onViewProfile: () => showAppSnackBar(
                            context,
                            'Traveler profile is not available yet',
                            icon: Icons.info_outline,
                          ),
                        ),
                        if (i != state.travelers.length - 1)
                          const SizedBox(height: 10),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<TravelersCubit, TravelersState>(
                builder: (context, state) {
                  final total = state.travelers.length;
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
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.tabSelectedBg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
