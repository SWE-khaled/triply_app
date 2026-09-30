import 'package:flutter/material.dart';

/// Round icon button used over images (back / favorite / share).
class CircleBackButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;

  const CircleBackButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
    this.backgroundColor = const Color(0x40000000),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 17, color: iconColor),
      ),
    );
  }
}
