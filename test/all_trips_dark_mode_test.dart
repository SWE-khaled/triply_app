import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/core/widgets/circle_back_button.dart';
import 'package:triply/features/tourist/all_trips/view/all_trips_screen.dart';
import 'package:triply/features/tourist/popular/cubit/popular_cubit.dart';
import 'package:triply/features/tourist/trips/widgets/trip_card.dart';

void main() {
  testWidgets('All Trips renders its surfaces and filters in dark mode', (
    tester,
  ) async {
    final cubit = PopularCubit(repository: _FakePublicTripsRepository());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const AllTripsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<Text>(find.text('All Trips')).style?.color,
      AppThemeDark.homeSectionTitle,
    );
    final darkBackButton = tester.widget<CircleBackButton>(
      find.byType(CircleBackButton),
    );
    expect(darkBackButton.backgroundColor, AppThemeDark.surfaceElevated);
    expect(darkBackButton.iconColor, AppThemeDark.iconPrimary);
    expect(find.byType(TripCard), findsOneWidget);

    final allChip = tester.widget<Container>(
      find
          .ancestor(of: find.text('All'), matching: find.byType(Container))
          .first,
    );
    expect(
      (allChip.decoration! as BoxDecoration).color,
      AppThemeDark.homeSeeAll,
    );

    final tripCard = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(TripCard),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (tripCard.decoration! as BoxDecoration).color,
      AppThemeDark.surfaceDefault,
    );
    expect(find.text('Giza trip'), findsOneWidget);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
          home: const AllTripsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppColors.background,
    );
    expect(
      tester.widget<Text>(find.text('All Trips')).style?.color,
      AppColors.primary,
    );
    final lightBackButton = tester.widget<CircleBackButton>(
      find.byType(CircleBackButton),
    );
    expect(lightBackButton.backgroundColor, Colors.white);
    expect(lightBackButton.iconColor, Colors.black);
  });
}

class _FakePublicTripsRepository implements PublicTripsRepository {
  @override
  Future<List<PublicTrip>?> fetchApprovedTrips({
    bool rethrowOnError = false,
  }) async => const [
    PublicTrip(
      id: 'trip-1',
      guideId: 'guide-1',
      title: 'Giza trip',
      location: 'Giza',
      dateLabel: 'Tomorrow',
      durationLabel: '2 hours',
      imageUrl: 'https://example.test/cover.png',
      guideName: 'Local guide',
      tag: 'Historical',
      priceEgp: 500,
      capacity: 10,
      bookedSeats: 1,
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
