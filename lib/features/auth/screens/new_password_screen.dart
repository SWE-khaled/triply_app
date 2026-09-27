import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/auth_colors.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_step_icon.dart';
import '../widgets/auth_text_field.dart';
import 'password_reset_success_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final String oobCode;

  const NewPasswordScreen({super.key, required this.oobCode});

  static const routeName = '/new-password';

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode,
        newPassword: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context)
            .pushReplacementNamed(PasswordResetSuccessScreen.routeName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset password: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthStepIcon(
                  icon: Icons.lock_outline,
                  title: 'New Password',
                  subtitle: "Create a strong password that you'll remember.",
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 32),
                const Text('New Password',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _passwordController,
                  hintText: 'Min. 6 characters',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) => (value == null || value.length < 6)
                      ? 'Minimum 6 characters'
                      : null,
                ),
                const SizedBox(height: 20),
                const Text('Confirm Password',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Repeat your password',
                  icon: Icons.check_circle_outline,
                  isPassword: true,
                  validator: (value) => value != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
                const SizedBox(height: 28),
                AuthButton(
                  label: 'Reset Password',
                  backgroundColor: AuthColors.mutedTeal,
                  isLoading: _isLoading,
                  onPressed: _handleResetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}