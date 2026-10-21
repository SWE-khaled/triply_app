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
                    style: const TextStyle(
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
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.subtitle,
                    ),
                  ),
                  if (item.timeLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.timeLabel,
                      style: const TextStyle(
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

  /// The colour and icon of a notification, per its type.
  (Color, IconData, Color) _styleForType(String type) {
    switch (type) {
      case 'booking':
        return (const Color(0xFFE3F3E7), Icons.check, const Color(0xFF2E9E5B));
      case 'trip_decided':
        return (
          const Color(0xFFE6F3F3),
          Icons.verified_outlined,
          AppColors.priceTeal,
        );
      case 'approval':
        return (
          const Color(0xFFE6F3F3),
          Icons.verified_outlined,
          AppColors.priceTeal,
        );
      case 'payment':
        return (
          const Color(0xFFFFEBDC),
          Icons.credit_card_outlined,
          AppColors.accentOrange,
        );
      case 'like':
        return (
          const Color(0xFFFFE8E8),
          Icons.favorite_border,
          const Color(0xFFE86A6A),
        );
      case 'message':
        return (
          const Color(0xFFE6F3F3),
          Icons.chat_bubble_outline,
          AppColors.priceTeal,
        );
      default:
        return (
          const Color(0xFFF2F2F2),
          Icons.notifications_none,
          AppColors.subtitle,
        );
    }
  }
}
