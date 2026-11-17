import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/models/tourist_booking.dart';
import 'package:triply/core/data/repositories/booking_repository.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/features/tourist/my_trips/cubit/my_trips_cubit.dart';

void main() {
  test(
    'a successful empty bookings read produces the empty success state',
    () async {
      final cubit = MyTripsCubit(
        bookingRepository: _FakeBookingRepository(bookings: const []),
        tripsRepository: _FakeTripsRepository(),
      );

      final state = await cubit.stream.firstWhere(
        (state) => state is MyTripsSuccess,
      );

      expect((state as MyTripsSuccess).trips, isEmpty);
      await cubit.close();
    },
  );

  test('a network read failure produces the connection error state', () async {
    final cubit = MyTripsCubit(
      bookingRepository: _FakeBookingRepository(
        error: const SocketException('offline'),
      ),
      tripsRepository: _FakeTripsRepository(),
    );

    final state = await cubit.stream.firstWhere(
      (state) => state is MyTripsError,
    );

    expect(
      (state as MyTripsError).error,
      'Unable to load data. Please check your internet connection and try again.',
    );
    await cubit.close();
  });

  test(
    'refreshing loaded bookings does not emit the initial loading state',
    () async {
      final repository = _FakeBookingRepository(bookings: const []);
      final cubit = MyTripsCubit(
        bookingRepository: repository,
        tripsRepository: _FakeTripsRepository(),
      );
      final emissions = <MyTripsState>[];
      final loaded = Completer<void>();
      final subscription = cubit.stream.listen((state) {
        emissions.add(state);
        if (state is MyTripsSuccess && !loaded.isCompleted) loaded.complete();
      });
      await loaded.future;
      await Future<void>.delayed(Duration.zero);
      emissions.clear();
      await cubit.load();

      expect(repository.readCount, 2);
      expect(emissions.whereType<MyTripsLoading>(), isEmpty);
      expect(cubit.state, isA<MyTripsSuccess>());
      await subscription.cancel();
      await cubit.close();
    },
  );

  test(
    'refresh reloads bookings added after the list was first opened',
    () async {
      final repository = _FakeBookingRepository(bookings: const []);
      final tripsRepository = _FakeTripsRepository(
        trips: [
          PublicTrip(
            id: 'public-trip',
            guideId: 'guide-uid',
            title: 'Public tour',
            location: 'Cairo',
            dateLabel: 'Tomorrow',
            durationLabel: '4 hours',
            imageUrl: 'https://example.test/trip.jpg',
            guideName: 'Nadia',
            tag: 'history',
            priceEgp: 500,
            capacity: 8,
            bookedSeats: 1,
          ),
        ],
      );
      final cubit = MyTripsCubit(
        bookingRepository: repository,
        tripsRepository: tripsRepository,
      );

      await cubit.stream.firstWhere((state) => state is MyTripsSuccess);
      repository.bookings = [
        TouristBooking.fromDocument({
          'tripId': '',
          'is_private': true,
          'guideId': 'guide-uid',
          'guideName': 'Nadia',
          'tour_title': 'Private tour with Nadia',
          'seats': 2,
          'totalPrice': 1200,
          'status': 'confirmed',
          'paymentStatus': 'paid',
        }, 'new-private-booking'),
        TouristBooking.fromDocument({
          'tripId': 'public-trip',
          'tour_title': 'Public tour',
          'seats': 1,
          'totalPrice': 500,
          'status': 'confirmed',
          'paymentStatus': 'paid',
        }, 'new-public-booking'),
      ];

      await cubit.refresh();

      final trips = (cubit.state as MyTripsSuccess).trips;
      expect(trips.map((trip) => trip.bookingId), [
        'new-private-booking',
        'new-public-booking',
      ]);
      expect(repository.readCount, 2);
      await cubit.close();
    },
  );

  test(
    'refresh requested during a load is replayed after that load finishes',
    () async {
      final repository = _DeferredBookingRepository();
      final tripsRepository = _FakeTripsRepository(
        trips: [
          PublicTrip(
            id: 'public-trip',
            guideId: 'guide-uid',
            title: 'Public tour',
            location: 'Cairo',
            dateLabel: 'Tomorrow',
            durationLabel: '4 hours',
            imageUrl: 'https://example.test/trip.jpg',
            guideName: 'Nadia',
            tag: 'history',
            priceEgp: 500,
            capacity: 8,
            bookedSeats: 1,
          ),
        ],
      );
      final cubit = MyTripsCubit(
        bookingRepository: repository,
        tripsRepository: tripsRepository,
      );
      final loadedNewBooking = Completer<MyTripsSuccess>();
      final subscription = cubit.stream.listen((state) {
        if (state is MyTripsSuccess && state.trips.isNotEmpty) {
          loadedNewBooking.complete(state);
        }
      });

      repository.bookings = [
        TouristBooking.fromDocument({
          'tripId': 'public-trip',
          'tour_title': 'Public tour',
          'seats': 1,
          'totalPrice': 500,
          'status': 'confirmed',
          'paymentStatus': 'paid',
        }, 'confirmed-booking'),
      ];
      await cubit.refresh();
      repository.firstRead.complete(const []);

      final state = await loadedNewBooking.future.timeout(
        const Duration(seconds: 1),
      );
      expect(state.trips.single.bookingId, 'confirmed-booking');
      expect(repository.readCount, 2);

      await subscription.cancel();
      await cubit.close();
    },
  );

  test(
    'private Firestore booking appears in My Trips without a public trip',
    () async {
      final booking = TouristBooking.fromDocument({
        'tripId': '',
        'is_private': true,
        'guideId': 'guide-uid',
        'guideName': 'Nadia',
        'guide_image_url': 'https://example.test/guide.png',
        'tour_title': 'Private tour with Nadia',
        'datetime_label': '2026-11-16',
        'seats': 2,
        'totalPrice': 1200,
        'status': 'confirmed',
        'paymentStatus': 'paid',
      }, 'private-booking-id');
      final tripsRepository = _FakeTripsRepository();
      final cubit = MyTripsCubit(
        bookingRepository: _FakeBookingRepository(bookings: [booking]),
        tripsRepository: tripsRepository,
      );

      final state = await cubit.stream.firstWhere(
        (state) => state is MyTripsSuccess,
      );
      final trip = (state as MyTripsSuccess).trips.single;

      expect(trip.id, 'private-booking-id');
      expect(trip.bookingId, 'private-booking-id');
      expect(trip.title, 'Private tour with Nadia');
      expect(trip.guideName, 'Nadia');
      expect(trip.imageUrl, 'https://example.test/guide.png');
      expect(trip.dateLabel, '2026-11-16');
      expect(trip.category, 'private');
      expect(tripsRepository.requestedTripIds, isEmpty);

      await cubit.close();
    },
  );
}

class _FakeBookingRepository extends BookingRepository {
  _FakeBookingRepository({this.bookings = const [], this.error});

  List<TouristBooking> bookings;
  final Object? error;
  int readCount = 0;

  @override
  Future<List<TouristBooking>> fetchMyBookings() async {
    readCount++;
    if (error != null) throw error!;
    return bookings;
  }
}

class _FakeTripsRepository extends PublicTripsRepository {
  _FakeTripsRepository({this.trips = const []});

  final List<PublicTrip> trips;
  List<String> requestedTripIds = const [];

  @override
  Future<List<PublicTrip>> fetchTripsByIds(
    List<String> tripIds, {
    bool rethrowOnError = false,
  }) async {
    requestedTripIds = tripIds;
    return trips;
  }
}

class _DeferredBookingRepository extends BookingRepository {
  final Completer<List<TouristBooking>> firstRead = Completer();
  List<TouristBooking> bookings = const [];
  int readCount = 0;

  @override
  Future<List<TouristBooking>> fetchMyBookings() {
    readCount++;
    return readCount == 1 ? firstRead.future : Future.value(bookings);
  }
}
