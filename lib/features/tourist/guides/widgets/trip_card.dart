import 'package:flutter/material.dart';
import 'package:triply/features/tourist/guides/model/trip.dart';

import '../../../../core/theme/app_colors.dart';

/// Trip row from Figma Available Trips section.
/// Image left, title + date/duration + price right.
class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;

  const TripCard({super.key, required this.trip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceElevated,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                trip.imageUrl,
                width: 75,
                height: 82,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 75,
                  height: 82,
                  color: AppColors.primaryLight,
                  alignment: Alignment.center,
                  child:  Icon(
                    Icons.landscape,
                    color: AppColors.actionPrimary,
                    size: 28,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style:  TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trip.dateLabel} - ${trip.durationLabel}',
                      style:  TextStyle(
                        fontSize: 12,
                        color: AppColors.subtitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ' ${trip.price.toStringAsFixed(0)} ${trip.currency}',
                      style:  TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.price,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
