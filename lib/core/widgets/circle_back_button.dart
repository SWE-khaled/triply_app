import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

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
        bg = AppColors.statusActiveBg;
        textColor = AppColors.statusActiveText;
        label = 'Active';
        break;
      case 'approved':
        bg = AppColors.statusActiveBg;
        textColor = AppColors.statusActiveText;
        label = 'Approved';
        break;
      case 'confirmed':
        bg = AppColors.statusActiveBg;
        textColor = AppColors.statusActiveText;
        label = 'Confirmed';
        break;
      case 'pending':
        bg = AppColors.statusPendingBg;
        textColor = AppColors.statusPendingText;
        label = 'Pending';
        break;
      case 'pending_review':
        bg = AppColors.statusPendingBg;
        textColor = AppColors.statusPendingText;
        label = 'Pending Review';
        break;
      case 'suspended':
        bg = AppColors.statusSuspendedBg;
        textColor = AppColors.statusSuspendedText;
        label = 'Suspended';
        break;
      case 'cancelled':
        bg = AppColors.statusCancelledBg;
        textColor = AppColors.statusCancelledText;
        label = 'Cancelled';
        break;
      default:
        bg = AppColors.statusSuspendedBg;
        textColor = AppColors.statusSuspendedText;
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
        style: AppTextStyles.tableCell.copyWith(
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
          border: Border.all(color: AppColors.divider, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Text(label, style: AppTextStyles.buttonSecondary),
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
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: AppTextStyles.buttonDanger),
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
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: AppTextStyles.buttonPrimary),
      ),
    );
  }
}
