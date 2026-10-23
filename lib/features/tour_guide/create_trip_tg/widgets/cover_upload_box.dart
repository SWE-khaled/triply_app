import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Dashed upload box (Figma). Shows the cover when there is one — the
/// freshly picked file, or the URL the trip already has — and the
/// dashed box when there is none.
class CoverUploadBox extends StatelessWidget {
  /// The picked local file, or the URL of the saved cover.
  final String? cover;

  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const CoverUploadBox({
    super.key,
    required this.onTap,
    this.cover,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final image = cover;
    if (image != null && image.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox(
              height: 240,
              width: double.infinity,
              child: _coverImage(image),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: _DashedRRectPainter(
          color: AppColors.cardBorder,
          radius: 24,
          dash: 5,
          gap: 4,
          strokeWidth: 1.5,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 220,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.priceTeal),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 20,
                    color: AppColors.priceTeal,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Upload cover image',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.priceTeal,
                  ),
                ),
                Text(
                  'This image appears on Tourist Home and Trip Details',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Renders the cover: a local file that was just picked, or a URL the
  /// trip already has.
  Widget _coverImage(String image) {
    final placeholder = Container(
      color: const Color(0xFFE6ECEF),
      child: const Icon(Icons.image, color: AppColors.subtitle),
    );
    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    }
    return Image.file(
      File(image),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final double strokeWidth;

  _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.dash,
    required this.gap,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap ||
      old.strokeWidth != strokeWidth;
}
