import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/widgets/guide_shared_widgets.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';

class GuideCard extends StatelessWidget {
  final Guide guide;
  final VoidCallback? onTap;
  final VoidCallback? onChatPressed;

  const GuideCard({
    super.key,
    required this.guide,
    this.onTap,
    this.onChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDefault,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textDisabled.withValues(alpha: .6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                guide.avatarUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.actionPrimary.withValues(alpha: .2),
                  alignment: Alignment.center,
                  child: Text(
                    guide.name.isNotEmpty ? guide.name[0] : '?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.actionPrimary,
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
                      Text(
                        guide.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.actionPrimary,
                        ),
                      ),
                      SizedBox(width: 4),
                      if (guide.isVerified)
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.actionSecondary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    guide.specialty,
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: guide.languages
                        .map(
                          (l) => LanguageChip(
                            label: l,
                            backgroundColor: AppColors.actionSecondary.withValues(alpha: .1),
                            textColor: AppColors.actionSecondary,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingRow(
                        rating: guide.rating,
                        reviewCount: guide.reviewCount,
                        ratingColor: AppColors.actionPrimary,
                        reviewCountColor: AppColors.textDisabled,
                      ),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'From ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.statusErrorPressed,
                              ),
                            ),
                            TextSpan(
                              text: guide.formatPrice(guide.pricePerHour),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.statusErrorPressed,
                              ),
                            ),
                             TextSpan(
                              text: '/hr',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textDisabled,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // const SizedBox(width: 8),
            // InkWell(
            //   onTap: onChatPressed,
            //   borderRadius: BorderRadius.circular(20),
            //   child: Container(
            //     width: 32,
            //     height: 32,
            //     decoration:  BoxDecoration(
            //       color: AppColors.actionSecondary.withOpacity(.15),
            //       shape: BoxShape.circle,
            //     ),
            //     child:  Icon(Icons.chat_outlined,
            //         size: 16, color: AppColors.actionSecondary),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
