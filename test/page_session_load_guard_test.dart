import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/public_guide.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_guides_repository.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/features/tourist/guides/cubit/guides_cubit.dart';
import 'package:triply/features/tourist/popular/cubit/popular_cubit.dart';

/// App-session scoped page Cubits must read once and keep the result.
///
/// These tests pin the two guards that stop navigation from starting a new
/// loading cycle: a successful state is never re-read, and a retry after an
/// error does not emit a second loading state (which would restart the
/// shimmer).
void main() {
  group('GuidesCubit session load', () {
    test('navigation re-reads nothing after a successful load', () async {
      final repository = _CountingGuidesRepository([_guide()]);
      final cubit = GuidesCubit(repository: repository);

      await cubit.stream.firstWhere((state) => state is GuidesSuccess);
      expect(repository.calls, 1);

      // Visiting the list again would call load() from a new screen.
      unawaited(cubit.load());
      await Future<void>.delayed(Duration.zero);

      expect(repository.calls, 1);
      expect(cubit.state, isA<GuidesSuccess>());
      await cubit.close();
    });

    test('retry after an error keeps the error until it resolves', () async {
      final repository = _CountingGuidesRepository(const [], shouldThrow: true);
      final cubit = GuidesCubit(repository: repository);

      final failed = await cubit.stream.firstWhere(
        (state) => state is GuidesError,
      );
      expect((failed as GuidesError).error, isNot(pageNetworkErrorMessage));

      repository.shouldThrow = false;
      final retry = cubit.load();

      // No GuidesLoading in between: the error view (and not the skeleton)
      // stays on screen while the retry is running.
      expect(cubit.state, isA<GuidesError>());
      await retry;

      expect(repository.calls, 2);
      expect(cubit.state, isA<GuidesSuccess>());
      await cubit.close();
    });

    test('a network failure uses the shared connection message', () async {
      final cubit = GuidesCubit(
        repository: _CountingGuidesRepository(
          const [],
          shouldThrow: true,
          error: Exception('network-request-failed'),
        ),
      );

      final failed = await cubit.stream.firstWhere(
        (state) => state is GuidesError,
      );

      expect((failed as GuidesError).error, pageNetworkErrorMessage);
      await cubit.close();
    });
  });

  group('PopularCubit session load', () {
    test('navigation re-reads nothing after a successful load', () async {
      final repository = _CountingTripsRepository([_trip()]);
      final cubit = PopularCubit(repository: repository);

      await cubit.stream.firstWhere((state) => state is PopularSuccess);
      expect(repository.calls, 1);

      unawaited(cubit.load());
      await Future<void>.delayed(Duration.zero);

      expect(repository.calls, 1);
      expect(cubit.state, isA<PopularSuccess>());
      await cubit.close();
    });

    test('retry after an error keeps the error until it resolves', () async {
      final repository = _CountingTripsRepository([], shouldThrow: true);
      final cubit = PopularCubit(repository: repository);

      await cubit.stream.firstWhere((state) => state is PopularError);

      repository.shouldThrow = false;
      final retry = cubit.load();
      expect(cubit.state, isA<PopularError>());
      await retry;

      expect(repository.calls, 2);
      expect(cubit.state, isA<PopularSuccess>());
      await cubit.close();
    });

    test('a network failure uses the shared connection message', () async {
      final cubit = PopularCubit(
        repository: _CountingTripsRepository(
          [],
          shouldThrow: true,
          error: Exception('network-request-failed'),
        ),
      );

      final failed = await cubit.stream.firstWhere(
        (state) => state is PopularError,
      );

      expect((failed as PopularError).error, pageNetworkErrorMessage);
      await cubit.close();
    });
  });
}

PublicGuide _guide() => const PublicGuide(
  id: 'guide-uid',
  name: 'Nadia',
  specialty: 'Egyptologist',
  avatarUrl: '',
  coverUrl: '',
  location: 'Cairo',
  about: '',
  languages: ['English'],
  rating: 4.9,
  reviewCount: 18,
  pricePerHour: 125,
  currency: 'EGP',
  isApproved: true,
);

PublicTrip _trip() => const PublicTrip(
  id: 'trip-id',
  guideId: 'guide-uid',
  title: 'Cairo walk',
  location: 'Cairo',
  dateLabel: '',
  durationLabel: '2h',
  imageUrl: '',
  guideName: 'Nadia',
  tag: 'historical',
  priceEgp: 100,
  capacity: 10,
  bookedSeats: 0,
);

class _CountingGuidesRepository extends PublicGuidesRepository {
  _CountingGuidesRepository(
    this.guides, {
    this.shouldThrow = false,
    this.error = const FormatException('Guide read failed.'),
  });

  final List<PublicGuide> guides;
  bool shouldThrow;
  final Object error;
  int calls = 0;

  @override
  Future<List<PublicGuide>> fetchApprovedGuides() async {
    calls++;
    if (shouldThrow) throw error;
    return guides;
  }
}

class _CountingTripsRepository extends PublicTripsRepository {
  _CountingTripsRepository(
    this.trips, {
    this.shouldThrow = false,
    this.error = const FormatException('Trip read failed.'),
  });

  final List<PublicTrip> trips;
  bool shouldThrow;
  final Object error;
  int calls = 0;

  @override
  Future<List<PublicTrip>?> fetchApprovedTrips({
    bool rethrowOnError = false,
  }) async {
    calls++;
    if (shouldThrow) throw error;
    return trips;
  }
}
