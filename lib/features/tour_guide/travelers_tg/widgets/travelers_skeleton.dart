import 'package:flutter/material.dart';

import '../../../../core/widgets/app_shimmer.dart';

/// Skeleton for the traveler list of one trip. The screen header and trip
/// summary card are rendered outside the cubit, so only the list shimmers.
class TravelersSkeleton extends StatelessWidget {
  const TravelersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          for (int i = 0; i < 3; i++) ...[
            const _TravelerCardSkeleton(),
            if (i != 2) const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          const _CheckedInCardSkeleton(),
        ],
      ),
    );
  }
}

class _TravelerCardSkeleton extends StatelessWidget {
  const _TravelerCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      padding: const EdgeInsets.all(12),
      child: AppShimmer(
        child: Row(
          children: [
            const ShimmerCircle(size: 44),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLine(width: 110, height: 14),
                  SizedBox(height: 6),
                  ShimmerLine(width: 150, height: 11),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const ShimmerBox(
              width: 50,
              height: 22,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckedInCardSkeleton extends StatelessWidget {
  const _CheckedInCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                ShimmerLine(width: 90, height: 13),
                Spacer(),
                ShimmerLine(width: 40, height: 13),
              ],
            ),
            SizedBox(height: 10),
            ShimmerBox(
              height: 6,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            SizedBox(height: 8),
            ShimmerLine(width: 120, height: 11),
          ],
        ),
      ),
    );
  }
}
