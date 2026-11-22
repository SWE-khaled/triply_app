import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_colors.dart';

/// Light circle icon + title + subtitle, used on Forgot Password,
/// New Password and Password Reset Success screens.
class AuthStepIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Color? iconColor;

  const AuthStepIcon({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.iconColor,
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
              backgroundColor: AppColors.fieldBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.lightCircleBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.signInDark, size: 40),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            title,
            style:  TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style:  TextStyle(fontSize: 15, color: AppColors.textGrey),
          ),
        ),
      ],
    );
  }
}
