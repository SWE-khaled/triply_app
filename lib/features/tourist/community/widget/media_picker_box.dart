import 'package:flutter/material.dart';

import 'package:triply/core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

/// Dashed media picker box extracted from `_MediaPickerBox`.
class MediaPickerBox extends StatelessWidget {
  final VoidCallback onTap;

  const MediaPickerBox({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppThemeColors.resolve(
            context,
            light: AppColors.primaryTeal,
            dark: AppThemeDark.actionSecondary,
          ),
          radius: 16,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: AppThemeColors.resolve(
              context,
              light: AppColors.storyBg,
              dark: AppThemeDark.backgroundSecondary,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppThemeColors.resolve(
                    context,
                    light: Colors.white,
                    dark: AppThemeDark.surfaceElevated,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.primaryTeal,
                    dark: AppThemeDark.actionSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Add Photo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.primaryTeal,
                    dark: AppThemeDark.actionSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Supports JPG, PNG up to 10MB',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  letterSpacing: 0,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.textGrey,
                    dark: AppThemeDark.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, this.radius = 16});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 4.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics().first;
    var distance = 0.0;
    while (distance < metrics.length) {
      final segment = metrics.extractPath(distance, distance + dash);
      canvas.drawPath(segment, paint);
      distance += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
