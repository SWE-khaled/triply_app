import 'package:flutter/material.dart';

import '../../../../core/widgets/app_shimmer.dart';

/// Skeleton for the guide "My Trips" list. Header, create banner and tabs are
/// rendered outside the cubit, so only the trip cards shimmer.
class GuideTripsSkeleton extends StatelessWidget {
  const GuideTripsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const _TripCardSkeleton(),
    );
  }
}

class _TripCardSkeleton extends StatelessWidget {
  const _TripCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ShimmerCard(
        radius: 16,
        child: AppShimmer(
          child: Column(
            children: [
              SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      width: 110,
                      child: ShimmerBox(borderRadius: BorderRadius.zero),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerLine(width: 150, height: 15),
                                SizedBox(height: 6),
                                ShimmerLine(width: 108, height: 15),
                                SizedBox(height: 8),
                                ShimmerLine(width: 140, height: 11),
                              ],
                            ),
                            Row(
                              children: [
                                ShimmerLine(width: 70, height: 14),
                                Spacer(),
                                ShimmerBox(
                                  width: 56,
                                  height: 22,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: ShimmerBox(
                        height: 42,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ShimmerBox(
                        height: 42,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
