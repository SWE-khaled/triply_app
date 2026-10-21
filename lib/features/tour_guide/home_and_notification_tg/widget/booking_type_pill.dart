import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Cream/tan tints from Figma (public pill). Local consts only — the global
/// theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);
const Color _tanText = Color(0xFF9A7B2D);

/// Uppercase booking-type pill (PRIVATE/PUBLIC BOOKING), same look as the
/// Dashboard booking cards.
class BookingTypePill extends StatelessWidget {
  final bool isPrivate;

  const BookingTypePill({super.key, required this.isPrivate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPrivate ? AppColors.primaryLight : _cream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isPrivate ? 'PRIVATE BOOKING' : 'PUBLIC BOOKING',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isPrivate ? AppColors.primary : _tanText,
        ),
      ),
    );
  }
}
