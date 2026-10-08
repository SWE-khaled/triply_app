import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_button.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_header.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_text_field.dart';
import 'package:triply/features/admin_dashboard/d_home/view/d_home_view.dart';
import '../cubit/admin_auth_cubit.dart';
import '../cubit/admin_auth_state.dart';

/// Admin Create Account — same visual design as the Tourist
/// Create Account (AuthHeader / AuthTextField / AuthButton).
/// Frontend-only rule: the identifier must contain 'triplykl'.
class AdminCreateAccountView extends StatefulWidget {
  const AdminCreateAccountView({super.key});

  @override
  State<AdminCreateAccountView> createState() =>
      _AdminCreateAccountViewState();
}

class _AdminCreateAccountViewState extends State<AdminCreateAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount(AdminAuthCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await cubit.createAccount(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success && cubit.state.session != null) {
      final session = cubit.state.session!;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => AdminAuthCubit.authenticated(session),
            child: const HomeView(),
          ),
        ),
        (_) => false,
      );
    } else if (cubit.state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.state.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminAuthCubit(),
      child: BlocBuilder<AdminAuthCubit, AdminAuthState>(
        builder: (context, state) {
          final cubit = context.read<AdminAuthCubit>();
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Admin Console',
                  subtitle: 'Create your admin account',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create admin account',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Use an identifier containing "triplykl"',
                            style: TextStyle(
                              color: Color(0xFF94A3A8),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 28),
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
                            hintText: 'khaled@gmail.com',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                (value == null || !value.contains('@'))
                                    ? 'Enter a valid email'
                                    : null,
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
                            validator: (value) =>
                                (value == null || value.length < 6)
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
                            validator: (value) =>
                                value != _passwordController.text
                                    ? 'Passwords do not match'
                                    : null,
                          ),
                          const SizedBox(height: 28),
                          AuthButton(
                            label: 'Create Account',
                            isLoading:
                                state.status == AdminAuthStatus.loading,
                            onPressed: () => _handleCreateAccount(cubit),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Wrap(
                              children: [
                                const Text(
                                  'Already have an admin account? ',
                                  style: TextStyle(color: Color(0xFF94A3A8)),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: Color(0xFF14555F),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
