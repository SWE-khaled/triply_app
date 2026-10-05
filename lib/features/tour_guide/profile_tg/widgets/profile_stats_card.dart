import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// White overlapping stats card: Reviews | Languages | Price/hr.
class ProfileStatsCard extends StatelessWidget {
  final String reviews;
  final String languages;
  final String price;

  const ProfileStatsCard({
    super.key,
    required this.reviews,
    required this.languages,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      transform: Matrix4.translationValues(0, -20, 0),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffFAF5EC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(value: reviews, label: 'Reviews'),
          _divider(),
          _StatItem(value: languages, label: 'Languages'),
          _divider(),
          _StatItem(value: price, label: 'Price/hr'),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 32, color: AppColors.cardBorder);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.titleDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.subtitle),
          ),
        ],
      ),
    );
  }
}
