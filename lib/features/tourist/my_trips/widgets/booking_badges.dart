import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Small public/private indicator for booked trips.
/// Public trip -> public icon + "Public" label; private trip -> private
/// icon + "Private" label (both also exposed as tooltips).
class BookingKindIcon extends StatelessWidget {
  final bool isPrivate;

  const BookingKindIcon({super.key, required this.isPrivate});

  @override
  Widget build(BuildContext context) {
    final label = isPrivate ? 'Private' : 'Public';
    return Tooltip(
      message: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPrivate ? Icons.lock_outline : Icons.public_outlined,
            size: 14,
            color: AppColors.primaryTeal,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTeal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pending-approval note shown under newly booked trips.
class PendingApprovalLabel extends StatelessWidget {
  const PendingApprovalLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_outlined, size: 14, color: AppColors.accentOrange),
        SizedBox(width: 4),
        Flexible(
          child: Text(
            'Waiting for admin approval',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentOrange,
            ),
          ),
        ),
      ],
    );
  }
}
