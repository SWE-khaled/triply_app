import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/services/profile_self_heal_service.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/common/auth/cubit/auth_cubit.dart';
import 'package:triply/features/common/auth/data/auth_repository.dart';
import 'package:triply/features/tourist/community/data/community_posts_repository.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';
import 'package:triply/features/tourist/user_profile/cubit/profile_posts_cubit.dart';
import 'package:triply/features/tourist/user_profile/view/my_posts_screen.dart';

void main() {
  testWidgets('My posts supports dark mode without changing light colors', (
    tester,
  ) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(),
      profileHeal: ProfileSelfHealService(),
    );
    final postsCubit = ProfilePostsCubit(
      postsRepository: _FakeCommunityPostsRepository(),
    );
    addTearDown(authCubit.close);
    addTearDown(postsCubit.close);

    await tester.pumpWidget(_app(ThemeMode.dark, authCubit, postsCubit));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('My posts')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester
          .widget<Text>(
            find.text(
              'Your published travel moments, all in one place. View or remove a post.',
            ),
          )
          .style
          ?.color,
      AppThemeDark.homeGuideSecondary,
    );
    expect(
      tester
          .widget<Text>(find.text('You have no published travel moments yet.'))
          .style
          ?.color,
      AppThemeDark.homeGuideSecondary,
    );

    await tester.pumpWidget(_app(ThemeMode.light, authCubit, postsCubit));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    expect(
      tester.widget<Text>(find.text('My posts')).style?.color,
      const Color(0xFF263A40),
    );
    expect(
      tester
          .widget<Text>(
            find.text(
              'Your published travel moments, all in one place. View or remove a post.',
            ),
          )
          .style
          ?.color,
      const Color(0xFF62777D),
    );
    expect(
      tester
          .widget<Text>(find.text('You have no published travel moments yet.'))
          .style
          ?.color,
      const Color(0xFF62777D),
    );
  });
}

Widget _app(ThemeMode mode, AuthCubit authCubit, ProfilePostsCubit postsCubit) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: authCubit),
      BlocProvider.value(value: postsCubit),
    ],
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: mode,
      home: const MyPostsScreen(),
    ),
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  User? get currentUser => null;

  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCommunityPostsRepository implements CommunityPostsRepository {
  @override
  Stream<List<CommunityPost>> watchMyPosts() => Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
