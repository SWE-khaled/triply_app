import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../model/trip_details.dart';

class GuideCard extends StatelessWidget {
  final TripDetails details;
  final VoidCallback? onTap;

  /// Registered guide phone from Firestore; row hidden when null/empty.
  final String? guidePhone;

  const GuideCard({
    super.key,
    required this.details,
    required this.onTap,
    this.guidePhone,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppThemeColors.resolve(
              context,
              light: AppColors.cardBorder,
              dark: AppThemeDark.borderSubtle,
            ),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Image.network(
                    details.guideAvatarUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 44,
                      height: 44,
                      color: AppThemeColors.resolve(
                        context,
                        light: const Color(0xFFE6ECEF),
                        dark: AppThemeDark.backgroundTertiary,
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.subtitle,
                          dark: AppThemeDark.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25C05D),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppThemeColors.resolve(
                          context,
                          light: Colors.white,
                          dark: AppThemeDark.backgroundPrimary,
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          details.guideName,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.resolve(
                              context,
                              light: AppColors.titleDetails,
                              dark: AppThemeDark.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (details.topRatedGuide) ...[
                        const SizedBox(width: 15),
                        Text(
                          'TOP RATED GUIDE',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.starGold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: AppColors.starGold,
                      ),
                      const SizedBox(width: 3),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${details.guideRating}  ',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppThemeColors.resolve(
                                  context,
                                  light: AppColors.titleDetails,
                                  dark: AppThemeDark.textPrimary,
                                ),
                              ),
                            ),
                            TextSpan(
                              text: '(${details.guideReviews})',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppThemeColors.resolve(
                                  context,
                                  light: AppColors.titleDetails.withValues(
                                    alpha: 0.40,
                                  ),
                                  dark: AppThemeDark.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (guidePhone != null && guidePhone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 12,
                          color: AppColors.starGold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          guidePhone!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.resolve(
                              context,
                              light: AppColors.titleDetails,
                              dark: AppThemeDark.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.subtitle,
                dark: AppThemeDark.textSecondary,
              ),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
