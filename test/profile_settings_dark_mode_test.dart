import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/services/profile_self_heal_service.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/core/theme/theme_cubit.dart';
import 'package:triply/features/common/auth/cubit/auth_cubit.dart';
import 'package:triply/features/common/auth/data/auth_repository.dart';
import 'package:triply/features/tourist/community/data/community_posts_repository.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';
import 'package:triply/features/tourist/user_profile/cubit/profile_cubit.dart';
import 'package:triply/features/tourist/user_profile/cubit/profile_details_cubit.dart';
import 'package:triply/features/tourist/user_profile/cubit/profile_posts_cubit.dart';
import 'package:triply/features/tourist/user_profile/view/profile_screen.dart';
import 'package:triply/features/tourist/user_profile/view/settings_screen.dart';
import 'package:triply/features/tour_guide/profile_tg/view/guide_settings_screen.dart';

void main() {
  testWidgets('Profile screen uses dark colors without changing light colors', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final cubits = _ProfileCubits(authRepository);
    addTearDown(cubits.close);

    await tester.pumpWidget(
      _app(ThemeMode.dark, const ProfileScreen(), cubits),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('My profile')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester.widget<Text>(find.text('Nadia')).style?.color,
      AppThemeDark.homeGuideName,
    );
    expect(
      tester.widget<Text>(find.text('Bio')).style?.color,
      AppThemeDark.homeSectionTitle,
    );

    await tester.pumpWidget(
      _app(ThemeMode.light, const ProfileScreen(), cubits),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      Colors.white,
    );
    expect(
      tester.widget<Text>(find.text('My profile')).style?.color,
      const Color(0xFF263A40),
    );
    expect(
      tester.widget<Text>(find.text('Nadia')).style?.color,
      const Color(0xFF263A40),
    );
  });

  testWidgets('Settings uses dark palette and preserves light palette', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final authCubit = _authCubit(authRepository);
    final profileCubit = ProfileCubit();
    final themeCubit = ThemeCubit();
    addTearDown(authCubit.close);
    addTearDown(profileCubit.close);
    addTearDown(themeCubit.close);

    await tester.pumpWidget(
      _settingsApp(ThemeMode.dark, authCubit, profileCubit, themeCubit),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Settings')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester.widget<Text>(find.text('Account')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester.widget<Text>(find.text('Dark mode')).style?.color,
      AppThemeDark.homeGuideName,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.dark_mode_outlined)).color,
      AppThemeDark.homeSeeAll,
    );

    await tester.pumpWidget(
      _settingsApp(ThemeMode.light, authCubit, profileCubit, themeCubit),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    expect(
      tester.widget<Text>(find.text('Settings')).style?.color,
      const Color(0xFF263A40),
    );
    expect(
      tester.widget<Text>(find.text('Dark mode')).style?.color,
      AppColors.guidesName,
    );
  });

  testWidgets('Guide settings toggle is readable in dark mode', (tester) async {
    final themeCubit = ThemeCubit();
    addTearDown(themeCubit.close);

    await tester.pumpWidget(_guideSettingsApp(ThemeMode.dark, themeCubit));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Settings')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester.widget<Text>(find.text('Dark mode')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(find.byType(Switch), findsOneWidget);

    await tester.pumpWidget(_guideSettingsApp(ThemeMode.light, themeCubit));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    expect(
      tester.widget<Text>(find.text('Settings')).style?.color,
      AppColors.title,
    );
  });
}

Widget _app(ThemeMode mode, Widget home, _ProfileCubits cubits) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: cubits.auth),
      BlocProvider.value(value: cubits.profile),
      BlocProvider.value(value: cubits.theme),
      BlocProvider.value(value: cubits.details),
      BlocProvider.value(value: cubits.posts),
    ],
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: mode,
      home: home,
    ),
  );
}

Widget _settingsApp(
  ThemeMode mode,
  AuthCubit auth,
  ProfileCubit profile,
  ThemeCubit theme,
) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: auth),
      BlocProvider.value(value: profile),
      BlocProvider.value(value: theme),
    ],
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: mode,
      home: const SettingsScreen(),
    ),
  );
}

Widget _guideSettingsApp(ThemeMode mode, ThemeCubit theme) {
  return BlocProvider.value(
    value: theme,
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: mode,
      home: const GuideSettingsScreen(),
    ),
  );
}

AuthCubit _authCubit(AuthRepository repository) => AuthCubit(
  authRepository: repository,
  profileHeal: ProfileSelfHealService(),
);

class _ProfileCubits {
  _ProfileCubits(AuthRepository repository)
    : auth = _authCubit(repository),
      profile = ProfileCubit(),
      theme = ThemeCubit(),
      details = ProfileDetailsCubit(
        userId: 'profile-test',
        authRepository: repository,
      ),
      posts = ProfilePostsCubit(
        postsRepository: _FakeCommunityPostsRepository(),
      );

  final AuthCubit auth;
  final ProfileCubit profile;
  final ThemeCubit theme;
  final ProfileDetailsCubit details;
  final ProfilePostsCubit posts;

  Future<void> close() async {
    await auth.close();
    await profile.close();
    await theme.close();
    await details.close();
    await posts.close();
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  User? get currentUser => null;

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async => {
    'displayName': 'Nadia',
    'city': 'Cairo',
    'bio': 'Traveler',
  };

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
