import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/circle_back_button.dart';

/// Skeleton for the guide trip-details loading state.
///
/// The real header (back button + title) and the tab labels stay visible and
/// interactive; only the trip data below them shimmers.
class GuideTripDetailsSkeleton extends StatelessWidget {
  final VoidCallback? onBack;

  const GuideTripDetailsSkeleton({super.key, this.onBack});

  /// Same labels as the real screen so the tab row does not jump.
  static const List<String> _tabs = [
    'About',
    'Highlights',
    'Itinerary',
    'Notes',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  CircleBackButton(
                    icon: Icons.chevron_left,
                    iconColor: AppThemeColors.resolve(
                      context,
                      light: AppColors.titleDark,
                      dark: AppThemeDark.textPrimary,
                    ),
                    backgroundColor: AppThemeColors.resolve(
                      context,
                      light: const Color(0xFFF6F1E7),
                      dark: AppThemeDark.surfaceElevated,
                    ),
                    onTap: onBack ?? () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Trip Details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.priceTeal,
                          dark: AppThemeDark.homeSeeAll,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppShimmer(
            child: const SizedBox(
              height: 300,
              width: double.infinity,
              child: ShimmerBox(borderRadius: BorderRadius.zero),
            ),
          ),
          Container(
            width: double.infinity,
            transform: Matrix4.translationValues(0, -24, 0),
            decoration: BoxDecoration(
              color: AppThemeColors.resolve(
                context,
                light: Colors.white,
                dark: AppThemeDark.surfaceDefault,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerLine(width: 220, height: 22, radius: 8),
                        SizedBox(height: 10),
                        ShimmerLine(width: 160, height: 13),
                        SizedBox(height: 8),
                        ShimmerLine(width: 120, height: 13),
                        SizedBox(height: 14),
                        ShimmerLine(width: 200, height: 13),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(_tabs.length, (i) {
                      return Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              color: i == 0
                                  ? AppColors.tabSelectedBg
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _tabs[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: i == 0
                                    ? Colors.white
                                    : AppThemeColors.resolve(
                                        context,
                                        light: AppColors.subtitle,
                                        dark: AppThemeDark.textSecondary,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  for (int i = 0; i < 3; i++) ...[
                    AppShimmer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerLine(width: 90, height: 12),
                          SizedBox(height: 8),
                          ShimmerLine(height: 12),
                          SizedBox(height: 6),
                          ShimmerLine(width: 240, height: 12),
                        ],
                      ),
                    ),
                    if (i != 2) const SizedBox(height: 18),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppThemeColors.resolve(
                        context,
                        light: const Color(0xFFFBF6EC),
                        dark: AppThemeDark.homeGuideSurface,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppShimmer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerLine(width: 110, height: 13),
                          SizedBox(height: 10),
                          ShimmerLine(height: 12),
                          SizedBox(height: 6),
                          ShimmerLine(width: 210, height: 12),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppShimmer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerCircle(size: 16),
                        SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerLine(width: 90, height: 11),
                              SizedBox(height: 8),
                              ShimmerLine(width: 200, height: 13),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppShimmer(
                    child: const ShimmerBox(
                      height: 52,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
