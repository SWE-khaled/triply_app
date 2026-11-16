import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/features/tourist/trips/cubit/trips_cubit.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

void main() {
  test(
    'starts loading, then retains Firestore trips for the session',
    () async {
      final response = Completer<List<PublicTrip>?>();
      final repository = _FakePublicTripsRepository(() => response.future);
      final cubit = TripsCubit(repository: repository);

      expect(cubit.state.isLoading, isTrue);
      expect(repository.readCount, 1);

      response.complete([_trip(id: 'approved-1')]);
      await cubit.stream.firstWhere((state) => !state.isLoading);

      expect(cubit.state.trips.single.id, 'approved-1');
      cubit.selectTab(TripStatus.completed);
      expect(cubit.state.trips, isEmpty);
      cubit.selectTab(TripStatus.upcoming);
      expect(cubit.state.trips.single.id, 'approved-1');

      await cubit.load();
      expect(repository.readCount, 1);
      await cubit.close();
    },
  );

  test('successful empty query is not treated as an error', () async {
    final cubit = TripsCubit(
      repository: _FakePublicTripsRepository(() async => const []),
    );

    await cubit.stream.firstWhere((state) => !state.isLoading);

    expect(cubit.state.trips, isEmpty);
    expect(cubit.state.error, isNull);
    await cubit.close();
  });

  test('network failure shows the shared connection message', () async {
    final cubit = TripsCubit(
      repository: _FakePublicTripsRepository(
        () => Future<List<PublicTrip>?>.error(const SocketException('offline')),
      ),
    );

    await cubit.stream.firstWhere((state) => state.error != null);

    expect(
      cubit.state.error,
      'Unable to load data. Please check your internet connection and try again.',
    );
    expect(cubit.state.isLoading, isFalse);
    await cubit.close();
  });
}

PublicTrip _trip({required String id}) => PublicTrip(
  id: id,
  guideId: 'guide-1',
  title: 'Cairo tour',
  location: 'Cairo',
  dateLabel: 'Tomorrow',
  durationLabel: '4 hours',
  imageUrl: 'https://example.test/trip.jpg',
  guideName: 'Nadia',
  tag: 'historical',
  priceEgp: 1000,
  capacity: 8,
  bookedSeats: 2,
);

class _FakePublicTripsRepository extends PublicTripsRepository {
  _FakePublicTripsRepository(this.fetch);

  final Future<List<PublicTrip>?> Function() fetch;
  int readCount = 0;

  @override
  Future<List<PublicTrip>?> fetchApprovedTrips({bool rethrowOnError = false}) {
    readCount++;
    return fetch();
  }
}
