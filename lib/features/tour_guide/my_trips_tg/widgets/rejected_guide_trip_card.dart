import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helper/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../model/guide_trip.dart';

/// Rejected-state card (Figma): banner image with REJECTED pill,
/// admin reason box, Preview + Edit & Resubmit actions.
/// Destinations don't exist yet → callbacks stay placeholder toasts.
class RejectedGuideTripCard extends StatelessWidget {
  final GuideTrip trip;
  final VoidCallback? onPreview;
  final VoidCallback? onEditResubmit;

  const RejectedGuideTripCard({
    super.key,
    required this.trip,
    this.onPreview,
    this.onEditResubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  trip.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFFE6ECEF),
                    child: const Icon(
                      Icons.image,
                      color: AppColors.subtitle,
                      size: 36,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'REJECTED',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentOrange,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trip.location} · ${trip.duration ?? trip.scheduleLabel}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.subtitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'EGP ${formatEgp(trip.priceEgp)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.titleDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin rejection reason',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trip.rejectionReason ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.dateText,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onPreview,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F1E7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Preview',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.titleDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: onEditResubmit,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.tabSelectedBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Edit & Resubmit',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
