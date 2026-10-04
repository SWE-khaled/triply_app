import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';

/// Tourist bottom nav: detached floating glass pill (Instagram-like).
/// Very translucent with blur, plus a soft shadow and a thin border so it
/// stays visible even over a plain white background.
/// Screens set `extendBody: true`. Same tab order everywhere:
/// Home / My Trip / Places / Community / Profile.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({super.key, required this.currentIndex, this.onTap});

  static const _icons = [
    LucideIcons.house,
    LucideIcons.route,
    LucideIcons.mapPin,
    LucideIcons.messageCircle,
    LucideIcons.user,
  ];

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
                    final selected = i == currentIndex;
                    final color = selected
                        ? AppColors.bottomNavSelected
                        : const Color.fromARGB(255, 171, 182, 187);
                    return GestureDetector(
                      onTap: onTap == null ? null : () => onTap!(i),
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