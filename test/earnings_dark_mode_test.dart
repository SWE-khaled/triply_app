import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/tour_guide/earnings_tg/view/earnings_screen.dart';

void main() {
  testWidgets('Earnings screen uses dark colors and preserves light colors', (
    tester,
  ) async {
    await tester.pumpWidget(_app(ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Recent activity')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      _withdrawButton(tester).decoration,
      isA<BoxDecoration>().having(
        (decoration) => decoration.color,
        'background color',
        AppThemeDark.surfaceElevated,
      ),
    );

    await tester.pumpWidget(_app(ThemeMode.light));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    expect(
      tester.widget<Text>(find.text('Recent activity')).style?.color,
      AppColors.priceTeal,
    );
    expect(
      _withdrawButton(tester).decoration,
      isA<BoxDecoration>().having(
        (decoration) => decoration.color,
        'background color',
        Colors.white,
      ),
    );
  });
}

Container _withdrawButton(WidgetTester tester) {
  return tester.widget<Container>(
    find
        .ancestor(
          of: find.text('Withdraw earnings'),
          matching: find.byType(Container),
        )
        .first,
  );
}

Widget _app(ThemeMode mode) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: const EarningsScreen(),
  );
}
