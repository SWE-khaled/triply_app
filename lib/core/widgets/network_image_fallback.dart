import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Network image with grey + icon fallback. Replaces every
/// `Image.network/errorBuilder` block (map preview, place-detail hero,
/// post images, story rings, avatars).
class NetworkImageFallback extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const NetworkImageFallback({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image,
    this.fallbackColor = AppColors.chipGrey,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: fallbackColor,
        alignment: Alignment.center,
        child: Icon(fallbackIcon, color: Colors.grey),
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: fallbackColor,
        alignment: Alignment.center,
        child: Icon(fallbackIcon, color: Colors.grey),
      ),
    );
  }
}
