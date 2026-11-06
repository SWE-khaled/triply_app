import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/auth/cubit/auth_cubit.dart';
import 'package:triply/features/common/auth/model/auth_role.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/features/tour_guide/home_and_notification_tg/view/guide_dashboard_screen.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/services/app_prefs.dart';
import '../../../../tour_guide/profile_tg/data/tour_guide_profile_service.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_text_field.dart';
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

  /// True from the tap until the next screen opens. The sign-in itself
  /// finishes before the guide lookup and the preference writes, so the
  /// cubit's loading flag alone would let the button re-enable too early.
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthCubit cubit) async {
    if (_isSubmitting || cubit.isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    var navigated = false;
    try {
      final success = await cubit.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: AuthRole.guide,
      );

      if (!mounted) return;

      if (!success) {
        setState(() => _isSubmitting = false);
        // Error is set in the cubit, show snackbar (this also covers the
        // cross-role guard: the repository throws "tourist account" and
        // signs the session out before anything opens).
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

      // The shared repository only lets a guide account through (non-guide
      // roles are signed out and thrown), so a successful sign-in is a guide.
      // Remember it before the next screen: this is what makes the app
      // open the guide flow directly on later launches.
      await AppPrefs.instance.setLastRole('guide');
      await AppPrefs.instance.markOnboardingSeen('guide');

      // Verified guides go straight home; others complete verification.
      // Verification state lives in Firestore, so it survives logout/login.
      final approved = await TourGuideProfileService().isVerificationApproved();
      await AppPrefs.instance.setGuideVerified(approved);
      if (!mounted) return;

      navigated = true;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => approved
              ? const GuideDashboardScreen()
              : const TourGuideVerificationScreen(),
        ),
        (route) => false,
      );
    } finally {
      if (!navigated && mounted && _isSubmitting) {
        setState(() => _isSubmitting = false);
      }
    }
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
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
                            color: AppColors.textGrey,
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
                            isLoading: _isSubmitting || cubit.isLoading,
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
                                  color: AppColors.textGrey,
                                  fontSize: 16,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.guideSignup),
                                child: const Text(
                                  'Create Guide Account',
                                  style: TextStyle(
                                    color: AppColors.signInDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 4,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamedAndRemoveUntil(
                                      AppRoutes.signIn,
                                      (_) => false,
                                    ),
                                child: const Text(
                                  'Are you a tourist? Sign in',
                                  style: TextStyle(
                                    color: AppColors.signInDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushNamed(AdminRoutes.login),
                                child: const Text(
                                  'Admin portal',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 14,
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
            ],
          ),
        );
      },
    );
  }
}
