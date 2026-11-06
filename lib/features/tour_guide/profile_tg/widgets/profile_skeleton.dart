import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// Skeleton for the guide profile loading state.
///
/// Mirrors the teal header, the overlapping stats card and the menu section so
/// the real profile lands in the same place. The guide bottom nav is owned by
/// the screen and stays visible.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF0E5261),
            padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 20),
            child: AppShimmer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ShimmerCircle(size: 88),
                  SizedBox(height: 10),
                  ShimmerLine(width: 150, height: 20, radius: 8),
                  SizedBox(height: 8),
                  ShimmerLine(width: 100, height: 12),
                  SizedBox(height: 10),
                  ShimmerLine(width: 130, height: 11),
                  SizedBox(height: 6),
                  ShimmerLine(width: 110, height: 11),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            transform: Matrix4.translationValues(0, -20, 0),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xffFAF5EC),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AppShimmer(
              child: Row(
                children: [
                  const _StatSkeleton(),
                  _divider(),
                  const _StatSkeleton(),
                  _divider(),
                  const _StatSkeleton(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: const [
                      ShimmerBox(
                        width: 70,
                        height: 27,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      ShimmerBox(
                        width: 60,
                        height: 27,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ShimmerLine(width: 60, height: 15),
                  const SizedBox(height: 8),
                  const ShimmerLine(height: 12),
                  const SizedBox(height: 6),
                  const ShimmerLine(height: 12),
                  const SizedBox(height: 6),
                  const ShimmerLine(width: 220, height: 12),
                  const SizedBox(height: 8),
                  for (int i = 0; i < 4; i++) const _MenuRowSkeleton(),
                  const SizedBox(height: 8),
                  const ShimmerBox(
                    height: 50,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 32, color: AppColors.cardBorder);
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        children: [
          ShimmerLine(width: 34, height: 15),
          SizedBox(height: 5),
          ShimmerLine(width: 56, height: 11),
        ],
      ),
    );
  }
}

class _MenuRowSkeleton extends StatelessWidget {
  const _MenuRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ShimmerCircle(size: 38),
          SizedBox(width: 12),
          ShimmerLine(width: 120, height: 14),
        ],
      ),
    );
  }
}
