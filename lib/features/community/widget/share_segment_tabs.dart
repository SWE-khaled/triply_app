import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Story/Post segment control extracted from `share_composer_view.dart:189`.
class ShareSegmentTabs extends StatelessWidget {
  final bool isStory;
  final ValueChanged<bool> onSelect;

  const ShareSegmentTabs({
    super.key,
    required this.isStory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.chipGrey,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _SegmentOption(
            label: 'Story',
            selected: isStory,
            onTap: () => onSelect(true),
          ),
          _SegmentOption(
            label: 'Post',
            selected: !isStory,
            onTap: () => onSelect(false),
          ),
        ],
      ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.primaryTeal,
            ),
          ),
        ),
      ),
    );
  }
}
