import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/features/tourist/trip_details/cubit/trip_details_cubit.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

void main() {
  test('uses the trip card details when the Firestore read fails', () async {
    final cubit = TripDetailsCubit(repository: _FailingTripsRepository());
    const trip = Trip(
      id: 'booked-trip',
      title: 'Cairo history walk',
      dateLabel: 'Tomorrow',
      guideName: 'Nadia',
      guideId: 'guide-1',
      guideAvatarUrl: 'https://example.test/guide.jpg',
      peopleCount: 2,
      priceEgp: 1200,
      imageUrl: 'https://example.test/trip.jpg',
      status: TripStatus.upcoming,
      category: 'historical',
      capacity: 8,
    );

    await cubit.loadTrip(trip);

    expect(cubit.state, isA<TripDetailsSuccess>());
    final details = (cubit.state as TripDetailsSuccess).details;
    expect(details.tripId, trip.id);
    expect(details.title, trip.title);
    expect(details.guideName, trip.guideName);
    expect(details.guideId, trip.guideId);
    expect(details.guideAvatarUrl, trip.guideAvatarUrl);
    expect(details.imageUrl, trip.imageUrl);
    await cubit.close();
  });

  test(
    'uses the profile avatar when the trip document has no guide avatar',
    () async {
      final cubit = TripDetailsCubit(
        repository: _TripsRepository(
          PublicTrip(
            id: 'profile-trip',
            guideId: '',
            title: 'Cairo history walk',
            location: 'Cairo',
            dateLabel: 'Tomorrow',
            durationLabel: '4 hours',
            imageUrl: 'https://example.test/trip.jpg',
            guideName: 'Nadia',
            tag: 'history',
            priceEgp: 1200,
            capacity: 8,
            bookedSeats: 2,
          ),
        ),
      );
      const trip = Trip(
        id: 'profile-trip',
        title: 'Cairo history walk',
        dateLabel: 'Tomorrow',
        guideName: 'Nadia',
        guideId: 'guide-1',
        guideAvatarUrl: 'https://example.test/guide.jpg',
        peopleCount: 2,
        priceEgp: 1200,
        imageUrl: 'https://example.test/trip.jpg',
        status: TripStatus.upcoming,
        category: 'historical',
        capacity: 8,
      );

      await cubit.loadTrip(trip);

      expect(cubit.state, isA<TripDetailsSuccess>());
      final details = (cubit.state as TripDetailsSuccess).details;
      expect(details.guideId, trip.guideId);
      expect(details.guideAvatarUrl, trip.guideAvatarUrl);
      await cubit.close();
    },
  );
}

class _FailingTripsRepository extends PublicTripsRepository {
  @override
  Future<PublicTrip?> fetchTrip(
    String tripId, {
    bool rethrowOnError = false,
  }) async {
    if (rethrowOnError) throw const SocketException('offline');
    return null;
  }
}

class _TripsRepository extends PublicTripsRepository {
  _TripsRepository(this.trip);

  final PublicTrip trip;

  @override
  Future<PublicTrip?> fetchTrip(
    String tripId, {
    bool rethrowOnError = false,
  }) async => trip;
}
