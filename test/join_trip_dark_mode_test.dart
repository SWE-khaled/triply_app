import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/tourist/booking_public/cubit/booking_public_cubit.dart';
import 'package:triply/features/tourist/booking_public/view/booking_public_screen.dart';
import 'package:triply/features/tourist/booking_public/widgets/booking_summary_card.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

void main() {
  const trip = Trip(
    id: 'join-trip-test',
    title: 'Nile evening trip',
    dateLabel: 'Tomorrow',
    guideName: 'Nadia Ahmed',
    peopleCount: 2,
    priceEgp: 800,
    imageUrl: '',
    status: TripStatus.upcoming,
    category: 'historical',
    capacity: 6,
  );

  testWidgets('Join Trip and its booking details use the dark palette', (
    tester,
  ) async {
    final cubit = BookingPublicCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_app(ThemeMode.dark, cubit, trip));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Join Trip')).style?.color,
      AppThemeDark.homeSectionTitle,
    );

    final summaryCard = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(BookingSummaryCard),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (summaryCard.decoration! as BoxDecoration).color,
      AppThemeDark.homeGuideSurface,
    );
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byType(BookingSummaryCard),
              matching: find.text('Nile evening trip'),
            ),
          )
          .style
          ?.color,
      Colors.white,
    );

    expect(
      tester.widget<Text>(find.text('Number of Seats')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.add)).color,
      AppThemeDark.homeSeeAll,
    );
    expect(
      tester.widget<Text>(find.text('Price Breakdown').first).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.ancestor(
              of: find.textContaining('Confirm & Pay'),
              matching: find.byType(ElevatedButton),
            ),
          )
          .style
          ?.backgroundColor
          ?.resolve({}),
      AppThemeDark.homeSeeAll,
    );
  });

  testWidgets('Join Trip retains the existing light-mode colors', (
    tester,
  ) async {
    final cubit = BookingPublicCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_app(ThemeMode.light, cubit, trip));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppColors.background,
    );
    expect(
      tester.widget<Text>(find.text('Join Trip')).style?.color,
      AppColors.title,
    );
    expect(
      tester.widget<Text>(find.text('Number of Seats')).style?.color,
      AppColors.title,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.ancestor(
              of: find.textContaining('Confirm & Pay'),
              matching: find.byType(ElevatedButton),
            ),
          )
          .style
          ?.backgroundColor
          ?.resolve({}),
      AppColors.tabSelectedBg,
    );
  });
}

Widget _app(ThemeMode mode, BookingPublicCubit cubit, Trip trip) {
  return BlocProvider.value(
    value: cubit,
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: mode,
      home: BookingPublicScreen(trip: trip),
    ),
  );
}
