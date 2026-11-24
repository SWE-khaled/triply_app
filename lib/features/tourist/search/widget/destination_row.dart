import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_fallback.dart';

class DestinationRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onTap;

  const DestinationRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppThemeColors.resolve(
            context,
            light: const Color(0xFFF7F7F7),
            dark: AppThemeDark.homeGuideSurface,
          ),
          border: isDark
              ? Border.all(color: AppThemeDark.homeGuideBorder)
              : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: NetworkImageFallback(
                imageUrl: imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                fallbackColor: AppThemeColors.resolve(
                  context,
                  light: AppColors.chipGrey,
                  dark: AppThemeDark.surfaceElevated,
                ),
                fallbackIconColor: AppThemeColors.resolve(
                  context,
                  light: Colors.grey,
                  dark: AppThemeDark.homeGuideSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.primaryTeal,
                        dark: AppThemeDark.homeGuideName,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.textGrey,
                        dark: AppThemeDark.homeGuideSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.textGrey,
                dark: AppThemeDark.homeGuideSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
