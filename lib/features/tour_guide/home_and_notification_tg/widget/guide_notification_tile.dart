import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../model/guide_notification.dart';

/// One notification row: coloured circle icon, bold title, grey body,
/// the time it happened, and a dot while it is still unread.
class GuideNotificationTile extends StatelessWidget {
  final GuideNotification item;
  final VoidCallback? onTap;

  const GuideNotificationTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (bg, icon, iconColor) = _styleForType(item.type);
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
                    style:  TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.subtitle,
                    ),
                  ),
                  if (item.timeLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.timeLabel,
                      style:  TextStyle(
                        fontSize: 11,
                        color: AppColors.subtitle,
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
                decoration:  BoxDecoration(
                  color: AppColors.accentOrange,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The colour and icon of a notification, per its type.
  (Color, IconData, Color) _styleForType(String type) {
    switch (type) {
      case 'booking':
        return (AppColors.surfaceDefault, Icons.check, AppColors.statusSuccess);
      case 'trip_decided':
        return (
          AppColors.surfaceSelected,
          Icons.verified_outlined,
          AppColors.priceTeal,
        );
      case 'approval':
        return (
          AppColors.surfaceSelected,
          Icons.verified_outlined,
          AppColors.priceTeal,
        );
      case 'payment':
        return (
          AppColors.surfaceElevated,
          Icons.credit_card_outlined,
          AppColors.accentOrange,
        );
      case 'like':
        return (
          AppColors.surfaceDefault,
          Icons.favorite_border,
          AppColors.statusError,
        );
      case 'message':
        return (
          AppColors.surfaceSelected,
          Icons.chat_bubble_outline,
          AppColors.priceTeal,
        );
      default:
        return (
          AppColors.surfaceDefault,
          Icons.notifications_none,
          AppColors.subtitle,
        );
    }
  }
}
