import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/tourist/booking/view/booking_screen.dart';
import 'package:triply/features/tourist/booking/widgets/booking_widgets.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';

void main() {
  const guide = Guide(
    id: 'guide-1',
    name: 'Nadia Ahmed',
    specialty: 'Egyptologist',
    avatarUrl: '',
    languages: ['English'],
    rating: 4.9,
    reviewCount: 18,
    pricePerHour: 500,
    currency: 'EGP',
  );

  testWidgets(
    'private booking page adapts dark mode and preserves light mode',
    (tester) async {
      await tester.pumpWidget(_bookingApp(ThemeMode.dark, guide));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppThemeDark.backgroundPrimary,
      );
      expect(
        tester.widget<Text>(find.text('Book Private Guide')).style?.color,
        AppThemeDark.homeSectionTitle,
      );
      expect(
        tester.widget<Text>(find.text('Date & Time')).style?.color,
        AppThemeDark.homeSeeAll,
      );
      expect(
        tester.widget<Text>(find.text('Nadia Ahmed')).style?.color,
        AppThemeDark.homeGuideSecondary,
      );

      await tester.tap(find.text('9:00 AM'));
      await tester.pump();
      expect(
        tester.widget<Text>(find.text('9:00 AM')).style?.color,
        AppThemeDark.backgroundPrimary,
      );

      await tester.pumpWidget(_bookingApp(ThemeMode.light, guide));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        Colors.white,
      );
      expect(
        tester.widget<Text>(find.text('Book Private Guide')).style?.color,
        AppColors.title,
      );
      expect(
        tester.widget<Text>(find.text('9:00 AM')).style?.color,
        Colors.white,
      );
    },
  );

  testWidgets('booking step widgets use dark surfaces and readable text', (
    tester,
  ) async {
    await tester.pumpWidget(_bookingWidgetsApp(ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('11:00 AM')).style?.color,
      AppThemeDark.textSecondary,
    );
    expect(
      tester.widget<Text>(find.text('Hotel Lobby')).style?.color,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byType(SummaryRow),
              matching: find.text('2'),
            ),
          )
          .style
          ?.color,
      AppThemeDark.homeGuideName,
    );

    await tester.pumpWidget(_bookingWidgetsApp(ThemeMode.light));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('11:00 AM')).style?.color,
      const Color(0xFF0E5261),
    );
    expect(
      tester.widget<Text>(find.text('Hotel Lobby')).style?.color,
      Colors.white,
    );
  });
}

Widget _bookingApp(ThemeMode mode, Guide guide) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: BookingScreen(guide: guide),
  );
}

Widget _bookingWidgetsApp(ThemeMode mode) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: const Scaffold(
      body: Column(
        children: [
          BookingStepper(stepIndex: 1),
          SelectableChip(label: '11:00 AM', selected: false),
          MeetingPointTile(label: 'Hotel Lobby', selected: true),
          SummaryRow(label: 'Travelers', value: '2'),
        ],
      ),
    ),
  );
}
