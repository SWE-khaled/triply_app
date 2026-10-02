import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Marker child extracted from `map_view.dart:54-63`.
class MapPlaceMarker extends StatelessWidget {
  final VoidCallback onTap;

  const MapPlaceMarker({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(
        Icons.location_on,
        color: AppColors.primaryTeal,
        size: 40,
      ),
    );
  }
}
