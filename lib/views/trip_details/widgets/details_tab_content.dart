import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/trip_details.dart';

class DetailsTabContent extends StatelessWidget {
  final TripDetails details;
  final int selectedTab;

  const DetailsTabContent({
    super.key,
    required this.details,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedTab) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Highlights'),
            const SizedBox(height: 8),
            ...details.highlights.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.price,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        h,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.dateText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(details.itinerary.length, (i) {
              final stop = details.itinerary[i];
              final last = i == details.itinerary.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 8,
                      child: Column(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin:
                                const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.price,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!last)
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4),
                                  color: AppColors.guidedTourBg.withValues(alpha: 0.40),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.only(bottom: last ? 0 : 16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.time,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.subtitle,
                              ),
                            ),
                            Text(
                              stop.title,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.titleDetails,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: details.notes
              .map(
                (n) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.accentOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          n,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.dateText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      case 0:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('About this trip'),
            const SizedBox(height: 6),
            Text(
              details.about,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.6,
                color: AppColors.dateText,
              ),
            ),
          ],
        );
    }
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.title,
      ),
    );
  }
}
