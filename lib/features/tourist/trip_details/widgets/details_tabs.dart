import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class DetailsTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const DetailsTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (i) {
        final selected = i == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(i),
            behavior: HitTestBehavior.opaque,
            // The labels are spread over the row, but the selected pill
            // hugs its own label instead of filling a slot.
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.tabSelectedBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tabs[i],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.subtitle,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
