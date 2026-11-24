import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_asset.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../trip_details/model/trip_details.dart';

class BookingSummaryCard extends StatelessWidget {
  final TripDetails details;
  final String dateLabel;

  const BookingSummaryCard({
    super.key,
    required this.details,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.resolve(
          context,
          light: Colors.transparent,
          dark: AppThemeDark.homeGuideSurface,
        ),
        border: Border.all(
          color: AppThemeColors.resolve(
            context,
            light: AppColors.cardBorder,
            dark: AppThemeDark.homeGuideBorder,
          ),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 190,
                width: double.infinity,
                child: Image.network(
                  details.imageUrl,
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
                        dark: AppThemeDark.homeGuideSecondary,
                      ),
                      size: 36,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Text(
                  details.title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _row(
                  context,
                  icon: Icons.location_on,
                  iconColor: AppColors.pin,
                  darkIconColor: AppThemeDark.homeGuidePrice,
                  label: 'Date & Time',
                  value: dateLabel,
                ),
                const SizedBox(height: 14),
                _peopleRow(context),
                const SizedBox(height: 14),
                _row(
                  context,
                  icon: Icons.schedule,
                  iconColor: AppColors.starGold,
                  darkIconColor: AppThemeDark.homeGuideRating,
                  label: 'Duration',
                  value: details.duration,
                ),
                const SizedBox(height: 14),
                _row(
                  context,
                  icon: Icons.location_on,
                  iconColor: AppColors.dateText,
                  darkIconColor: AppThemeDark.homeGuideSecondary,
                  label: 'Meeting Point',
                  value: details.meetingPoint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Widget child) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppThemeColors.resolve(
          context,
          light: const Color(0xFFF5F7F8),
          dark: AppThemeDark.surfaceElevated,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _row(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color darkIconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tile(
          context,
          Icon(
            icon,
            size: 16,
            color: AppThemeColors.resolve(
              context,
              light: iconColor,
              dark: darkIconColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.guideLabel,
                    dark: AppThemeDark.homeGuideSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.title,
                    dark: AppThemeDark.homeGuideName,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _peopleRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tile(
          context,
          SvgPicture.asset(
            AppAsset.iconPeople,
            width: 14,
            height: 14,
            colorFilter: ColorFilter.mode(
              AppThemeColors.resolve(
                context,
                light: AppColors.guidedTourText,
                dark: AppThemeDark.homeGuideVerified,
              ),
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guide',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.guideLabel,
                    dark: AppThemeDark.homeGuideSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                details.guideName,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.title,
                    dark: AppThemeDark.homeGuideName,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
