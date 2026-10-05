import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../model/guide_notification.dart';

/// Cream tint from Figma (icon circles). Local const only — the global
/// theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);

/// One notification row: cream circle icon, bold title, grey body.
class GuideNotificationTile extends StatelessWidget {
  final GuideNotification item;
  final VoidCallback? onTap;

  const GuideNotificationTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: _cream,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(item.type),
                size: 22,
                color: AppColors.title,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.subtitle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'booking':
        return Icons.people_outline;
      case 'approval':
        return Icons.calendar_today_outlined;
      case 'payment':
        return Icons.credit_card_outlined;
      default:
        return Icons.notifications_none;
    }
  }
}
