import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Star + rating pill (`map_view.dart:336` preview card, place-detail rating row).
class RatingBadge extends StatelessWidget {
  final String rating;
  final Color backgroundColor;

  const RatingBadge({
    super.key,
    required this.rating,
    this.backgroundColor = const Color(0xFFFFF3D6),
  });

  factory RatingBadge.fromNum(
    num rating, {
    Key? key,
    Color backgroundColor = const Color(0xFFFFF3D6),
  }) {
    return RatingBadge(
      key: key,
      rating: rating.toString(),
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: AppColors.starGold),
          const SizedBox(width: 2),
          Text(
            rating,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
