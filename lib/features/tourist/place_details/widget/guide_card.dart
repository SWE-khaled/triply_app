import 'package:flutter/material.dart';

import 'package:triply/core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/widgets/network_image_fallback.dart';
import '../model/guide.dart';

class GuideCard extends StatelessWidget {
  final Guide guide;
  final VoidCallback? onTap;

  const GuideCard({super.key, required this.guide, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppThemeColors.resolve(
            context,
            light: Colors.white,
            dark: AppThemeDark.surfaceDefault,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppThemeColors.resolve(
              context,
              light: AppColors.cardBorder,
              dark: AppThemeDark.borderSubtle,
            ),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetworkImageFallback(
                imageUrl: guide.avatarUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                fallbackIcon: Icons.person,
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
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0,
                            color: AppThemeColors.resolve(
                              context,
                              light: const Color(0xFF0E5261),
                              dark: AppThemeDark.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (guide.verified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: AppThemeColors.resolve(
                            context,
                            light: const Color(0xFF4DA7A0),
                            dark: AppThemeDark.actionSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    guide.specialty,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      letterSpacing: 0,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.textGrey,
                        dark: AppThemeDark.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.starGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            guide.rating.toStringAsFixed(2),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              letterSpacing: 0,
                              color: AppThemeColors.resolve(
                                context,
                                light: const Color(0xFF0E5261),
                                dark: AppThemeDark.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            ' (${guide.reviewsCount})',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              letterSpacing: 0,
                              color: AppThemeColors.resolve(
                                context,
                                light: AppColors.textGrey,
                                dark: AppThemeDark.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'From \$${guide.pricePerHour.toStringAsFixed(0)}/hr',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0,
                                color: AppColors.accentOrange,
                              ),
                            ),
                            
                          ],
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
