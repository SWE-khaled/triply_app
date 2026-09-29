import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Cream location chip (`community_screen.dart:574`, composer `new_share_screen.dart:292`).
class LocationTagChip extends StatelessWidget {
  final String label;
  final bool withSparkle;

  const LocationTagChip({
    super.key,
    required this.label,
    this.withSparkle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F0DF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        withSparkle ? '$label ✨' : label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: AppColors.primaryTeal,
        ),
      ),
    );
  }
}
