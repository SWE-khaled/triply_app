import 'package:flutter/material.dart';

import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import '../cubit/map_state.dart';

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
            backgroundColor: AppThemeColors.resolve(
              context,
              light: Colors.white,
              dark: AppThemeDark.surfaceDefault,
            ),
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : AppThemeColors.resolve(
                      context,
                      light: AppColors.textGrey,
                      dark: AppThemeDark.textSecondary,
                    ),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryTeal
                    : AppThemeColors.resolve(
                        context,
                        light: AppColors.cardBorder,
                        dark: AppThemeDark.borderSubtle,
                      ),
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
