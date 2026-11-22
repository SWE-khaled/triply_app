import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/place_favorite_cubit.dart';
import '../cubit/place_favorite_state.dart';
import '../model/place.dart';
import '../../../../core/theme/app_text_styles.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaceFavoriteCubit, PlaceFavoriteState>(
      builder: (context, favoriteState) {
        final isFavorite = favoriteState.isFavorite;
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
                    onTap: () => context.read<PlaceFavoriteCubit>().toggle(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavorite ? AppColors.statusError : AppColors.overlayScrim.withValues(alpha: 0.54),
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
                      Text(
                        '${place.city}, ${place.country}',
                        style: AppTextStyles.cardSubtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
