import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_shimmer.dart';

/// Skeleton for the guide dashboard loading state.
///
/// Mirrors the real content (header, greeting, six stat cards and the
/// "New bookings" list) so nothing shifts when the dashboard arrives.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeaderSkeleton(),
          const SizedBox(height: 16),
          AppShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLine(width: 150, height: 28, radius: 8),
                SizedBox(height: 10),
                ShimmerLine(width: 190, height: 13),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (int row = 0; row < 3; row++) ...[
            Row(
              children: [
                Expanded(child: _StatCardSkeleton()),
                const SizedBox(width: 12),
                Expanded(child: _StatCardSkeleton()),
              ],
            ),
            if (row != 2) const SizedBox(height: 12),
          ],
          const SizedBox(height: 20),
          AppShimmer(
            child: const ShimmerLine(width: 160, height: 22, radius: 8),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < 2; i++) ...[
            _BookingCardSkeleton(),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Row(
        children: [
          const ShimmerBox(
            width: 27,
            height: 44,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(width: 6),
          const ShimmerBox(
            width: 64,
            height: 28,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          const Spacer(),
          const ShimmerCircle(size: 50),
        ],
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerCircle(size: 40),
            SizedBox(height: 12),
            ShimmerLine(width: 56, height: 22, radius: 8),
            SizedBox(height: 6),
            ShimmerLine(width: 92, height: 12),
          ],
        ),
      ),
    );
  }
}

class _BookingCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      padding: const EdgeInsets.all(12),
      child: AppShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLine(width: 120, height: 15),
                  SizedBox(height: 6),
                  ShimmerLine(width: 150, height: 12),
                  SizedBox(height: 6),
                  ShimmerLine(width: 100, height: 11),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const ShimmerBox(
              width: 70,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ],
        ),
      ),
    );
  }
}
