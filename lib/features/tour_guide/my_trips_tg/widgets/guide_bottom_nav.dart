import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Guide flow bottom bar: Home / My Trips / Profile.
/// Selected tab is boxed with the orange highlight (Figma).
/// Kept feature-local: other bars live in core/widgets.
class GuideBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const GuideBottomNav({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home'),
      (Icons.calendar_today_outlined, 'My Trips'),
      (Icons.person_outline, 'Profile'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i].$1,
                    size: 22,
                    color: selected
                        ? AppColors.bottomNavSelected
                        : AppColors.bottomNavUnselected,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[i].$2,
                    style: TextStyle(
                      fontSize: 10,
                      color: selected
                          ? AppColors.bottomNavSelected
                          : AppColors.bottomNavUnselected,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              );
              return GestureDetector(
                onTap: onTap == null ? null : () => onTap!(i),
                behavior: HitTestBehavior.opaque,
                child: selected
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: content,
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        child: content,
                      ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
