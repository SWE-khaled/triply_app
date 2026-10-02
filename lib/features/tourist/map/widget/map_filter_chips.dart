import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../controller/map_controller.dart';

/// Filter chips row extracted from `map_view.dart:157-190`.
class MapFilterChips extends StatelessWidget {
  final MapFilter selectedFilter;
  final ValueChanged<MapFilter> onFilterSelected;

  const MapFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: MapFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = MapFilter.values[i];
          final isSelected = selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) => onFilterSelected(filter),
            selectedColor: AppColors.primaryTeal,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textGrey,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryTeal
                    : AppColors.cardBorder,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
