import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/chat/widgets/message_guide_button.dart';
import 'package:triply/features/tourist/guides/model/trip.dart';
import 'package:triply/features/tourist/guides/widgets/trip_card.dart';

void main() {
  const trip = Trip(
    id: 'trip-1',
    guideId: 'guide-1',
    title: 'Nile tour',
    imageUrl: '',
    dateLabel: 'Tomorrow',
    durationLabel: '3 hours',
    price: 500,
    currency: 'EGP',
  );

  testWidgets('guide profile trip and message cards adapt to dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(_app(ThemeMode.dark, trip));

    final tripCard = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(TripCard),
            matching: find.byType(Container),
          )
          .first,
    );
    final tripDecoration = tripCard.decoration! as BoxDecoration;
    expect(tripDecoration.color, AppThemeDark.homeGuideSurface);
    expect(
      (tripDecoration.border! as Border).top.color,
      AppThemeDark.homeGuideBorder,
    );
    expect(
      tester.widget<Text>(find.text('Nile tour')).style?.color,
      AppThemeDark.homeGuideName,
    );

    final message = tester.widget<OutlinedButton>(
      find.byKey(MessageGuideButton.buttonKey),
    );
    expect(
      message.style?.foregroundColor?.resolve({}),
      AppThemeDark.homeSeeAll,
    );
    expect(message.style?.side?.resolve({})?.color, AppThemeDark.homeSeeAll);

    await tester.pumpWidget(_app(ThemeMode.light, trip));
    await tester.pumpAndSettle();

    final lightTripCard = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(TripCard),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (lightTripCard.decoration! as BoxDecoration).color,
      const Color(0xFFFAF5EC),
    );
    expect(
      tester.widget<Text>(find.text('Nile tour')).style?.color,
      AppColors.title,
    );

    final lightMessage = tester.widget<OutlinedButton>(
      find.byKey(MessageGuideButton.buttonKey),
    );
    expect(lightMessage.style?.foregroundColor?.resolve({}), AppColors.primary);
  });
}

Widget _app(ThemeMode mode, Trip trip) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: Scaffold(
      body: Column(
        children: [
          TripCard(trip: trip),
          MessageGuideButton(
            guideId: 'guide-1',
            guideName: 'Nadia',
            expanded: true,
            isTourist: true,
          ),
        ],
      ),
    ),
  );
}
