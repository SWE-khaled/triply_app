import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helper/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
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
                    color: AppThemeColors.resolve(
                      context,
                      light: const Color(0xFFE6ECEF),
                      dark: AppThemeDark.surfaceElevated,
                    ),
                    child: Icon(
                      Icons.image,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.subtitle,
                        dark: AppThemeDark.textSecondary,
                      ),
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
                    color: AppThemeColors.resolve(
                      context,
                      light: const Color(0xFFFDE8E0),
                      dark: AppThemeDark.surfaceElevated,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'REJECTED',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.accentOrange,
                        dark: AppThemeDark.homeGuidePrice,
                      ),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.title,
                      dark: AppThemeDark.homeSectionTitle,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trip.location} · ${trip.duration ?? trip.scheduleLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.subtitle,
                      dark: AppThemeDark.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'EGP ${formatEgp(trip.priceEgp)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.titleDark,
                      dark: AppThemeDark.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin rejection reason',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.accentOrange,
                      dark: AppThemeDark.homeGuidePrice,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (trip.rejectionReason ?? '').trim().isEmpty
                      ? 'No reason was given by the admin.'
                      : trip.rejectionReason!.trim(),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.5,
                    color: AppThemeColors.resolve(
                      context,
                      light: AppColors.dateText,
                      dark: AppThemeDark.textSecondary,
                    ),
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
                            color: AppThemeColors.resolve(
                              context,
                              light: const Color(0xFFF6F1E7),
                              dark: AppThemeDark.surfaceElevated,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Preview',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppThemeColors.resolve(
                                context,
                                light: AppColors.titleDark,
                                dark: AppThemeDark.textPrimary,
                              ),
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
