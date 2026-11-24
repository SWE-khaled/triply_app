import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/theme/app_theme_dark.dart';
import '../model/guide_notification.dart';

/// One notification row: coloured circle icon, bold title, grey body,
/// the time it happened, and a dot while it is still unread.
class GuideNotificationTile extends StatelessWidget {
  final GuideNotification item;
  final VoidCallback? onTap;

  const GuideNotificationTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (bg, icon, iconColor) = _styleForType(context, item.type);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.title,
                        dark: AppThemeDark.homeSectionTitle,
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
                      height: 1.4,
                      color: AppThemeColors.resolve(
                        context,
                        light: AppColors.subtitle,
                        dark: AppThemeDark.textSecondary,
                      ),
                    ),
                  ),
                  if (item.timeLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.timeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.subtitle,
                          dark: AppThemeDark.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, left: 8),
                decoration: BoxDecoration(
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.accentOrange,
                    dark: AppThemeDark.homeGuidePrice,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The colour and icon of a notification, per its type.
  (Color, IconData, Color) _styleForType(BuildContext context, String type) {
    Color background(Color light) => AppThemeColors.resolve(
      context,
      light: light,
      dark: AppThemeDark.surfaceElevated,
    );
    Color foreground(Color light, Color dark) =>
        AppThemeColors.resolve(context, light: light, dark: dark);

    switch (type) {
      case 'booking':
        return (
          background(const Color(0xFFE3F3E7)),
          Icons.check,
          foreground(const Color(0xFF2E9E5B), AppThemeDark.statusSuccess),
        );
      case 'trip_decided':
        return (
          background(const Color(0xFFE6F3F3)),
          Icons.verified_outlined,
          foreground(AppColors.priceTeal, AppThemeDark.homeSeeAll),
        );
      case 'approval':
        return (
          background(const Color(0xFFE6F3F3)),
          Icons.verified_outlined,
          foreground(AppColors.priceTeal, AppThemeDark.homeSeeAll),
        );
      case 'payment':
        return (
          background(const Color(0xFFFFEBDC)),
          Icons.credit_card_outlined,
          foreground(AppColors.accentOrange, AppThemeDark.homeGuidePrice),
        );
      case 'like':
        return (
          background(const Color(0xFFFFE8E8)),
          Icons.favorite_border,
          foreground(const Color(0xFFE86A6A), AppThemeDark.statusError),
        );
      case 'message':
        return (
          background(const Color(0xFFE6F3F3)),
          Icons.chat_bubble_outline,
          foreground(AppColors.priceTeal, AppThemeDark.homeSeeAll),
        );
      default:
        return (
          background(const Color(0xFFF2F2F2)),
          Icons.notifications_none,
          foreground(AppColors.subtitle, AppThemeDark.textSecondary),
        );
    }
  }
}
