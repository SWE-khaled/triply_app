import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourist/constants/auth_colors.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_button.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_text_field.dart';
import 'package:triply/features/admin_dashboard/d_home/view/d_home_view.dart';
import '../cubit/admin_auth_cubit.dart';
import 'admin_create_account_view.dart';

/// Admin Login — same visual design as the Tourist Login,
/// responsive for mobile and web.
/// Frontend-only rule: the identifier must contain 'triplykl'.
class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  static const double _webBreakpoint = 900;
  static const double _formMaxWidth = 480;

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
    if (success && cubit.session != null) {
      final session = cubit.session!;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => AdminAuthCubit.authenticated(session),
            child: const HomeView(),
          ),
        ),
        (_) => false,
      );
    } else if (cubit.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(cubit.errorMessage!)));
    }
  }


  BoxDecoration _gradient({BorderRadius? radius}) => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [Color(0xFF0E5566), Color(0xFF020B0D)],
    ),
    borderRadius: radius,
  );

  Widget _logo({double scale = 1}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/edits/Frame 1.png',
            width: 40 * scale,
            height: 62 * scale,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 4 * scale),
        Image.asset(
          'assets/images/edits/Frame 2.png',
          height: 38 * scale,
          width: 93 * scale,
          fit: BoxFit.contain,
        ),
      ],
    );
  }


  Widget _buildMobileHeader() {
    return Container(
      height: 248,
      width: double.infinity,
      decoration: _gradient(
        radius: const BorderRadius.only(
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
              child: _logo(),
            ),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 158),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Admin Console',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage Triply from one place',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildWebBrandPanel() {
    return Container(
      decoration: _gradient(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _logo(scale: 1.8),
            const SizedBox(height: 32),
            const Text(
              'Admin Console',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage Triply from one place',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
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


  Widget _buildForm(AdminAuthCubit cubit, AdminAuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back, Admin',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3238),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in with your admin identifier',
            style: TextStyle(color: AuthColors.textGrey, fontSize: 16),
          ),
          const SizedBox(height: 28),
          _label('Email'),
          const SizedBox(height: 10),
          AuthTextField(
            controller: _emailController,
            hintText: 'admin@gmail.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => (value == null || !value.contains('@'))
                ? 'Enter a valid email'
                : null,
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
          const SizedBox(height: 28),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: AuthButton(
              label: 'Log In',
              isLoading: state is AdminAuthLoading,
              onPressed: () => _handleLogin(cubit),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  "Don't have an admin account? ",
                  style: TextStyle(color: AuthColors.textGrey, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminCreateAccountView(),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
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
    );
  }


  Widget _buildScrollableForm(
    AdminAuthCubit cubit,
    AdminAuthState state, {
    required EdgeInsets padding,
  }) {
    return SingleChildScrollView(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _formMaxWidth),
          child: _buildForm(cubit, state),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminAuthCubit(),
      child: BlocBuilder<AdminAuthCubit, AdminAuthState>(
        builder: (context, state) {
          final cubit = context.read<AdminAuthCubit>();

          return Scaffold(
            backgroundColor: Colors.white,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth >= _webBreakpoint;

      
                if (isWeb) {
                  return Row(
                    children: [
                      Expanded(flex: 5, child: _buildWebBrandPanel()),
                      Expanded(
                        flex: 6,
                        child: Center(
                          child: _buildScrollableForm(
                            cubit,
                            state,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

     
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMobileHeader(),
                    Expanded(
                      child: _buildScrollableForm(
                        cubit,
                        state,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}