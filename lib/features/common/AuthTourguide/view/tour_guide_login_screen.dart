import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourguide/data/tour_guide_auth_service.dart';
import 'package:triply/features/common/AuthTourguide/cubit/tour_guide_auth_cubit.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_button.dart';
import 'package:triply/features/common/AuthTourist/constants/auth_colors.dart';
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
      // Error is set in the cubit, show snackbar (this also covers the
      // cross-role guard: the service throws "tourist account" and signs
      // the session out before anything opens).
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
      return;
    }

    // The service only lets a guide account through (non-guide roles
    // are signed out and thrown), so a successful sign-in is a guide.
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
  }

  // ───────────── Header ─────────────
  Widget _buildHeader() {
    return Container(
      height: 248,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0E5566), Color(0xFF020B0D)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 78),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/edits/Frame 1.png',
                      width: 40,
                      height: 62,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Image.asset(
                    'assets/images/edits/Frame 2.png',
                    height: 38,
                    width: 93,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 168),
              child: Text(
                'Sign in to manage your trips and travelers.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F3238),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TourGuideAuthCubit(),
      child: BlocBuilder<TourGuideAuthCubit, TourGuideAuthState>(
        builder: (context, state) {
          final cubit = context.read<TourGuideAuthCubit>();
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back, Guide',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F3238),
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
                          _label('Email address'),
                          const SizedBox(height: 10),
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
                          const SizedBox(height: 22),
                          _label('Password'),
                          const SizedBox(height: 10),
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
                          const SizedBox(height: 28),
                          SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: AuthButton(
                              label: 'Log In',
                              isLoading: cubit.isLoading,
                              onPressed: () => _handleLogin(cubit),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: AuthColors.textGrey,
                                    fontSize: 16,
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
              ],
            ),
          );
        },
      ),
    );
  }
}
