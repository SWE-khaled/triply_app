import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/core/widgets/circle_back_button.dart';
import 'package:triply/features/tourist/trips/cubit/trips_cubit.dart';
import 'package:triply/features/tourist/trips/view/trips_screen.dart';

void main() {
  testWidgets(
    'Trips back button adapts to dark mode and preserves light mode',
    (tester) async {
      final cubit = TripsCubit(repository: _FakePublicTripsRepository());
      addTearDown(cubit.close);

      await tester.pumpWidget(_app(ThemeMode.dark, cubit));
      await tester.pumpAndSettle();

      final darkButton = tester.widget<CircleBackButton>(
        find.byType(CircleBackButton),
      );
      expect(darkButton.backgroundColor, AppThemeDark.surfaceElevated);
      expect(darkButton.iconColor, AppThemeDark.iconPrimary);

      await tester.pumpWidget(_app(ThemeMode.light, cubit));
      await tester.pumpAndSettle();

      final lightButton = tester.widget<CircleBackButton>(
        find.byType(CircleBackButton),
      );
      expect(lightButton.backgroundColor, Colors.white);
      expect(lightButton.iconColor, Colors.black);
    },
  );
}

Widget _app(ThemeMode mode, TripsCubit cubit) {
  return BlocProvider.value(
    value: cubit,
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: mode,
      home: const TripsScreen(),
    ),
  );
}

class _FakePublicTripsRepository extends PublicTripsRepository {
  @override
  Future<List<PublicTrip>?> fetchApprovedTrips({
    bool rethrowOnError = false,
  }) async => const [];
}
