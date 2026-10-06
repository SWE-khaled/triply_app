import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Cream tint from Figma (banner, earnings card, public pill). Local const
/// only — the global theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);

/// Single dashboard metric card (icon, big value, label). The earnings
/// card passes [highlighted] for its cream background.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool highlighted;
  final bool valueTeal;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.highlighted = false,
    this.valueTeal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? _cream : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.searchBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.title),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: valueTeal ? AppColors.priceTeal : AppColors.title,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.subtitle),
          ),
        ],
      ),
    );
  }
}
