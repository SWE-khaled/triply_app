import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/auth_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_step_icon.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const routeName = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    final success =
        await authProvider.sendPasswordResetEmail(_emailController.text.trim());
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset link sent to your email')),
      );
      Navigator.of(context).pop();
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(authProvider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Expanded(
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
                    const Text('Email Address',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _emailController,
                      hintText: 'your@email.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || !value.contains('@'))
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 28),
                    AuthButton(
                      label: 'Send ',
                      backgroundColor: AuthColors.signInDark,
                      isLoading: authProvider.isLoading,
                      onPressed: () => _handleSendCode(authProvider),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        children: [
                          const Text('Remember it? ',
                              style: TextStyle(color: AuthColors.textGrey)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Text('Sign in',
                                style: TextStyle(
                                    color: AuthColors.signInDark,
                                    fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}