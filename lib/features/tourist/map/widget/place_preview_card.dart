import 'package:flutter/material.dart';

import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import '../../../../core/widgets/network_image_fallback.dart';
import '../../../../core/widgets/rating_badge.dart';
import '../model/place.dart';

/// Preview card extracted from `_PlacePreviewCard` in `map_view.dart:279`.
/// Moved as-is (no core swap here — Step 5 handles that separately).
class PlacePreviewCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final VoidCallback onViewDetails;

  const PlacePreviewCard({
    super.key,
    required this.place,
    required this.onTap,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppThemeColors.resolve(
            context,
            light: Colors.white,
            dark: AppThemeDark.surfaceDefault,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppThemeColors.resolve(
                context,
                light: Colors.black26,
                dark: Colors.black54,
              ),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetworkImageFallback(
                imageUrl: place.imageUrl,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                            color: AppThemeColors.resolve(
                              context,
                              light: AppColors.textDark,
                              dark: AppThemeDark.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      RatingBadge.fromNum(
                        place.rating,
                        backgroundColor: AppThemeColors.resolve(
                          context,
                          light: const Color(0xFFFFF3D6),
                          dark: AppThemeDark.surfaceElevated,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    place.shortDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
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
                      Text(
                        place.category == 'Historical'
                            ? 'Historical Landmark'
                            : place.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          color: AppThemeColors.resolve(
                            context,
                            light: const Color(0xFF4DA7A0),
                            dark: AppThemeDark.actionSecondary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onViewDetails,
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                            color: AppColors.accentOrange,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.accentOrange,
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
