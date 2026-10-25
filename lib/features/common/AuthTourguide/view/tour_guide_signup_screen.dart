import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourguide/cubit/tour_guide_auth_cubit.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_button.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_header.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_text_field.dart';
import '../../../../core/constants/app_colors.dart';
import 'tour_guide_login_screen.dart';
import 'tour_guide_verification_screen.dart';

class TourGuideSignupScreen extends StatefulWidget {
  const TourGuideSignupScreen({super.key});

  @override
  State<TourGuideSignupScreen> createState() => _TourGuideSignupScreenState();
}

class _TourGuideSignupScreenState extends State<TourGuideSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(TourGuideAuthCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await cubit.registerGuide(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: '+20${_phoneController.text.trim()}',
      licenseNumber: '',
      languages: const ['Arabic', 'English'], // default; can extend later
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TourGuideVerificationScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.errorMessage ?? 'Registration failed'),
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
                  subtitle: 'Create your professional guide account.',
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
                              'Become a Triply Guide',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create your professional guide account.',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'Full name',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            AuthTextField(
                              controller: _nameController,
                              hintText: 'Your full legal name',
                              icon: Icons.person_outline,
                              validator: (v) =>
                                  (v == null || v.trim().length < 3)
                                  ? 'Enter your full name (min 3 characters)'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Phone number',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            AuthTextField(
                              controller: _phoneController,
                              hintText: '1012345678',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              prefix: const Text(
                                '🇪🇬 +20 ',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 15,
                                ),
                              ),
                              validator: (v) {
                                final digits = (v ?? '').replaceAll(
                                  RegExp(r'\D'),
                                  '',
                                );
                                if (digits.isEmpty) {
                                  return 'Enter your phone number';
                                }
                                if (!RegExp(
                                  r'^1[0125]\d{8}$',
                                ).hasMatch(digits)) {
                                  return 'Enter a valid Egyptian mobile number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
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
                                  return 'Email is required';
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
                                  return 'Password is required';
                                }
                                if (v.length < 6) {
                                  return 'Minimum 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Confirm password',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            AuthTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Repeat your password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (v != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            AuthButton(
                              label: 'Continue to Verification',
                              isLoading: cubit.isLoading,
                              onPressed: () => _handleRegister(cubit),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Wrap(
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TourGuideLoginScreen(),
                                      ),
                                    ),
                                    child: const Text(
                                      'Log In',
                                      style: TextStyle(
                                        color: AppColors.signInDark,
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
