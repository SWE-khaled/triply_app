import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/location_tag_chip.dart';

/// Location row extracted from `share_composer_view.dart:264`.
class LocationRow extends StatelessWidget {
  final String? location;
  final VoidCallback onTap;

  const LocationRow({super.key, required this.location, required this.onTap});

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
            const SizedBox(width: 8),
            const Text(
              'Add Location',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: 0,
                color: Color(0xFF17343B),
              ),
            ),
            const Spacer(),
            if (location case final loc?) LocationTagChip(label: loc),
          ],
        ),
      ),
    );
  }
}
