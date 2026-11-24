import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/tourist/search/view/search_screen.dart';
import 'package:triply/features/tourist/search/widget/destination_row.dart';

void main() {
  testWidgets('search screen and results adapt to dark and light modes', (
    tester,
  ) async {
    await tester.pumpWidget(_app(ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.fillColor,
      AppThemeDark.surfaceDefault,
    );
    expect(
      tester.widget<Text>(find.text('Recent Searches')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester.widget<Text>(find.text('Clear all')).style?.color,
      AppThemeDark.homeGuidePrice,
    );

    await tester.enterText(find.byType(TextField), 'Giza Pyramids');
    await tester.pumpAndSettle();

    final resultRow = find.ancestor(
      of: find.text('Giza Pyramids & Sphinx'),
      matching: find.byType(DestinationRow),
    );
    expect(resultRow, findsOneWidget);
    final resultCard = tester.widget<Container>(
      find.descendant(of: resultRow, matching: find.byType(Container)).first,
    );
    expect(
      (resultCard.decoration! as BoxDecoration).color,
      AppThemeDark.homeGuideSurface,
    );
    expect(
      tester.widget<Text>(find.text('Giza Pyramids & Sphinx')).style?.color,
      AppThemeDark.homeGuideName,
    );

    await tester.pumpWidget(_app(ThemeMode.light));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.fillColor,
      AppColors.inputFill,
    );
    expect(
      tester.widget<Text>(find.text('Giza Pyramids & Sphinx')).style?.color,
      AppColors.primaryTeal,
    );
    final lightResultCard = tester.widget<Container>(
      find.descendant(of: resultRow, matching: find.byType(Container)).first,
    );
    expect(
      (lightResultCard.decoration! as BoxDecoration).color,
      const Color(0xFFF7F7F7),
    );
  });

  testWidgets('search empty state has readable dark-mode colors', (
    tester,
  ) async {
    await tester.pumpWidget(_app(ThemeMode.dark));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'not-a-destination');
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('No results found')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester
          .widget<Text>(find.text('Try a different keyword or filter'))
          .style
          ?.color,
      AppThemeDark.homeGuideSecondary,
    );
  });
}

Widget _app(ThemeMode mode) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: const SearchScreen(),
  );
}
