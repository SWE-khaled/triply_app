import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Place row extracted from `location_picker_view.dart:181`.
class LocationPlaceRow extends StatelessWidget {
  final String place;
  final VoidCallback onTap;

  const LocationPlaceRow({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.primaryTeal,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                place,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF17343B),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}
