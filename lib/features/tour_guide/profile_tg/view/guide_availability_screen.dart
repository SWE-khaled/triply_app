import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/data/guide_trips_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circle_back_button.dart';

/// Guide availability derived from the guide's own trips (same
/// [GuideTripsStore] source as My Trips): each trip with its schedule.
class GuideAvailabilityScreen extends StatelessWidget {
  const GuideAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = GuideTripsStore.allTrips();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleBackButton(),
                  const SizedBox(width: 12),
                  Text(
                    'Availability',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.title,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'When you are available, based on your trips.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.subtitle,
                ),
              ),
              const SizedBox(height: 16),
              if (trips.isEmpty)
                Text(
                  'No trips yet — availability will appear here once you add trips.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.subtitle,
                  ),
                )
              else
                for (final trip in trips)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: AppColors.priceTeal,
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
                                  color: AppColors.title,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                trip.scheduleLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.subtitle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
