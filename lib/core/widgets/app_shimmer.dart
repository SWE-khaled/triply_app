import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme_colors.dart';
import '../theme/app_theme_dark.dart';

/// Shared shimmer wrapper for skeleton loading states.
///
/// Wrap only the placeholder blocks — never the card chrome — so the whole
/// card does not turn into a moving gradient.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return child;
    return Shimmer.fromColors(
      baseColor: isDark
          ? AppThemeDark.backgroundTertiary
          : const Color(0xFFEDF2F2),
      highlightColor: isDark
          ? AppThemeDark.surfaceElevated
          : const Color(0xFFF9FBFB),
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
  final Color? color;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppThemeDark.surfaceElevated
            : const Color(0xFFE7EDED));
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: resolvedColor,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Circular placeholder (avatars, icon bubbles).
class ShimmerCircle extends StatelessWidget {
  final double size;
  final Color? color;

  const ShimmerCircle({super.key, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppThemeDark.surfaceElevated
            : const Color(0xFFE7EDED));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: resolvedColor, shape: BoxShape.circle),
    );
  }
}

/// One line of text. Defaults to a single-line height; pass [width] as null
/// to fill the available width.
class ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Color? color;

  const ShimmerLine({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 6,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppThemeDark.surfaceElevated
            : const Color(0xFFE7EDED));
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: resolvedColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Themed surface used by skeleton cards, so only their content shimmers.
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
        color: AppThemeColors.resolve(
          context,
          light: Colors.white,
          dark: AppThemeDark.surfaceDefault,
        ),
        border: Border.all(
          color: AppThemeColors.resolve(
            context,
            light: AppColors.cardBorder,
            dark: AppThemeDark.borderSubtle,
          ),
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
