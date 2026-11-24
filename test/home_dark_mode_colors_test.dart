import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/tourist/home/model/guide.dart';
import 'package:triply/features/tourist/home/widget/guide_tile.dart';
import 'package:triply/features/tourist/home/widget/section_header.dart';

void main() {
  testWidgets('home section header uses readable dark-mode colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Scaffold(body: SectionHeader(title: 'Popular Places')),
      ),
    );

    expect(
      tester.widget<Text>(find.text('Popular Places')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester.widget<Text>(find.text('See all')).style?.color,
      AppThemeDark.homeSeeAll,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.chevron_right)).color,
      AppThemeDark.homeSeeAll,
    );
  });

  testWidgets('local guide card uses the dark Triply palette', (tester) async {
    const guide = Guide(
      id: 'guide-1',
      name: 'Mariam Ahmed',
      specialty: 'Cairo history',
      avatarUrl: 'https://example.test/avatar.png',
      rating: 0,
      reviewCount: 0,
      pricePerHour: 500,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Scaffold(body: GuideTile(guide: guide)),
      ),
    );

    final card = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(GuideTile),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.color, AppThemeDark.homeGuideSurface);
    expect(
      (decoration.border! as Border).top.color,
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
    expect(
      tester.widget<Text>(find.text('From EGP 500')).style?.color,
      AppThemeDark.homeGuidePrice,
    );
    expect(
      tester.widget<Text>(find.text('Cairo history')).style?.color,
      AppThemeDark.homeGuideSecondary,
    );
  });
}
