import 'package:flutter/material.dart';
import '../../models/guide.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GuideTile extends StatelessWidget {
  final Guide guide;
  final VoidCallback? onTap;

  const GuideTile({super.key, required this.guide, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(guide.avatarUrl,
                  width: 56, height: 56, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(guide.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryTeal)),
                      ),
                      const Icon(Icons.verified, size: 16, color: AppColors.primaryTeal),
                    ],
                  ),
                  Text(guide.specialty, style: AppTextStyles.bodyGrey),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(' ${guide.rating} (${guide.reviewCount})',
                          style: AppTextStyles.bodyGrey),
                      const Spacer(),
                      Text('From \$${guide.pricePerHour.toInt()}',
                          style: AppTextStyles.price),
                      const Text('/hr', style: AppTextStyles.bodyGrey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
