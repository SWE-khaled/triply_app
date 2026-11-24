import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/public_guide.dart';
import 'package:triply/core/data/repositories/public_guides_repository.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/tourist/guides/cubit/guides_cubit.dart';
import 'package:triply/features/tourist/guides/view/guides_list_screen.dart';
import 'package:triply/features/tourist/guides/widgets/guide_card.dart';

void main() {
  testWidgets('All Guides uses dark palette and preserves light palette', (
    tester,
  ) async {
    final cubit = GuidesCubit(repository: _FakePublicGuidesRepository());
    addTearDown(cubit.close);

    await tester.pumpWidget(_app(cubit, ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('All Guides')).style?.color,
      AppThemeDark.homeSectionTitle,
    );

    final search = tester.widget<TextField>(find.byType(TextField));
    expect(search.decoration?.fillColor, AppThemeDark.surfaceDefault);

    final card = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(GuideCard),
            matching: find.byType(Container),
          )
          .first,
    );
    final cardDecoration = card.decoration! as BoxDecoration;
    expect(cardDecoration.color, AppThemeDark.homeGuideSurface);
    expect(
      (cardDecoration.border! as Border).top.color,
      AppThemeDark.homeGuideBorder,
    );
    expect(
      tester.widget<Text>(find.text('Mariam Ahmed')).style?.color,
      AppThemeDark.homeGuideName,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.verified)).color,
      AppThemeDark.homeGuideVerified,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.star)).color,
      AppThemeDark.homeGuideRating,
    );

    await tester.pumpWidget(_app(cubit, ThemeMode.light));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    expect(
      tester.widget<Text>(find.text('All Guides')).style?.color,
      Colors.black,
    );
    expect(
      tester.widget<Text>(find.text('Mariam Ahmed')).style?.color,
      const Color(0xFF0E5261),
    );
  });
}

Widget _app(GuidesCubit cubit, ThemeMode mode) {
  return BlocProvider.value(
    value: cubit,
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: mode,
      home: const GuidesListScreen(),
    ),
  );
}

class _FakePublicGuidesRepository implements PublicGuidesRepository {
  @override
  Future<List<PublicGuide>> fetchApprovedGuides() async => const [
    PublicGuide(
      id: 'guide-1',
      name: 'Mariam Ahmed',
      specialty: 'Cairo history',
      avatarUrl: 'https://example.test/avatar.png',
      coverUrl: '',
      location: 'Cairo',
      about: '',
      languages: ['English'],
      rating: 4.8,
      reviewCount: 12,
      pricePerHour: 500,
      currency: 'EGP',
      isApproved: true,
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
