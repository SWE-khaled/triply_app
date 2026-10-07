import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triply/features/common/AuthTourist/screens/sign_in_screen.dart';
import '../constants/auth_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import 'package:flutter/services.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Egyptian mobile validation: 10 digits starting with 10/11/12/15
  /// (accepts 01…, +20…, 0020… forms too).
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

  Future<void> _handleCreateAccount(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await authProvider.signUp(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: normalizeEgyptianPhone(_phoneController.text),
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authProvider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الـ Header الأخضر ثابت فوق
          const AuthHeader(
            title: 'Create Account',
            subtitle: 'Join Triply and explore Egypt',
          ),
          // باقي الصفحة بس هو اللي بيعمل Scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Full Name',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _nameController,
                      hintText: 'Ahmed Mohamed',
                      icon: Icons.person_outline,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Email',
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
                    const SizedBox(height: 20),
                    const Text(
                      'Phone Number',
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

                      validator: validateEgyptianPhone,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _passwordController,
                      hintText: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Minimum 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Confirm Password',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      hintText: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) => value != _passwordController.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: AuthColors.textGrey,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(text: 'By signing up, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AuthColors.signInDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AuthColors.signInDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthButton(
                      label: 'Create Account',
                      backgroundColor: AuthColors.darkTeal,
                      isLoading: authProvider.isLoading,
                      onPressed: () => _handleCreateAccount(authProvider),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: AuthColors.textGrey),
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
        ],
      ),
    );
  }
}
