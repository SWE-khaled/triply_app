import 'package:flutter/material.dart';
import '../model/guide.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
        padding:  EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDefault,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                guide.avatarUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.surfaceElevated,
                  alignment: Alignment.center,
                  child: Text(
                    guide.name.isNotEmpty ? guide.name[0].toUpperCase() : '?',
                    style:  TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          guide.name,
                          style:  TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.guidesName,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                       Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.primaryTeal,
                      ),
                    ],
                  ),
                  Text(guide.specialty, style: AppTextStyles.bodyGrey),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       Icon(Icons.star, size: 14, color: AppColors.statusWarning),
                      Text(
                        ' ${guide.rating} (${guide.reviewCount})',
                        style: AppTextStyles.bodyGrey,
                      ),
                      const Spacer(),
                      Text(
                        'From EGP ${guide.pricePerHour.toInt()}',
                        style: AppTextStyles.price,
                      ),
                       Text('/hr', style: AppTextStyles.bodyGrey),
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
