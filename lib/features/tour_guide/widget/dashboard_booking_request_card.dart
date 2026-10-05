import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_fallback.dart';
import '../model/guide_dashboard_booking_request.dart';

/// Cream tint from Figma (public badge). Local const only — the global
/// theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);
const Color _tanText = Color(0xFF9A7B2D);

/// One row of the "New bookings" list: guest avatar, names, detail lines
/// and a PRIVATE/PUBLIC pill.
class BookingRequestCard extends StatelessWidget {
  final BookingRequest booking;
  final VoidCallback? onTap;

  const BookingRequestCard({super.key, required this.booking, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetworkImageFallback(
                imageUrl: booking.avatarUrl,
                width: 48,
                height: 48,
                fallbackIcon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.guestName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.tourTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.subtitle,
                    ),
                  ),
                  Text(
                    booking.detailLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.subtitle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:
                    booking.isPrivate ? AppColors.primaryLight : _cream,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                booking.isPrivate ? 'PRIVATE' : 'PUBLIC',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: booking.isPrivate
                      ? AppColors.primary
                      : _tanText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
