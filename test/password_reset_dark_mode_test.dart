import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/services/profile_self_heal_service.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/common/auth/cubit/auth_cubit.dart';
import 'package:triply/features/common/auth/data/auth_repository.dart';
import 'package:triply/features/common/auth/views/tourist/forgot_password/view/forgot_password_screen.dart';
import 'package:triply/features/common/auth/views/tourist/forgot_password/view/new_password_screen.dart';
import 'package:triply/features/common/auth/views/tourist/forgot_password/view/password_reset_success_screen.dart';

void main() {
  testWidgets('Forgot password adapts to dark and light themes', (
    tester,
  ) async {
    final cubit = AuthCubit(
      authRepository: _FakeAuthRepository(),
      profileHeal: ProfileSelfHealService(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_forgotPasswordApp(ThemeMode.dark, cubit));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Forgot Password?')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      _fieldFillColor(tester, find.byType(TextFormField).first),
      AppThemeDark.backgroundSecondary,
    );
    expect(
      tester.widget<Text>(find.text('Sign in')).style?.color,
      AppThemeDark.homeSeeAll,
    );

    await tester.pumpWidget(_forgotPasswordApp(ThemeMode.light, cubit));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppColors.background,
    );
    expect(
      tester.widget<Text>(find.text('Forgot Password?')).style?.color,
      AppColors.textDark,
    );
    expect(
      _fieldFillColor(tester, find.byType(TextFormField).first),
      AppColors.fieldBackground,
    );
    expect(
      tester.widget<Text>(find.text('Sign in')).style?.color,
      AppColors.signInDark,
    );
  });

  testWidgets('New password fields use dark colors and retain light colors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(ThemeMode.dark, const NewPasswordScreen(oobCode: 'test')),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      _fieldFillColor(tester, find.byType(TextFormField).first),
      AppThemeDark.backgroundSecondary,
    );
    expect(
      tester.widget<Text>(find.text('New Password').first).style?.color,
      AppThemeDark.homeSectionTitle,
    );

    await tester.pumpWidget(
      _app(ThemeMode.light, const NewPasswordScreen(oobCode: 'test')),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppColors.background,
    );
    expect(
      _fieldFillColor(tester, find.byType(TextFormField).first),
      AppColors.fieldBackground,
    );
    expect(
      tester.widget<Text>(find.text('New Password').first).style?.color,
      AppColors.textDark,
    );
  });

  testWidgets('Password reset success adapts to dark and light themes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(ThemeMode.dark, const PasswordResetSuccessScreen()),
    );

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester
          .widget<Text>(
            find.text(
              'Your password has been updated successfully. Sign in with your new password.',
            ),
          )
          .style
          ?.color,
      AppThemeDark.homeGuideSecondary,
    );

    await tester.pumpWidget(
      _app(ThemeMode.light, const PasswordResetSuccessScreen()),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppColors.background,
    );
    expect(
      tester
          .widget<Text>(
            find.text(
              'Your password has been updated successfully. Sign in with your new password.',
            ),
          )
          .style
          ?.color,
      AppColors.textGrey,
    );
  });
}

Widget _forgotPasswordApp(ThemeMode mode, AuthCubit cubit) {
  return BlocProvider.value(
    value: cubit,
    child: _app(mode, const ForgotPasswordScreen()),
  );
}

Color? _fieldFillColor(WidgetTester tester, Finder formField) {
  final textField = find.descendant(
    of: formField,
    matching: find.byType(TextField),
  );
  return tester.widget<TextField>(textField).decoration?.fillColor;
}

Widget _app(ThemeMode mode, Widget home) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: home,
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  User? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
