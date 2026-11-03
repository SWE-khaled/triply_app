import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared status badge chip used across all admin tables.
/// [status] can be: 'active', 'approved', 'confirmed', 'pending',
///                  'suspended', 'cancelled', 'pending_review'
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg;
    Color textColor;
    String label;

    switch (s) {
      case 'active':
        bg = AppColors.adminStatusActiveBg;
        textColor = AppColors.adminStatusActiveText;
        label = 'Active';
        break;
      case 'approved':
        bg = AppColors.adminStatusActiveBg;
        textColor = AppColors.adminStatusActiveText;
        label = 'Approved';
        break;
      case 'confirmed':
        bg = AppColors.adminStatusActiveBg;
        textColor = AppColors.adminStatusActiveText;
        label = 'Confirmed';
        break;
      case 'pending':
        bg = AppColors.adminStatusPendingBg;
        textColor = AppColors.adminStatusPendingText;
        label = 'Pending';
        break;
      case 'pending_review':
        bg = AppColors.adminStatusPendingBg;
        textColor = AppColors.adminStatusPendingText;
        label = 'Pending Review';
        break;
      case 'suspended':
        bg = AppColors.adminStatusSuspendedBg;
        textColor = AppColors.adminStatusSuspendedText;
        label = 'Suspended';
        break;
      case 'cancelled':
        bg = AppColors.adminStatusCancelledBg;
        textColor = AppColors.adminStatusCancelledText;
        label = 'Cancelled';
        break;
      default:
        bg = AppColors.adminStatusSuspendedBg;
        textColor = AppColors.adminStatusSuspendedText;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.adminTableCell.copyWith(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Outline action button (e.g. "View", "Details", "Review")
class OutlineActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const OutlineActionButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.adminDivider, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Text(label, style: AppTextStyles.adminButtonSecondary),
      ),
    );
  }
}

/// Danger outline action button (e.g. "Reject", "Suspend", "Cancel & Refund")
class DangerActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const DangerActionButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.adminDangerLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: AppTextStyles.adminButtonDanger),
      ),
    );
  }
}

/// Primary filled action button (e.g. "Approve")
class PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const PrimaryActionButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.adminPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: AppTextStyles.adminButtonPrimary),
      ),
    );
  }
}

