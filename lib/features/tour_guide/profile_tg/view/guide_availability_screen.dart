import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/data/repositories/guide_trips_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../my_trips_tg/model/guide_trip.dart';

/// Guide availability derived from the guide's own trips (same
/// [GuideTripsRepository] source as My Trips): each trip with its
/// schedule. The list updates live.
class GuideAvailabilityScreen extends StatefulWidget {
  const GuideAvailabilityScreen({super.key});

  @override
  State<GuideAvailabilityScreen> createState() =>
      _GuideAvailabilityScreenState();
}

class _GuideAvailabilityScreenState extends State<GuideAvailabilityScreen> {
  late final Stream<List<GuideTrip>> _trips;

  @override
  void initState() {
    super.initState();
    _trips = GuideTripsRepository().watchTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.resolve(
        context,
        light: AppColors.background,
        dark: AppThemeDark.backgroundPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleBackButton(
                    backgroundColor: AppThemeColors.resolve(
                      context,
                      light: Colors.white,
                      dark: AppThemeDark.surfaceElevated,
                    ),
                    iconColor: AppThemeColors.resolve(
                      context,
                      light: Colors.black,
                      dark: AppThemeDark.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Availability',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.title,
                        dark: AppThemeDark.homeSectionTitle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'When you are available, based on your trips.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.subtitle,
                    dark: AppThemeDark.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<GuideTrip>>(
                stream: _trips,
                builder: (context, snapshot) {
                  final trips = snapshot.data ?? const <GuideTrip>[];
                  if (trips.isEmpty) {
                    return Text(
                      'No trips yet — availability will appear here once you add trips.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.subtitle,
                          dark: AppThemeDark.textSecondary,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final trip in trips)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppThemeColors.resolve(
                              context,
                              light: Colors.white,
                              dark: AppThemeDark.surfaceDefault,
                            ),
                            border: Border.all(
                              color: AppThemeColors.resolve(
                                context,
                                light: AppColors.cardBorder,
                                dark: AppThemeDark.borderSubtle,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: AppThemeColors.resolve(
                                  context,
                                  light: AppColors.priceTeal,
                                  dark: AppThemeDark.homeSeeAll,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trip.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppThemeColors.resolve(
                                          context,
                                          light: AppColors.title,
                                          dark: AppThemeDark.homeSectionTitle,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      trip.scheduleLabel,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppThemeColors.resolve(
                                          context,
                                          light: AppColors.subtitle,
                                          dark: AppThemeDark.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
