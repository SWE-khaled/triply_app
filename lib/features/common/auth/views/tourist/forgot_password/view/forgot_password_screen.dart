import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/theme/app_colors.dart';
import '../../../../cubit/auth_cubit.dart';
import '../../../../widgets/auth_button.dart';
import '../../../../widgets/auth_step_icon.dart';
import '../../../../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const routeName = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  /// Keeps the button loading until the screen is popped.
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode(AuthCubit authCubit) async {
    if (_isSubmitting || authCubit.isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    var dismissed = false;
    try {
      final success = await authCubit.sendPasswordResetEmail(
        _emailController.text.trim(),
      );
      if (!mounted) return;

      if (!success) {
        setState(() => _isSubmitting = false);
        final message = authCubit.errorMessage;
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset link sent to your email')),
      );
      dismissed = true;
      Navigator.of(context).pop();
    } finally {
      if (!dismissed && mounted && _isSubmitting) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthStepIcon(
                    icon: Icons.mark_email_read_outlined,
                    title: 'Forgot Password?',
                    subtitle:
                        "Enter your email and we'll send you a link to reset your password.",
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Email Address',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'your@email.com',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        (value == null || !value.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 28),
                  AuthButton(
                    label: 'Send ',
                    backgroundColor: AppColors.signInDark,
                    isLoading: _isSubmitting || authCubit.isLoading,
                    onPressed: () => _handleSendCode(authCubit),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Wrap(
                      children: [
                        const Text(
                          'Remember it? ',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: AppColors.signInDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
