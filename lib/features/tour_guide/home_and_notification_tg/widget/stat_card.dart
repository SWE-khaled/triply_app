import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/theme/app_theme_dark.dart';

/// Cream tint from Figma (banner, earnings card, public pill). Local const
/// only — the global theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);

/// Single dashboard metric card (icon, big value, label). The earnings
/// card passes [highlighted] for its cream background.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool highlighted;
  final bool valueTeal;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.highlighted = false,
    this.valueTeal = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? AppThemeColors.resolve(
                context,
                light: _cream,
                dark: AppThemeDark.homeGuideSurface,
              )
            : AppThemeColors.resolve(
                context,
                light: Colors.white,
                dark: AppThemeDark.surfaceDefault,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemeColors.resolve(
            context,
            light: AppColors.cardBorder,
            dark: AppThemeDark.borderSubtle,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppThemeColors.resolve(
                context,
                light: AppColors.searchBg,
                dark: AppThemeDark.surfaceElevated,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.title,
                dark: AppThemeDark.homeSectionTitle,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Long values (e.g. "EGP 12,345.67") scale down on narrow cards
          // instead of overflowing; the 28px typography is kept when it fits.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: valueTeal
                    ? AppThemeColors.resolve(
                        context,
                        light: AppColors.priceTeal,
                        dark: AppThemeDark.homeSeeAll,
                      )
                    : AppThemeColors.resolve(
                        context,
                        light: AppColors.title,
                        dark: AppThemeDark.homeSectionTitle,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.subtitle,
                dark: AppThemeDark.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}
