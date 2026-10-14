import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:triply/core/theme/app_colors.dart';

/// 3-tab bottom bar from the guide Figma (Home / My Trips / Profile).
/// Visuals mirror the tourist floating glass pill ([AppBottomNav]:
/// detached capsule, blur, translucent background, border, shadow and
/// the same oval active highlight). Tabs, icons, indices and tap
/// behavior are unchanged.
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

  /// Same IconData as the Tourist navbar ([AppBottomNav]): Home → house,
  /// My Trips → route (Tourist Trips/Explore icon), Profile → user.
  static const _icons = [
    LucideIcons.house,
    LucideIcons.route,
    LucideIcons.user,
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EDF0).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_icons.length, (i) {
                    final selected = i == _selected;
                    final color = selected
                        ? AppColors.bottomNavSelected
                        : const Color.fromARGB(255, 171, 182, 187);
                    return GestureDetector(
                      onTap: () => _handleTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.bottomNavSelected.withValues(
                                  alpha: 0.16,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: AnimatedScale(
                          scale: selected ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          child: Icon(
                            _icons[i],
                            size: 25,
                            color: color,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}