import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_colors.dart';

/// Cream tint from Figma (active tab circle). Local const only — the global
/// theme in `core/theme/` is left untouched.
const Color _cream = Color(0xFFFAF5EA);

/// 4-tab bottom bar from the guide Figma (Home / My Trips / Chats /
/// Profile). Local to tour_guide: the shared `AppBottomNav` carries tourist
/// tabs.
///
/// Keeps its own selected index, so the active color changes on tap even if
/// the parent doesn't rebuild. If the parent changes [currentIndex], the nav
/// follows it.
class GuideBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  /// The sum of the guide's unread chats, shown on the Chats tab.
  final int chatUnread;

  const GuideBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.chatUnread = 0,
  });

  @override
  State<GuideBottomNav> createState() => _GuideBottomNavState();
}

class _GuideBottomNavState extends State<GuideBottomNav> {
  late int _selected;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.work_outline, 'My Trips'),
    (Icons.chat_bubble_outline, 'Chats'),
    (Icons.person_outline, 'Profile'),
  ];

  Widget _icon(int index, Color color) {
    final icon = Icon(_items[index].$1, size: 22, color: color);
    if (index != 2 || widget.chatUnread <= 0) return icon;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: -4,
          right: -7,
          child: Container(
            key: const Key('guide-nav-chat-badge'),
            constraints: const BoxConstraints(minWidth: 16),
            height: 16,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accentOrange,
              shape: BoxShape.circle,
            ),
            child: Text(
              widget.chatUnread > 99 ? '99+' : '${widget.chatUnread}',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

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
              final color = selected
                  ? AppColors.title
                  : AppColors.bottomNavUnselected;
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
                      child: _icon(i, color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _items[i].$2,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
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
