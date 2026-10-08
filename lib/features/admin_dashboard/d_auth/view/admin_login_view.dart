import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_button.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_header.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_text_field.dart';
import 'package:triply/features/admin_dashboard/d_home/view/d_home_view.dart';
import '../cubit/admin_auth_cubit.dart';
import '../cubit/admin_auth_state.dart';
import 'admin_create_account_view.dart';

/// Admin Login — same visual design as the Tourist Login
/// (AuthHeader / AuthTextField / AuthButton).
/// Frontend-only rule: the identifier must contain 'triplykl'.
class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AdminAuthCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await cubit.login(
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
                  subtitle: 'Manage Triply from one place',
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
                            'Welcome back, Admin',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in with your admin identifier',
                            style: TextStyle(
                              color: Color(0xFF94A3A8),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          AuthTextField(
                            controller: _emailController,
                            hintText: 'khaledtriplykl@gmail.com',
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
                          const SizedBox(height: 24),
                          AuthButton(
                            label: 'Log In',
                            isLoading:
                                state.status == AdminAuthStatus.loading,
                            onPressed: () => _handleLogin(cubit),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Wrap(
                              children: [
                                const Text(
                                  "Don't have an admin account? ",
                                  style: TextStyle(color: Color(0xFF94A3A8)),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AdminCreateAccountView(),
                                    ),
                                  ),
                                  child: const Text(
                                    'Create Account',
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
