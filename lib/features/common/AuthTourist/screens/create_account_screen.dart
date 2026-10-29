import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourist/screens/sign_in_screen.dart';
import 'package:triply/features/common/AuthTourist/constants/auth_colors.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_text_field.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  static const routeName = '/create-account';

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [
      _nameController,
      _emailController,
      _phoneController,
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

  /// Egyptian mobile validation: 10 digits starting with 10/11/12/15
  /// (accepts 01..., +20..., 0020... forms too).
  static String? validateEgyptianPhone(String? value) {
    if (_egyptianLocalDigits(value) == null) {
      return 'Enter a valid Egyptian mobile (e.g. 1012345678)';
    }
    return null;
  }

  /// Normalizes to international format: +20XXXXXXXXXX.
  static String normalizeEgyptianPhone(String value) {
    return '+20${_egyptianLocalDigits(value)!}';
  }

  static String? _egyptianLocalDigits(String? value) {
    var digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0020')) {
      digits = digits.substring(4);
    } else if (digits.startsWith('20') && digits.length == 12) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }
    if (!RegExp(r'^1[0125]\d{8}$').hasMatch(digits)) return null;
    return digits;
  }

  Future<void> _handleCreateAccount(AuthCubit authCubit) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await authCubit.signUp(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: normalizeEgyptianPhone(_phoneController.text),
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted && authCubit.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authCubit.errorMessage!)));
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
                'Discover Egypt with expert guides',
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

  // ───────────── Create Account button (Disabled / Enabled) ─────────────
  Widget _buildCreateButton(AuthCubit authCubit) {
    final enabled = _isFormFilled && !authCubit.isLoading;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? () => _handleCreateAccount(authCubit) : null,
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
        child: authCubit.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Create Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();

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
                      'Create Account',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3238),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _label('Full Name'),
                    const SizedBox(height: 10),
                    AuthTextField(
                      controller: _nameController,
                      hintText: 'Ahmed Mohamed',
                      icon: Icons.person_outline,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    _label('Email'),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 22),
                    _label('Phone Number'),
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
                            color: AppColors.textDark,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      validator: validateEgyptianPhone,
                    ),
                    const SizedBox(height: 22),
                    _label('Password'),
                    const SizedBox(height: 10),
                    AuthTextField(
                      controller: _passwordController,
                      hintText: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Minimum 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    _label('Confirm Password'),
                    const SizedBox(height: 10),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      hintText: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) => value != _passwordController.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: AuthColors.textGrey,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: 'By signing up, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(color: AuthColors.signInDark),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: AuthColors.signInDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildCreateButton(authCubit),
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
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            ),
                            child: const Text(
                              'Sign in',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
