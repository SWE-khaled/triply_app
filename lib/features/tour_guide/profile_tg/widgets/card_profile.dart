import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_theme_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/core/widgets/guide_shared_widgets.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';

class CardProfile extends StatelessWidget {
  final Guide guide;
  final VoidCallback? onTap;
  final VoidCallback? onChatPressed;

  const CardProfile({
    super.key,
    required this.guide,
    this.onTap,
    this.onChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppThemeColors.resolve(
            context,
            light: Colors.white,
            dark: AppThemeDark.surfaceDefault,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppThemeColors.resolve(
              context,
              light: const Color(0xFFAAB8BC).withValues(alpha: .6),
              dark: AppThemeDark.borderSubtle,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
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
                    light: const Color(0xFF0E5261).withValues(alpha: .2),
                    dark: AppThemeDark.surfaceElevated,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    guide.name.isNotEmpty ? guide.name[0] : '?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.resolve(
                        context,
                        light: const Color(0xFF0E5261),
                        dark: AppThemeDark.homeSeeAll,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppThemeColors.resolve(
                              context,
                              light: const Color(0xFF0E5261),
                              dark: AppThemeDark.homeSectionTitle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      if (guide.isVerified)
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: AppThemeColors.resolve(
                            context,
                            light: const Color(0xFF4DA7A0),
                            dark: AppThemeDark.homeGuideVerified,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    guide.specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppThemeColors.resolve(
                        context,
                        light: const Color(0xFF8A9EA3),
                        dark: AppThemeDark.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: guide.languages
                        .map(
                          (l) => LanguageChip(
                            label: l,
                            backgroundColor: AppThemeColors.resolve(
                              context,
                              light: const Color(
                                0xFF4DA7A0,
                              ).withValues(alpha: .1),
                              dark: AppThemeDark.surfaceElevated,
                            ),
                            textColor: AppThemeColors.resolve(
                              context,
                              light: const Color(0xFF4DA7A0),
                              dark: AppThemeDark.homeSeeAll,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingRow(
                        rating: guide.rating,
                        reviewCount: guide.reviewCount,
                        ratingColor: AppThemeColors.resolve(
                          context,
                          light: const Color(0xFF0E5261),
                          dark: AppThemeDark.homeSectionTitle,
                        ),
                        reviewCountColor: AppThemeColors.resolve(
                          context,
                          light: const Color(0xFFAAB8BC),
                          dark: AppThemeDark.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'From ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppThemeColors.resolve(
                                    context,
                                    light: const Color(0xFFE07A4F),
                                    dark: AppThemeDark.homeGuidePrice,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${guide.currency}${guide.pricePerHour.toStringAsFixed(0)}/hr',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppThemeColors.resolve(
                                    context,
                                    light: const Color(0xFFE07A4F),
                                    dark: AppThemeDark.homeGuidePrice,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: '/hr',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppThemeColors.resolve(
                                    context,
                                    light: const Color(0xFFAAB8BC),
                                    dark: AppThemeDark.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
