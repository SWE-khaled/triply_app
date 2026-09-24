import 'package:flutter/material.dart';
import '../../models/trip.dart';
import '../theme/app_text_styles.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;

  const TripCard({super.key, required this.trip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(trip.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trip.title, style: AppTextStyles.cardTitle),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text('${trip.duration} · ${trip.location}',
                        style: AppTextStyles.cardSubtitle),
                  ),
                  Text('\$${trip.price.toInt()}', style: AppTextStyles.price),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
