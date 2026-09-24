import 'package:flutter/material.dart';
import '../../models/place.dart';
import '../theme/app_text_styles.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const PlaceCard({super.key, required this.place, this.onTap, this.onFavoriteTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(place.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onFavoriteTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    place.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: place.isFavorite ? Colors.red : Colors.black54,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(place.name, style: AppTextStyles.cardTitle),
                  Text('${place.city}, ${place.country}',
                      style: AppTextStyles.cardSubtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
