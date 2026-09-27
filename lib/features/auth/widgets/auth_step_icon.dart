import 'package:flutter/material.dart';
import '../constants/auth_colors.dart';

/// Light circle icon + title + subtitle, used on Forgot Password,
/// New Password and Password Reset Success screens.
class AuthStepIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Color iconColor;

  const AuthStepIcon({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.iconColor = AuthColors.signInDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: AuthColors.fieldBackground,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AuthColors.lightCircleBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: iconColor, size: 40),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AuthColors.textDark),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AuthColors.textGrey),
          ),
        ),
      ],
    );
  }
}