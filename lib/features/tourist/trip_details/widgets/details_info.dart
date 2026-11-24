import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../model/trip_details.dart';

class DetailsInfo extends StatelessWidget {
  final TripDetails details;

  const DetailsInfo({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppThemeColors.resolve(
              context,
              light: AppColors.guidedTourBg,
              dark: AppThemeDark.surfaceElevated,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            details.tag,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.guidedTourText,
                dark: AppThemeDark.actionSecondary,
              ),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          details.title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppThemeColors.resolve(
              context,
              light: AppColors.titleDetails,
              dark: AppThemeDark.textPrimary,
            ),
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            ...List.generate(
              5,
              (_) =>
                  const Icon(Icons.star, size: 13, color: AppColors.starGold),
            ),
            const SizedBox(width: 4),
            Text(
              details.rating.toString(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.titleDetails,
                  dark: AppThemeDark.textPrimary,
                ),
              ),
            ),
            Text(
              ' (${details.reviewsCount} reviews)',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.subtitle,
                  dark: AppThemeDark.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.location_on, size: 13, color: AppColors.pin),
            Text(
              details.location,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.subtitle,
                  dark: AppThemeDark.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _meta(context, Icons.access_time_filled, details.duration),
            _meta(context, Icons.group_outlined, details.groupType),
            _meta(context, Icons.translate, details.languages),
          ],
        ),
      ],
    );
  }

  Widget _meta(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: AppThemeColors.resolve(
            context,
            light: AppColors.iconDetails,
            dark: AppThemeDark.iconSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.titleDetails,
                dark: AppThemeDark.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
