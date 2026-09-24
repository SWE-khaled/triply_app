import 'package:flutter/material.dart';

class CircleBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CircleBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: IconButton(
        onPressed: onPressed ?? () => Navigator.maybePop(context),
        icon: const Icon(Icons.chevron_left, size: 24),
      ),
    );
  }
}
