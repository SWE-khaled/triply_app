import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// Shared shimmer wrapper for skeleton loading states.
///
/// Wrap only the placeholder blocks — never the card chrome (white surface,
/// border) — so the whole card does not turn into a moving gradient.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  /// Base/highlight match the app's light surfaces, so the sweep stays subtle
  /// on white cards.
  static const Color _base = Color(0xFFEDF2F2);
  static const Color _highlight = Color(0xFFF9FBFB);

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return child;
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      period: const Duration(milliseconds: 1400),
      direction: ShimmerDirection.ltr,
      child: child,
    );
  }
}

/// Rounded rectangular placeholder. The colour is only the static fallback —
/// [AppShimmer] replaces it with the moving gradient.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final Color color;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.color = const Color(0xFFE7EDED),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
    );
  }
}

/// Circular placeholder (avatars, icon bubbles).
class ShimmerCircle extends StatelessWidget {
  final double size;
  final Color color;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.color = const Color(0xFFE7EDED),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// One line of text. Defaults to a single-line height; pass [width] as null
/// to fill the available width.
class ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Color color;

  const ShimmerLine({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 6,
    this.color = const Color(0xFFE7EDED),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// White surface used by every skeleton card, so loading cards keep the same
/// outline as the real cards while only their content shimmers.
class ShimmerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const ShimmerCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
