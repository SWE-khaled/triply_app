import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../map/model/place.dart';

class AboutTab extends StatelessWidget {
  final Place place;

  const AboutTab({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          place.about,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            letterSpacing: 0,
            height: 1.6,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Highlights',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        ...place.highlights.map(
          (h) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 10, color: AppColors.bulletGold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    h,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      letterSpacing: 0,
                      color: Color(0xFF526B72),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
