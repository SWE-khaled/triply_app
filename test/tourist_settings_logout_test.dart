import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/routing/app_routes.dart';
import 'package:triply/core/services/profile_self_heal_service.dart';
import 'package:triply/features/common/auth/cubit/auth_cubit.dart';
import 'package:triply/features/common/auth/data/auth_repository.dart';
import 'package:triply/features/tourist/user_profile/cubit/profile_cubit.dart';
import 'package:triply/features/tourist/user_profile/view/settings_screen.dart';
import 'package:triply/core/theme/theme_cubit.dart';

void main() {
  testWidgets('tourist settings logs out and navigates to sign in', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final authCubit = AuthCubit(
      authRepository: repository,
      profileHeal: ProfileSelfHealService(),
    );
    addTearDown(authCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider(create: (_) => ProfileCubit()),
          BlocProvider(create: (_) => ThemeCubit()),
        ],
        child: MaterialApp(
          home: const SettingsScreen(),
          routes: {
            AppRoutes.signIn: (_) =>
                const Scaffold(body: Center(child: Text('Signed out'))),
          },
        ),
      ),
    );

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 1);
    expect(find.text('Signed out'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  int signOutCalls = 0;

  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  User? get currentUser => null;

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
