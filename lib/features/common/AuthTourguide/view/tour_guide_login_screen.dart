import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourguide/data/tour_guide_auth_service.dart';
import 'package:triply/features/common/AuthTourguide/cubit/tour_guide_auth_cubit.dart';
import 'package:triply/features/common/AuthTourist/constants/auth_colors.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_button.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_header.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_text_field.dart';
import 'package:triply/features/tour_guide/home_and_notification_tg/view/guide_dashboard_screen.dart';
import 'tour_guide_signup_screen.dart';
import 'tour_guide_verification_screen.dart';

class TourGuideLoginScreen extends StatefulWidget {
  const TourGuideLoginScreen({super.key});

  @override
  State<TourGuideLoginScreen> createState() => _TourGuideLoginScreenState();
}

class _TourGuideLoginScreenState extends State<TourGuideLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(TourGuideAuthCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;

    final role = await cubit.signInGuide(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (role == null) {
      // Error is set in the cubit, show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (role == 'guide') {
      // Verified guides go straight home; others complete verification.
      // Verification state lives in Firestore, so it survives logout/login.
      final approved = await TourGuideAuthService().isVerificationApproved();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => approved
              ? const GuideDashboardScreen()
              : const TourGuideVerificationScreen(),
        ),
        (route) => false,
      );
    } else {
      // A non-guide account: the roles are exclusive, so the sign-in is
      // refused with a message instead of being redirected silently.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cubit.errorMessage ?? 'This account cannot use the guide portal.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TourGuideAuthCubit(),
      child: BlocBuilder<TourGuideAuthCubit, TourGuideAuthState>(
        builder: (context, state) {
          final cubit = context.read<TourGuideAuthCubit>();
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Triply',
                  subtitle: 'Sign in to manage your trips and travelers.',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back, Guide',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sign in to manage your trips and travelers.',
                              style: TextStyle(
                                color: AuthColors.textGrey,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'Email address',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            AuthTextField(
                              controller: _emailController,
                              hintText: 'guide@email.com',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!v.contains('@') || !v.contains('.')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Password',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            AuthTextField(
                              controller: _passwordController,
                              hintText: 'Enter your password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (v.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            AuthButton(
                              label: 'Log In',
                              isLoading: cubit.isLoading,
                              onPressed: () => _handleLogin(cubit),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Wrap(
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: AuthColors.textGrey,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TourGuideSignupScreen(),
                                      ),
                                    ),
                                    child: const Text(
                                      'Create Guide Account',
                                      style: TextStyle(
                                        color: AuthColors.signInDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
