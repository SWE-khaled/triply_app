import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_colors.dart';

/// Cream tint from Figma (active tab circle). Local const only — the global
/// theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);

/// 3-tab bottom bar from the guide Figma (Home / My Trips / Profile).
/// Local to tour_guide: the shared `AppBottomNav` carries tourist tabs.
///
/// Keeps its own selected index, so the active color changes on tap even if
/// the parent doesn't rebuild. If the parent changes [currentIndex], the nav
/// follows it.
class GuideBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const GuideBottomNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  State<GuideBottomNav> createState() => _GuideBottomNavState();
}

class _GuideBottomNavState extends State<GuideBottomNav> {
  late int _selected;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.work_outline, 'My Trips'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant GuideBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _selected = widget.currentIndex;
    }
  }

  void _handleTap(int i) {
    if (i != _selected) setState(() => _selected = i);
    widget.onTap?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final selected = i == _selected;
              final color =
                  selected ? AppColors.title : AppColors.bottomNavUnselected;
              return GestureDetector(
                onTap: () => _handleTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 32,
                      decoration: BoxDecoration(
                        color: selected ? _cream : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_items[i].$1, size: 22, color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _items[i].$2,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}