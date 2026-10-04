import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Designed empty state for trip lists (Figma: map icon + title + subtext).
/// Title is dynamic per tab, e.g. "No Upcoming trips".
class EmptyTrips extends StatelessWidget {
  final String tabName;
  final String? title;

  const EmptyTrips({super.key, required this.tabName, this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F4F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_outlined,
                size: 30,
                color: AppColors.subtitle,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'No $tabName trips',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Explore Egypt and book your first adventure',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.subtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
