import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/AuthTourist/constants/auth_colors.dart';
import 'package:triply/features/common/AuthTourist/widgets/auth_text_field.dart';
import 'package:triply/features/admin_dashboard/d_home/view/d_home_view.dart';
import '../cubit/admin_auth_cubit.dart';

/// Admin Create Account — same visual design as the Tourist
/// Create Account, responsive for mobile and web.
/// Frontend-only rule: the identifier must contain 'triplykl'.
class AdminCreateAccountView extends StatefulWidget {
  const AdminCreateAccountView({super.key});

  @override
  State<AdminCreateAccountView> createState() => _AdminCreateAccountViewState();
}

class _AdminCreateAccountViewState extends State<AdminCreateAccountView> {
  static const double _webBreakpoint = 900;
  static const double _formMaxWidth = 480;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [
      _nameController,
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

  Future<void> _handleCreateAccount(AdminAuthCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await cubit.createAccount(
      name: _nameController.text.trim(),
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

  // ───────────── Brand pieces ─────────────
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

  /// Header للموبايل (فوق الفورم)
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
                    'Create your admin account',
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

  /// بانل الـ Brand على اليسار في الويب
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
              'Create your admin account',
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

  // ───────────── Create Account button (Disabled / Enabled) ─────────────
  Widget _buildCreateButton(AdminAuthCubit cubit, bool isLoading) {
    final enabled = _isFormFilled && !isLoading;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? () => _handleCreateAccount(cubit) : null,
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
        child: isLoading
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

  // ───────────── Form (مشترك بين الموبايل والويب) ─────────────
  Widget _buildForm(AdminAuthCubit cubit, AdminAuthState state) {
    final isLoading = state is AdminAuthLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create admin account',
            style: TextStyle(
              fontSize: 25,
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
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter your full name'
                : null,
          ),
          const SizedBox(height: 22),
          _label('Email'),
          const SizedBox(height: 10),
          AuthTextField(
            controller: _emailController,
            hintText: 'khaled@gmail.com',
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
          const SizedBox(height: 28),
          _buildCreateButton(cubit, isLoading),
          const SizedBox(height: 28),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Already have an admin account? ',
                  style: TextStyle(color: AuthColors.textGrey, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
    );
  }

  /// Scroll + توسيط الفورم بعرض أقصى
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

                // ───── Web: بانل Brand يسار + فورم يمين ─────
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

                // ───── Mobile: Header فوق + فورم تحته ─────
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