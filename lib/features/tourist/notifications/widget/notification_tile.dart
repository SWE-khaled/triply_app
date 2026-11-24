import 'package:flutter/material.dart';
import '../model/notification_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (bg, icon, iconColor) = _styleForType(item.type, isDark: isDark);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppThemeColors.resolve(
                        context,
                        light:
                            Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.black87,
                        dark: AppThemeDark.homeGuideName,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.textGrey,
                        dark: AppThemeDark.homeGuideSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.timeLabel,
                    style: TextStyle(
                      fontSize: 11,
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
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, left: 8),
                decoration: const BoxDecoration(
                  color: AppColors.accentOrange,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  (Color, IconData, Color) _styleForType(String type, {required bool isDark}) {
    switch (type) {
      case 'booking':
        return isDark
            ? (
                AppThemeDark.homeGuideSurface,
                Icons.check,
                AppThemeDark.statusSuccess,
              )
            : (const Color(0xFFE3F3E7), Icons.check, const Color(0xFF2E9E5B));
      case 'reminder':
        return isDark
            ? (
                AppThemeDark.surfaceElevated,
                Icons.access_time,
                AppThemeDark.homeGuidePrice,
              )
            : (
                const Color(0xFFFFEBDC),
                Icons.access_time,
                AppColors.accentOrange,
              );
      case 'message':
        return isDark
            ? (
                AppThemeDark.surfaceElevated,
                Icons.chat_bubble_outline,
                AppThemeDark.homeSeeAll,
              )
            : (
                const Color(0xFFE6F3F3),
                Icons.chat_bubble_outline,
                AppColors.primaryTeal,
              );
      case 'like':
        return isDark
            ? (
                AppThemeDark.surfaceElevated,
                Icons.favorite_border,
                AppThemeDark.statusError,
              )
            : (
                const Color(0xFFFFE8E8),
                Icons.favorite_border,
                const Color(0xFFE86A6A),
              );
      default:
        return isDark
            ? (
                AppThemeDark.surfaceElevated,
                Icons.notifications_none,
                AppThemeDark.textSecondary,
              )
            : (
                const Color(0xFFF2F2F2),
                Icons.notifications_none,
                AppColors.textGrey,
              );
    }
  }
}
