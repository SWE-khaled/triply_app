import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourguide/cubit/tour_guide_auth_cubit.dart';
import 'package:triply/features/common/AuthTourist/constants/auth_colors.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_text_field.dart';
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

  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [
      _nameController,
      _phoneController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ];
    for (final c in _controllers) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => setState(() {});

  /// الزرار يبقى Disabled (رمادي) لحد ما كل الحقول تتملي
  bool get _isFormFilled => _controllers.every((c) => c.text.trim().isNotEmpty);

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
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
                'Create your professional guide account.',
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

  // ───────────── Continue button (Disabled / Enabled) ─────────────
  Widget _buildContinueButton(TourGuideAuthCubit cubit) {
    final enabled = _isFormFilled && !cubit.isLoading;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? () => _handleRegister(cubit) : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AuthColors.darkTeal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE8ECEC),
          disabledForegroundColor: const Color(0xFF7A8B8F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: cubit.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Continue to Verification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
                            'Become a Triply Guide',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F3238),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _label('Full name'),
                          const SizedBox(height: 10),
                          AuthTextField(
                            controller: _nameController,
                            hintText: 'Your full legal name',
                            icon: Icons.person_outline,
                            validator: (v) =>
                                (v == null || v.trim().length < 3)
                                ? 'Enter your full name (min 3 characters)'
                                : null,
                          ),
                          const SizedBox(height: 22),
                          _label('Phone number'),
                          const SizedBox(height: 10),
                          AuthTextField(
                            controller: _phoneController,
                            hintText: '1012345678',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            prefix: const Padding(
                              padding: EdgeInsets.only(right: 2),
                              child: Text(
                                '🇪🇬 +20',
                                style: TextStyle(
                                  color: AuthColors.textDark,
                                  fontSize: 15,
                                ),
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
                              if (!RegExp(r'^1[0125]\d{8}$').hasMatch(digits)) {
                                return 'Enter a valid Egyptian mobile number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          _label('Email address'),
                          const SizedBox(height: 10),
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
                                return 'Password is required';
                              }
                              if (v.length < 6) {
                                return 'Minimum 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          _label('Confirm password'),
                          const SizedBox(height: 10),
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
                          _buildContinueButton(cubit),
                          const SizedBox(height: 28),
                          Center(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: AuthColors.textGrey,
                                    fontSize: 16,
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