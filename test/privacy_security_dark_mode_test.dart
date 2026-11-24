import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/core/widgets/circle_back_button.dart';
import 'package:triply/features/tourist/user_profile/view/privacy_security_screen.dart';

void main() {
  testWidgets(
    'Privacy & security supports dark mode without changing light colors',
    (tester) async {
      await tester.pumpWidget(_app(ThemeMode.dark));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppThemeDark.backgroundPrimary,
      );
      expect(
        tester.widget<Text>(find.text('Privacy & security')).style?.color,
        AppThemeDark.homeSectionTitle,
      );
      final darkBackButton = tester.widget<CircleBackButton>(
        find.byType(CircleBackButton),
      );
      expect(darkBackButton.backgroundColor, AppThemeDark.surfaceElevated);
      expect(darkBackButton.iconColor, AppThemeDark.iconPrimary);
      expect(
        tester.widget<Text>(find.text('Reset password')).style?.color,
        AppThemeDark.homeGuideName,
      );
      expect(find.text('Biometric login'), findsNothing);
      expect(
        _containersWithColor(tester, AppThemeDark.homeGuideSurface),
        hasLength(1),
      );

      await tester.pumpWidget(_app(ThemeMode.light));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        Colors.white,
      );
      expect(
        tester.widget<Text>(find.text('Privacy & security')).style?.color,
        AppColors.textDark,
      );
      final lightBackButton = tester.widget<CircleBackButton>(
        find.byType(CircleBackButton),
      );
      expect(lightBackButton.backgroundColor, Colors.white);
      expect(lightBackButton.iconColor, Colors.black);
      expect(
        tester.widget<Text>(find.text('Reset password')).style?.color,
        AppColors.guidesName,
      );
      expect(find.text('Biometric login'), findsNothing);
      expect(
        _containersWithColor(tester, Colors.grey.withValues(alpha: .1)),
        hasLength(1),
      );
    },
  );
}

List<Container> _containersWithColor(WidgetTester tester, Color color) {
  return tester
      .widgetList<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration && decoration.color == color;
        }),
      )
      .toList();
}

Widget _app(ThemeMode mode) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: const PrivacySecurityScreen(),
  );
}
