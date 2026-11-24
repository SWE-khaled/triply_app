import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

class SeatsStepper extends StatelessWidget {
  final int seats;
  final int spotsAvailable;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const SeatsStepper({
    super.key,
    required this.seats,
    required this.spotsAvailable,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final personWord = seats == 1 ? 'person' : 'persons';
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Number of Seats',
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
          const SizedBox(height: 14),
          Row(
            children: [
              _stepBtn(
                context,
                Icons.remove,
                onDecrement,
                darkIconColor: AppThemeDark.iconSecondary,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$seats',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.title,
                          dark: AppThemeDark.homeGuideName,
                        ),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      personWord,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.subtitle,
                          dark: AppThemeDark.homeGuideSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _stepBtn(
                context,
                Icons.add,
                onIncrement,
                iconColor: AppColors.tabSelectedBg,
                darkIconColor: AppThemeDark.homeSeeAll,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '$spotsAvailable spots available',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.subtitle,
                  dark: AppThemeDark.homeGuideSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(
    BuildContext context,
    IconData icon,
    VoidCallback onTap, {
    Color iconColor = AppColors.dateText,
    required Color darkIconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppThemeColors.resolve(
            context,
            light: const Color(0xFFF1F4F5),
            dark: AppThemeDark.surfaceElevated,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppThemeColors.resolve(
            context,
            light: iconColor,
            dark: darkIconColor,
          ),
        ),
      ),
    );
  }
}
