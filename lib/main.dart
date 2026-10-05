import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:triply/features/common/auth/screens/create_account_screen.dart';
import 'package:triply/features/common/auth/screens/forgot_password_screen.dart';
import 'package:triply/features/common/auth/screens/onboarding_screen.dart';
import 'package:triply/features/common/auth/screens/password_reset_success_screen.dart';
import 'package:triply/features/common/auth/screens/sign_in_screen.dart';
import 'firebase_options.dart';
import 'features/tour_guide/role_selection/view/role_selection_screen.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/common/auth/providers/auth_provider.dart';
import 'features/tourist/home/view/home_screen.dart';
import 'features/tourist/notifications/view/notifications_screen.dart';
import 'features/tourist/search/view/search_screen.dart';
import 'features/tourist/UserProfile/view/profile_screen.dart';
import 'features/tourist/UserProfile/view/privacy_security_screen.dart';
import 'features/tourist/UserProfile/view/emergency_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try { await dotenv.load(fileName: '.env'); } catch (_) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
    
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Triply',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            switch (authProvider.status) {
              case AuthStatus.initial:
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              // On auth state change we stay at RoleSelection so the user
              // can be redirected to the correct flow (tourist vs guide).
              // Each auth flow handles its own post-login navigation.
              default:
                return const RoleSelectionScreen();
            }
          },
        ),
        routes: {
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.search: (context) => const SearchScreen(),
          AppRoutes.notifications: (context) => const NotificationsScreen(),
          AppRoutes.onboarding: (context) => const OnboardingScreen(),
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
