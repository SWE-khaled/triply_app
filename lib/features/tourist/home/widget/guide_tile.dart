import 'package:flutter/material.dart';
import '../model/guide.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

class GuideTile extends StatelessWidget {
  final Guide guide;
  final VoidCallback? onTap;

  const GuideTile({super.key, required this.guide, this.onTap});

  @override
  Widget build(BuildContext context) {
    final secondaryColor = AppThemeColors.resolve(
      context,
      light: AppColors.textGrey,
      dark: AppThemeDark.homeGuideSecondary,
    );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppThemeColors.resolve(
            context,
            light: Colors.white,
            dark: AppThemeDark.homeGuideSurface,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppThemeColors.resolve(
              context,
              light: const Color(0xFFEEEEEE),
              dark: AppThemeDark.homeGuideBorder,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                guide.avatarUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 56,
                  height: 56,
                  color: AppThemeColors.resolve(
                    context,
                    light: const Color(0xFFF0F3F3),
                    dark: AppThemeDark.surfaceElevated,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    guide.name.isNotEmpty ? guide.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.primaryTeal,
                        dark: AppThemeDark.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          guide.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppThemeColors.resolve(
                              context,
                              light: AppColors.guidesName,
                              dark: AppThemeDark.homeGuideName,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.primaryTeal,
                          dark: AppThemeDark.homeGuideVerified,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    guide.specialty,
                    style: AppTextStyles.bodyGrey.copyWith(
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppThemeColors.resolve(
                          context,
                          light: Colors.amber,
                          dark: AppThemeDark.homeGuideRating,
                        ),
                      ),
                      Text(
                        ' ${guide.rating} (${guide.reviewCount})',
                        style: AppTextStyles.bodyGrey.copyWith(
                          color: secondaryColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'From EGP ${guide.pricePerHour.toInt()}/hr',
                        style: AppTextStyles.price.copyWith(
                          color: AppThemeColors.resolve(
                            context,
                            light: AppColors.accentOrange,
                            dark: AppThemeDark.homeGuidePrice,
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
      ),
    );
  }
}
