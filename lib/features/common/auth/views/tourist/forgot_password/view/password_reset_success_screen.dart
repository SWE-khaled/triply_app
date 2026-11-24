import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import '../../../../widgets/auth_button.dart';
import '../../sign_in_screen.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  static const routeName = '/password-reset-success';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.resolve(
        context,
        light: AppColors.background,
        dark: AppThemeDark.backgroundPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.lightCircleBg,
                    dark: AppThemeDark.surfaceElevated,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.check,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.successTeal,
                    dark: AppThemeDark.statusSuccess,
                  ),
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Password Reset!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Your password has been updated successfully. Sign in with your new password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.textGrey,
                    dark: AppThemeDark.homeGuideSecondary,
                  ),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              AuthButton(
                label: 'Back to Sign In',
                backgroundColor: AppThemeColors.resolve(
                  context,
                  light: AppColors.signInDark,
                  dark: AppThemeDark.actionPrimary,
                ),
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  SignInScreen.routeName,
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
