import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Step indicator from Figma: 1 Date & Time — 2 Details — 3 Confirm.
class BookingStepper extends StatelessWidget {
  final int stepIndex; // 0..2 (success step reuses 2 as all-done)

  const BookingStepper({super.key, required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    final display = stepIndex >= 3 ? 2 : stepIndex;
    return Row(
      children: [
        _dot(0, 'Date & Time', display),
        _line(display >= 1),
        _dot(1, 'Details', display),
        _line(display >= 2),
        _dot(2, 'Confirm', display),
      ],
    );
  }

  Widget _dot(int index, String label, int display) {
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
            color: active ? AppColors.primary : AppColors.searchBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.subtitle,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: current ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.primary : AppColors.hint,
          ),
        ),
      ],
    );
  }

  Widget _line(bool filled) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: filled ? AppColors.primary : AppColors.cardBorder,
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
    return InkWell(
      onTap: onSelected == null ? null : () => onSelected!(label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.title,
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
    return InkWell(
      onTap: onSelected == null ? null : () => onSelected!(label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: selected ? const Color(0xFFF5C445) : AppColors.subtitle,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.title,
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
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.subtitle)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.title,
            ),
          ),
        ],
      ),
    );
  }
}
