import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// Skeleton for the guide earnings page. The whole body is cubit-driven
/// (header, balance card and activity list), so all of it shimmers.
class EarningsSkeleton extends StatelessWidget {
  const EarningsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.tabSelectedBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLine(width: 110, height: 12),
                  SizedBox(height: 8),
                  ShimmerLine(width: 190, height: 28, radius: 8),
                  SizedBox(height: 14),
                  ShimmerBox(
                    width: 150,
                    height: 40,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppShimmer(
            child: Row(
              children: const [
                ShimmerLine(width: 130, height: 16),
                Spacer(),
                ShimmerLine(width: 60, height: 12),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < 4; i++) ...[
            AppShimmer(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: const [
                    Expanded(child: ShimmerLine(height: 14)),
                    SizedBox(width: 16),
                    ShimmerLine(width: 80, height: 13),
                  ],
                ),
              ),
            ),
            if (i != 3) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
