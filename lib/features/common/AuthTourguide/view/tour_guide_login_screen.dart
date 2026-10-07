import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_dashboard/features/common/AuthTourguide/data/tour_guide_auth_service.dart';
import 'package:admin_dashboard/features/common/AuthTourguide/providers/tour_guide_auth_provider.dart';
import 'package:admin_dashboard/features/common/AuthTourist/constants/auth_colors.dart';
import 'package:admin_dashboard/features/common/AuthTourist/widgets/auth_button.dart';
import 'package:admin_dashboard/features/common/AuthTourist/widgets/auth_header.dart';
import 'package:admin_dashboard/features/common/AuthTourist/widgets/auth_text_field.dart';
import 'package:admin_dashboard/features/tour_guide/homeandNotificationTr/view/guide_dashboard_screen.dart';
import 'tour_guide_signup_screen.dart';
import 'tour_guide_verification_screen.dart';
// Tourist home (for role-based redirect when a tourist logs in here)
import '../../../tourist/home/view/home_screen.dart';

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

  Future<void> _handleLogin(TourGuideAuthProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final role = await provider.signInGuide(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (role == null) {
      // Error is set in provider, show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (role == 'guide') {
      // Verified guides go straight home; others complete verification.
      // Verification state lives in Firestore, so it survives logout/login.
      final approved =
          await TourGuideAuthService().isVerificationApproved();
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
      // Tourist account logged in via guide screen → redirect to tourist home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TourGuideAuthProvider(),
      child: Consumer<TourGuideAuthProvider>(
        builder: (context, provider, _) {
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
                              isLoading: provider.isLoading,
                              onPressed: () => _handleLogin(provider),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Wrap(
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style:
                                        TextStyle(color: AuthColors.textGrey),
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

