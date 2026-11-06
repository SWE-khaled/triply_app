import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/network/dio_helper.dart';
import 'core/routing/app_routes.dart';
import 'features/common/auth/views/tour_guide/tour_guide_login_screen.dart';
import 'features/common/auth/views/tour_guide/tour_guide_signup_screen.dart';
import 'features/common/auth/views/tour_guide/tour_guide_verification_screen.dart';
import 'features/common/auth/views/tourist/create_account_screen.dart';
import 'features/common/auth/views/tourist/forgot_password/view/forgot_password_screen.dart';
import 'features/common/auth/views/tourist/forgot_password/view/password_reset_success_screen.dart';
import 'features/common/auth/views/tourist/sign_in_screen.dart';
import 'features/common/role_selection/view/role_selection_screen.dart';
import 'features/tourist/onboarding/view/onboarding_screen.dart';
import 'features/tourist/user_profile/view/emergency_screen.dart';
import 'features/tourist/checkout/paymob_settings.dart';
import 'features/tourist/user_profile/view/privacy_security_screen.dart';
import 'features/tourist/user_profile/view/profile_screen.dart';
import 'firebase_options.dart';
import 'features/splash/cubit/startup_cubit.dart';
import 'features/splash/view/startup_gate.dart';
import 'features/tour_guide/onboarding/view/tour_guide_onboarding_screen.dart';
import 'features/admin_dashboard/d_auth/view/admin_login_view.dart';
import 'core/theme/app_theme.dart';
import 'features/common/auth/cubit/auth_cubit.dart';
import 'features/tourist/home/view/home_screen.dart';
import 'features/tourist/notifications/view/notifications_screen.dart';
import 'features/tourist/search/view/search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  PaymobSettings.initialize();
  DioHelper().initialization();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // One session cubit for both roles. Not lazy: it starts listening
        // to Firebase at launch, so the restored user is ready by the time
        // any screen reads it (and the profile self-heal can run).
        BlocProvider(lazy: false, create: (_) => AuthCubit()),
        // Resolves the restored Firebase session while the splash animates.
        // Not lazy: the work must start at launch, not when the gate mounts.
        BlocProvider(lazy: false, create: (_) => StartupCubit()..resolve()),
      ],
      child: MaterialApp(
        title: 'Triply',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        onGenerateInitialRoutes: (_) => [
          AppRoutes.splash(nextPageBuilder: (_) => const StartupGate()),
        ],
        routes: {
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.search: (context) => const SearchScreen(),
          AppRoutes.notifications: (context) => const NotificationsScreen(),
          AppRoutes.onboarding: (context) => const OnboardingScreen(),
          AppRoutes.roleSelection: (context) => const RoleSelectionScreen(),
          AppRoutes.guideOnboarding: (context) =>
              const TourGuideOnboardingScreen(),
          AppRoutes.guideLogin: (context) => const TourGuideLoginScreen(),
          AppRoutes.guideSignup: (context) => const TourGuideSignupScreen(),
          AppRoutes.guideVerification: (context) =>
              const TourGuideVerificationScreen(),
          AdminRoutes.login: (context) => const AdminLoginView(),
          AppRoutes.signIn: (context) => const SignInScreen(),
          AppRoutes.createAccount: (context) => const CreateAccountScreen(),
          ForgotPasswordScreen.routeName: (context) =>
              const ForgotPasswordScreen(),
          AppRoutes.passwordResetSuccess: (context) =>
              const PasswordResetSuccessScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),
          AppRoutes.privacySecurity: (context) => const PrivacySecurityScreen(),
          AppRoutes.emergency: (context) => const EmergencyScreen(),
        },
      ),
    );
  }
}
