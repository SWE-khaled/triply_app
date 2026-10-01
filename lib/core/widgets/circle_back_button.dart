import 'package:flutter/material.dart';



/// Round icon button. Defaults to a white back button with shadow.
/// Pass [icon]/[backgroundColor]/[iconColor] for use over images.
class CircleBackButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onPressed; // alias for the old API
  final Color iconColor;
  final Color backgroundColor;
  final double size;

  const CircleBackButton({
    super.key,
    this.icon = Icons.chevron_left,
    this.onTap,
    this.onPressed,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final callback =
        onTap ?? onPressed ?? () => Navigator.maybePop(context);
    return GestureDetector(
      onTap: callback,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: size * 0.55, color: iconColor),
      ),
    );
  }
}

