import 'package:flutter/material.dart';

import '../constants/app_asset.dart';

/// The avatar of a person.
///
/// Shows the photo the user picked (a network URL). When there is no
/// photo — or it fails to load — the bundled default avatar is shown
/// instead of a stock face, so the app never displays somebody else's
/// picture by accident.
class ProfileAvatar extends StatelessWidget {
  /// The photo URL, or null/empty when the user has not picked one.
  final String? imageUrl;

  final double? size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.person,
  });

  /// The bundled default avatar.
  static const String defaultAvatar = AppAsset.defaultAvatar;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final w = width ?? size;
    final h = height ?? size;

    if (url.isEmpty) return _default(w, h);

    return Image.network(
      url,
      width: w,
      height: h,
      fit: fit,
      errorBuilder: (_, _, _) => _default(w, h),
    );
  }

  Widget _default(double? w, double? h) => Image.asset(
    defaultAvatar,
    width: w,
    height: h,
    fit: fit,
    errorBuilder: (_, _, _) => Container(
      width: w,
      height: h,
      color: const Color(0xFFE6ECEF),
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: const Color(0xFF8FA8AE)),
    ),
  );
}
