import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_shimmer.dart';

/// Skeleton for the guide notification list. The screen header stays real;
/// only the rows shimmer.
class GuideNotificationsSkeleton extends StatelessWidget {
  const GuideNotificationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.cardBorder),
      itemBuilder: (_, _) => const _NotificationRowSkeleton(),
    );
  }
}

class _NotificationRowSkeleton extends StatelessWidget {
  const _NotificationRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerCircle(size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLine(width: 150, height: 14),
                  SizedBox(height: 8),
                  ShimmerLine(width: 230, height: 12),
                  SizedBox(height: 6),
                  ShimmerLine(width: 90, height: 11),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const ShimmerLine(width: 36, height: 10),
          ],
        ),
      ),
    );
  }
}
