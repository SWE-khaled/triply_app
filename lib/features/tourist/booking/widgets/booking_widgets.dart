import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';

/// Step indicator from Figma: 1 Date & Time — 2 Details — 3 Confirm.
class BookingStepper extends StatelessWidget {
  final int stepIndex; // 0..2 (success step reuses 2 as all-done)

  const BookingStepper({super.key, required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    final display = stepIndex >= 3 ? 2 : stepIndex;
    final activeColor = AppThemeColors.resolve(
      context,
      light: AppColors.primary,
      dark: AppThemeDark.homeSeeAll,
    );
    return Row(
      children: [
        // Loose dots keep their natural width when there is room and shrink
        // (ellipsising the label) on narrow screens; the connectors flex
        // around them. This avoids an overflow at 320-390px.
        Flexible(child: _dot(context, 0, 'Date & Time', display, activeColor)),
        _line(context, display >= 1),
        Flexible(child: _dot(context, 1, 'Details', display, activeColor)),
        _line(context, display >= 2),
        Flexible(child: _dot(context, 2, 'Confirm', display, activeColor)),
      ],
    );
  }

  Widget _dot(
    BuildContext context,
    int index,
    String label,
    int display,
    Color activeColor,
  ) {
    final done = index < display;
    final current = index == display;
    final active = done || current;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: active
                ? activeColor
                : AppThemeColors.resolve(
                    context,
                    light: AppColors.searchBg,
                    dark: AppThemeDark.surfaceElevated,
                  ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: done
              ? Icon(
                  Icons.check,
                  size: 14,
                  color: AppThemeColors.resolve(
                    context,
                    light: Colors.white,
                    dark: AppThemeDark.backgroundPrimary,
                  ),
                )
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? AppThemeColors.resolve(
                            context,
                            light: Colors.white,
                            dark: AppThemeDark.backgroundPrimary,
                          )
                        : AppThemeColors.resolve(
                            context,
                            light: AppColors.subtitle,
                            dark: AppThemeDark.textSecondary,
                          ),
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: current ? FontWeight.w700 : FontWeight.w500,
              color: active
                  ? activeColor
                  : AppThemeColors.resolve(
                      context,
                      light: AppColors.hint,
                      dark: AppThemeDark.textDisabled,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _line(BuildContext context, bool filled) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: filled
            ? AppThemeColors.resolve(
                context,
                light: AppColors.primary,
                dark: AppThemeDark.homeSeeAll,
              )
            : AppThemeColors.resolve(
                context,
                light: AppColors.cardBorder,
                dark: AppThemeDark.borderSubtle,
              ),
      ),
    );
  }
}

/// Single-select pill used for time slots and durations.
class SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<String>? onSelected;

  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppThemeColors.resolve(
      context,
      light: AppColors.primary,
      dark: AppThemeDark.homeSeeAll,
    );
    final surfaceColor = AppThemeColors.resolve(
      context,
      light: AppColors.background,
      dark: AppThemeDark.surfaceDefault,
    );
    final borderColor = AppThemeColors.resolve(
      context,
      light: AppColors.cardBorder,
      dark: AppThemeDark.borderSubtle,
    );
    return InkWell(
      onTap: onSelected == null ? null : () => onSelected!(label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedColor : surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? selectedColor : borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppThemeColors.resolve(
                    context,
                    light: Colors.white,
                    dark: AppThemeDark.backgroundPrimary,
                  )
                : AppThemeColors.resolve(
                    context,
                    light: AppColors.title,
                    dark: AppThemeDark.textSecondary,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Full-width single-select meeting point tile from Figma step 2.
class MeetingPointTile extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<String>? onSelected;

  const MeetingPointTile({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppThemeColors.resolve(
      context,
      light: AppColors.primary,
      dark: AppThemeDark.homeSeeAll,
    );
    final surfaceColor = AppThemeColors.resolve(
      context,
      light: AppColors.background,
      dark: AppThemeDark.surfaceDefault,
    );
    return InkWell(
      onTap: onSelected == null ? null : () => onSelected!(label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? selectedColor : surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? selectedColor
                : AppThemeColors.resolve(
                    context,
                    light: AppColors.cardBorder,
                    dark: AppThemeDark.borderSubtle,
                  ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: selected
                  ? const Color(0xFFF5C445)
                  : AppThemeColors.resolve(
                      context,
                      light: AppColors.subtitle,
                      dark: AppThemeDark.homeGuideSecondary,
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppThemeColors.resolve(
                        context,
                        light: Colors.white,
                        dark: AppThemeDark.backgroundPrimary,
                      )
                    : AppThemeColors.resolve(
                        context,
                        light: AppColors.title,
                        dark: AppThemeDark.textSecondary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label/value row for Booking Summary + Price Breakdown.
class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Loose fit keeps short labels unchanged; long price-breakdown
          // labels (e.g. rate x hours x travelers) ellipsise on narrow
          // screens instead of overflowing the row at 320px.
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: AppThemeColors.resolve(
                  context,
                  light: AppColors.subtitle,
                  dark: AppThemeDark.homeGuideSecondary,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.title,
                dark: AppThemeDark.homeGuideName,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
