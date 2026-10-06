import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Renders gallery-picked local files with [Image.file] and remote
/// URLs with [Image.network], keeping the existing fallback look.
class TripImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double fallbackIconSize;

  const TripImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: const Color(0xFFE6ECEF),
      alignment: Alignment.center,
      child: Icon(
        Icons.image,
        color: AppColors.subtitle,
        size: fallbackIconSize,
      ),
    );
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return Image.file(
      File(imageUrl),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
