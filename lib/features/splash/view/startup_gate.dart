import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../admin_dashboard/d_auth/cubit/admin_auth_cubit.dart';
import '../../admin_dashboard/d_auth/model/admin_session.dart';
import '../../admin_dashboard/d_auth/view/admin_login_view.dart';
import '../../admin_dashboard/d_home/view/d_home_view.dart';
import '../../common/auth/views/tour_guide/tour_guide_login_screen.dart';
import '../../common/auth/views/tour_guide/tour_guide_verification_screen.dart';
import '../../common/auth/views/tourist/sign_in_screen.dart';
import '../../common/role_selection/view/role_selection_screen.dart';
import '../../tour_guide/home_and_notification_tg/view/guide_dashboard_screen.dart';
import '../../tourist/home/view/home_screen.dart';
import '../cubit/startup_cubit.dart';
import '../cubit/startup_state.dart';

/// Replaces the splash once its animation ends and shows the screen that
/// matches the restored session.
class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StartupCubit, StartupState>(
      builder: (context, state) {
        return switch (state) {
          StartupLoading() => const _StartupLoadingView(),
          StartupError(:final message) => _StartupErrorView(message: message),
          StartupReady() => _destination(state),
        };
      },
    );
  }

  Widget _destination(StartupReady state) {
    switch (state.destination) {
      case StartupDestination.touristHome:
        return const HomeScreen();
      case StartupDestination.touristLogin:
        return const SignInScreen();
      case StartupDestination.guideHome:
        return const GuideDashboardScreen();
      case StartupDestination.guideVerification:
        return const TourGuideVerificationScreen();
      case StartupDestination.guideLogin:
        return const TourGuideLoginScreen();
      case StartupDestination.roleSelection:
        return const RoleSelectionScreen();
      case StartupDestination.adminLogin:
        return const AdminLoginView();
      case StartupDestination.adminDashboard:
        return BlocProvider(
          create: (_) => AdminAuthCubit.authenticated(
            AdminSession(
              name: state.adminName ?? 'Admin',
              email: state.adminEmail ?? '',
            ),
          ),
          child: const HomeView(),
        );
    }
  }
}

class _StartupLoadingView extends StatelessWidget {
  const _StartupLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F4E9),
      body: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.deepNile,
          ),
        ),
      ),
    );
  }
}

class _StartupErrorView extends StatelessWidget {
  final String message;

  const _StartupErrorView({required this.message});

  /// The gate must stay readable even when a platform error is huge; the
  /// full text is already printed by [StartupCubit].
  String get _displayMessage =>
      message.length <= 1200 ? message : '${message.substring(0, 1200)}…';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4E9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Long platform errors must scroll instead of overflowing.
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 56,
                          color: AppColors.deepNile,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Could not start Triply',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNile,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _displayMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF6B7478)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<StartupCubit>().resolve(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepNile,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                          ),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
