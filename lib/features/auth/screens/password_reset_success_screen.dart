import 'package:flutter/material.dart';
import '../constants/auth_colors.dart';
import '../widgets/auth_button.dart';
import 'sign_in_screen.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  static const routeName = '/password-reset-success';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  color: AuthColors.lightCircleBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.check,
                    color: AuthColors.successTeal, size: 44),
              ),
              const SizedBox(height: 24),
              const Text('Password Reset!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'Your password has been updated successfully. Sign in with your new password.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AuthColors.textGrey, fontSize: 15),
              ),
              const SizedBox(height: 32),
              AuthButton(
                label: 'Back to Sign In',
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    SignInScreen.routeName, (route) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}