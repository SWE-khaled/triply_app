import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_shimmer.dart';

/// Skeleton for the booking-details loading state.
///
/// Keeps the real "Booking Details" header (rendered outside the cubit) and
/// mirrors the guest card + trip card geometry from the Figma reference.
class BookingDetailsSkeleton extends StatelessWidget {
  const BookingDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuestCardSkeleton(),
          const SizedBox(height: 16),
          _TripCardSkeleton(),
        ],
      ),
    );
  }
}

class _GuestCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: AppShimmer(
        child: Column(
          children: const [
            ShimmerCircle(size: 72),
            SizedBox(height: 12),
            ShimmerLine(width: 160, height: 22, radius: 8),
            SizedBox(height: 8),
            ShimmerLine(width: 110, height: 13),
            SizedBox(height: 12),
            ShimmerBox(
              width: 122,
              height: 27,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerLine(width: 200, height: 18, radius: 8),
            SizedBox(height: 12),
            ShimmerLine(width: 130, height: 13),
            SizedBox(height: 8),
            ShimmerLine(width: 190, height: 13),
            SizedBox(height: 8),
            ShimmerLine(width: 170, height: 13),
          ],
        ),
      ),
    );
  }
}
