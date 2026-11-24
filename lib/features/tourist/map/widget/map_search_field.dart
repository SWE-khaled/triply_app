import 'package:flutter/material.dart';

import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';

/// Search field extracted from `map_view.dart:119-155`.
class MapSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const MapSearchField({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Search this area...',
        hintStyle: TextStyle(
          color: AppThemeColors.resolve(
            context,
            light: AppColors.chipTextGrey,
            dark: AppThemeDark.textDisabled,
          ),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: AppThemeColors.resolve(
          context,
          light: Colors.white,
          dark: AppThemeDark.backgroundSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppThemeColors.resolve(
              context,
              light: AppColors.cardBorder,
              dark: AppThemeDark.borderDefault,
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppThemeColors.resolve(
              context,
              light: AppColors.cardBorder,
              dark: AppThemeDark.borderDefault,
            ),
          ),
        ),
      ),
    );
  }
}
