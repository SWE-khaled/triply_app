import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tourist bottom navigation.
/// Screens set `extendBody: true`. Same tab order everywhere:
/// Home / Trips / Map / Community / Profile.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({super.key, required this.currentIndex, this.onTap});

  static const _items = [
    (
      label: 'Home',
      selected: Icons.home_rounded,
      unselected: Icons.home_outlined,
    ),
    (
      label: 'Trips',
      selected: Icons.luggage,
      unselected: Icons.luggage_outlined,
    ),
    (label: 'Map', selected: Icons.map, unselected: Icons.map_outlined),
    (
      label: 'Community',
      selected: Icons.groups,
      unselected: Icons.groups_outlined,
    ),
    (
      label: 'Profile',
      selected: Icons.person,
      unselected: Icons.person_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              final color = selected
                  ? AppColors.bottomNavSelected
                  : AppColors.subtitle;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: item.label,
                  child: InkWell(
                    onTap: onTap == null ? null : () => onTap!(i),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? item.selected : item.unselected,
                            size: 27,
                            color: color,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontSize: 13,
                              height: 1.2,
                              fontWeight: selected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
