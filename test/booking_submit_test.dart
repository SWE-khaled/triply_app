import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/my_bookings_public.dart';
import 'package:triply/data/firestore/booking_pricing.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import 'package:triply/features/tourist/booking/cubit/booking_cubit.dart';
import 'package:triply/features/tourist/booking_public/cubit/booking_public_cubit.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

/// Focused Phase 2 tests: cubits submit through `createBooking` with stable
/// idempotency keys and server-authoritative totals. No Firebase, no
/// emulator: the fake repository overrides the callable boundary (possible
/// because failures/successes are scripted without touching channels).
class _FakeBookingsRepository extends BookingsRepository {
  int createPublicCalls = 0;
  int createPrivateCalls = 0;
  Map<String, dynamic>? lastPublic;
  Map<String, dynamic>? lastPrivate;
  Future<BookingDoc>? pendingPublic;
  BookingDoc? publicResult;
  Object? publicError;
  BookingDoc? privateResult;
  Object? privateError;

  @override
  Future<BookingDoc> createPublic({
    required String tripId,
    DateTime? tripDate,
    required int seats,
    required String idempotencyKey,
    String specialRequests = '',
  }) async {
    createPublicCalls++;
    lastPublic = {
      'tripId': tripId,
      'tripDate': tripDate?.toUtc().toIso8601String(),
      'seats': seats,
      'specialRequests': specialRequests,
      'idempotencyKey': idempotencyKey,
    };
    if (pendingPublic != null) return pendingPublic!;
    if (publicError != null) throw publicError!;
    return publicResult!;
  }

  @override
  Future<BookingDoc> createPrivate({
    required String guideId,
    String? placeId,
    required DateTime appointmentAt,
    required String timeSlot,
    required int travelers,
    required int durationHours,
    String meetingPoint = '',
    String specialRequests = '',
    required String idempotencyKey,
  }) async {
    createPrivateCalls++;
    lastPrivate = {
      'guideId': guideId,
      'placeId': placeId,
      'appointmentAt': appointmentAt.toUtc().toIso8601String(),
      'timeSlot': timeSlot,
      'travelers': travelers,
      'durationHours': durationHours,
      'meetingPoint': meetingPoint,
      'specialRequests': specialRequests,
      'idempotencyKey': idempotencyKey,
    };
    if (privateError != null) throw privateError!;
    return privateResult!;
  }
}

const _trip = Trip(
  id: 't1',
  title: 'Nile Day',
  dateLabel: 'Oct 15, 2026 · 6:00 AM',
  guideName: 'Omar',
  peopleCount: 6,
  priceEgp: 6000,
  imageUrl: '',
  status: TripStatus.upcoming,
  category: 'historical',
  capacity: 12,
  // Remote-backed card (as mapped from `trips/t1`): bookable.
  isRemote: true,
);

BookingDoc _serverPublicDoc() => const BookingDoc(
  id: 'b-server-1',
  touristId: 'u1',
  bookingType: 'public',
  tripId: 't1',
  guideId: 'g1',
  seats: 2,
  unitPrice: 6000,
  serviceFee: 600,
  totalAmount: 12600,
  currency: 'EGP',
  status: 'pending',
  paymentStatus: 'pending',
  idempotencyKey: 'k',
);

BookingDoc _serverPrivateDoc() => const BookingDoc(
  id: 'b-server-2',
  touristId: 'u1',
  bookingType: 'private',
  guideId: 'guide1',
  seats: 2,
  durationHours: 4,
  unitPrice: 100,
  serviceFee: 40,
  totalAmount: 840,
  currency: 'EGP',
  status: 'pending',
  paymentStatus: 'pending',
  idempotencyKey: 'k',
);

void _clearLocalBookings() {
  for (final id in MyBookingsPublic.bookedIds.toList()) {
    MyBookingsPublic.cancelBooking(id);
  }
}

void main() {
  tearDown(_clearLocalBookings);

  group('public submit', () {
    test(
      'success sends the callable contract + returns server totals',
      () async {
        final repo = _FakeBookingsRepository()
          ..publicResult = _serverPublicDoc();
        final cubit = BookingPublicCubit()..changeSeats(2);
        final doc = await cubit.submitBooking(
          repository: repo,
          uid: 'u1',
          trip: _trip,
        );
        expect(doc, isNotNull);
        // Server is authoritative: totals come from the response, not the UI.
        expect(doc!.id, 'b-server-1');
        expect(doc.totalAmount, 12600);
        expect(doc.serviceFee, 600);
        expect(doc.status, 'pending');
        expect(doc.paymentStatus, 'pending');
        // Callable contract: trip id, seats, key; display dateLabel is NOT
        // parseable, so tripDate is omitted rather than invented.
        expect(repo.createPublicCalls, 1);
        expect(repo.lastPublic!['tripId'], 't1');
        expect(repo.lastPublic!['seats'], 2);
        expect(repo.lastPublic!['tripDate'], isNull);
        final key = repo.lastPublic!['idempotencyKey'] as String;
        expect(key.startsWith('pub-u1-t1-nodate-2-'), isTrue);
        expect(key.length >= 8 && key.length <= 160, isTrue);
        expect(key.contains('/'), isFalse);
        expect(cubit.state.isSubmitting, isFalse);
        await cubit.close();
      },
    );

    test('ISO dateLabel is sent as UTC tripDate', () async {
      const isoTrip = Trip(
        id: 't9',
        title: 'T',
        dateLabel: '2026-11-02T10:00:00.000Z',
        guideName: 'G',
        peopleCount: 0,
        priceEgp: 100,
        imageUrl: '',
        status: TripStatus.upcoming,
        category: 'historical',
        capacity: 10,
        isRemote: true,
      );
      final repo = _FakeBookingsRepository()..publicResult = _serverPublicDoc();
      final cubit = BookingPublicCubit();
      await cubit.submitBooking(repository: repo, uid: 'u1', trip: isoTrip);
      expect(repo.lastPublic!['tripDate'], '2026-11-02T10:00:00.000Z');
      expect(
        (repo.lastPublic!['idempotencyKey'] as String).contains('20261102'),
        isTrue,
      );
      await cubit.close();
    });

    test('sold-out trip fails before any backend call', () async {
      const full = Trip(
        id: 'tFull',
        title: 'Full',
        dateLabel: 'x',
        guideName: 'G',
        peopleCount: 6,
        priceEgp: 100,
        imageUrl: '',
        status: TripStatus.upcoming,
        category: 'historical',
        capacity: 6,
      );
      final repo = _FakeBookingsRepository()..publicResult = _serverPublicDoc();
      final cubit = BookingPublicCubit();
      await expectLater(
        cubit.submitBooking(repository: repo, uid: 'u1', trip: full),
        throwsA(isA<Exception>()),
      );
      expect(repo.createPublicCalls, 0);
      expect(cubit.state.isSubmitting, isFalse);
      await cubit.close();
    });

    test('unauthenticated submit fails without backend call', () async {
      final repo = _FakeBookingsRepository()..publicResult = _serverPublicDoc();
      final cubit = BookingPublicCubit();
      await expectLater(
        cubit.submitBooking(repository: repo, uid: null, trip: _trip),
        throwsA(predicate((e) => e.toString().contains('Please sign in'))),
      );
      expect(repo.createPublicCalls, 0);
      await cubit.close();
    });

    test('mock (non-remote) trip is refused before any backend call',
        () async {
      // Regression for "Trip not found.": mock/offline baseline cards carry
      // ids the server has never seen (`trips/t1` absent), so the cubit
      // refuses honestly instead of surfacing a late server `not-found`.
      const mockTrip = Trip(
        id: 't1',
        title: 'Nile Day',
        dateLabel: 'Oct 15, 2026 · 6:00 AM',
        guideName: 'Omar',
        peopleCount: 6,
        priceEgp: 6000,
        imageUrl: '',
        status: TripStatus.upcoming,
        category: 'historical',
        capacity: 12,
      );
      expect(mockTrip.isRemote, isFalse);
      final repo = _FakeBookingsRepository()
        ..publicResult = _serverPublicDoc();
      final cubit = BookingPublicCubit()..changeSeats(2);
      await expectLater(
        cubit.submitBooking(repository: repo, uid: 'u1', trip: mockTrip),
        throwsA(
          predicate((e) => e.toString().contains('not available for booking')),
        ),
      );
      expect(repo.createPublicCalls, 0);
      expect(cubit.state.isSubmitting, isFalse);
      await cubit.close();
    });

    test('checkout forwards the exact selected trip id', () async {
      const remote = Trip(
        id: 'trip-demo-public',
        title: 'Demo',
        dateLabel: '2026-11-02T10:00:00.000Z',
        guideName: 'G',
        peopleCount: 0,
        priceEgp: 1000,
        imageUrl: '',
        status: TripStatus.upcoming,
        category: 'historical',
        capacity: 10,
        isRemote: true,
      );
      final repo = _FakeBookingsRepository()
        ..publicResult = _serverPublicDoc();
      final cubit = BookingPublicCubit();
      await cubit.submitBooking(repository: repo, uid: 'u1', trip: remote);
      expect(repo.lastPublic!['tripId'], 'trip-demo-public');
      expect(
        (repo.lastPublic!['idempotencyKey'] as String).contains(
          'trip-demo-public',
        ),
        isTrue,
      );
      await cubit.close();
    });

    test(
      'backend failure propagates, resets flag, records nothing local',
      () async {
        final repo = _FakeBookingsRepository()
          ..publicError = Exception('Only 1 seats left.');
        final cubit = BookingPublicCubit()..changeSeats(2);
        await expectLater(
          cubit.submitBooking(repository: repo, uid: 'u1', trip: _trip),
          throwsA(predicate((e) => e.toString().contains('Only 1 seats left'))),
        );
        expect(cubit.state.isSubmitting, isFalse);
        expect(MyBookingsPublic.bookedIds, isEmpty);
        await cubit.close();
      },
    );

    test('duplicate in-flight submit returns null; repo called once', () async {
      final gate = Completer<BookingDoc>();
      final repo = _FakeBookingsRepository()..pendingPublic = gate.future;
      final cubit = BookingPublicCubit()..changeSeats(2);
      final first = cubit.submitBooking(
        repository: repo,
        uid: 'u1',
        trip: _trip,
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isSubmitting, isTrue);
      final second = await cubit.submitBooking(
        repository: repo,
        uid: 'u1',
        trip: _trip,
      );
      expect(second, isNull);
      gate.complete(_serverPublicDoc());
      final doc = await first;
      expect(doc!.id, 'b-server-1');
      expect(repo.createPublicCalls, 1);
      expect(cubit.state.isSubmitting, isFalse);
      await cubit.close();
    });

    test('idempotency key is stable per request, unique per change', () {
      String key({int seats = 2, String req = 'window seat'}) =>
          BookingPublicCubit.buildIdempotencyKey(
            uid: 'u1',
            tripId: 't1',
            tripDate: null,
            seats: seats,
            specialRequests: req,
          );
      expect(key(), key());
      expect(key(seats: 3) == key(), isFalse);
      expect(key(req: 'aisle') == key(), isFalse);
      expect(BookingPricing.shortHash('a'), BookingPricing.shortHash('a'));
      expect(BookingPricing.shortHash('a').length, 8);
    });
  });

  group('private submit', () {
    BookingCubit readyCubit() {
      // Remote-backed guide (as mapped from `guideProfiles/guide1`).
      final cubit = BookingCubit(guideId: 'guide1', isRemoteGuide: true);
      cubit.setDate(DateTime.utc(2026, 11, 2, 10));
      cubit.setTimeSlot('9:00 AM');
      cubit.setDuration('4 hours');
      return cubit;
    }

    test('success sends the private contract with server totals', () async {
      final repo = _FakeBookingsRepository()
        ..privateResult = _serverPrivateDoc();
      final cubit = readyCubit();
      final doc = await cubit.submitBooking(repository: repo, uid: 'u1');
      expect(doc, isNotNull);
      expect(doc!.totalAmount, 840);
      expect(doc.paymentStatus, 'pending');
      expect(repo.createPrivateCalls, 1);
      expect(repo.lastPrivate!['guideId'], 'guide1');
      expect(repo.lastPrivate!['appointmentAt'], '2026-11-02T10:00:00.000Z');
      expect(repo.lastPrivate!['travelers'], 2);
      expect(repo.lastPrivate!['durationHours'], 4);
      expect(repo.lastPrivate!['timeSlot'], '9:00 AM');
      final key = repo.lastPrivate!['idempotencyKey'] as String;
      expect(key.startsWith('pvt-u1-guide1-20261102-2-4h-'), isTrue);
      expect(key.length >= 8 && key.length <= 160, isTrue);
      expect(cubit.state.isSubmitting, isFalse);
      await cubit.close();
    });

    test('missing date fails before any backend call', () async {
      final repo = _FakeBookingsRepository()
        ..privateResult = _serverPrivateDoc();
      final cubit = BookingCubit(guideId: 'guide1', isRemoteGuide: true);
      await expectLater(
        cubit.submitBooking(repository: repo, uid: 'u1'),
        throwsA(predicate((e) => e.toString().contains('Select a date'))),
      );
      expect(repo.createPrivateCalls, 0);
      await cubit.close();
    });

    test('mock (non-remote) guide is refused before any backend call',
        () async {
      // Private keeps its own guide lookup (never a trip lookup): a
      // mock/offline guide id has no `guideProfiles/` document, so the
      // cubit refuses honestly instead of surfacing "Guide not found."
      final repo = _FakeBookingsRepository()
        ..privateResult = _serverPrivateDoc();
      final cubit = BookingCubit(guideId: 'g1');
      expect(cubit.isRemoteGuide, isFalse);
      cubit.setDate(DateTime.utc(2026, 11, 2, 10));
      cubit.setTimeSlot('9:00 AM');
      cubit.setDuration('4 hours');
      await expectLater(
        cubit.submitBooking(repository: repo, uid: 'u1'),
        throwsA(
          predicate((e) => e.toString().contains('not available for booking')),
        ),
      );
      expect(repo.createPrivateCalls, 0);
      expect(cubit.state.isSubmitting, isFalse);
      await cubit.close();
    });

    test('checkout forwards the exact selected guide id', () async {
      final repo = _FakeBookingsRepository()
        ..privateResult = _serverPrivateDoc();
      final cubit = readyCubit();
      await cubit.submitBooking(repository: repo, uid: 'u1');
      expect(repo.lastPrivate!['guideId'], 'guide1');
      expect(
        (repo.lastPrivate!['idempotencyKey'] as String).contains('guide1'),
        isTrue,
      );
      await cubit.close();
    });

    test('unknown guide error propagates and records nothing local', () async {
      final repo = _FakeBookingsRepository()
        ..privateError = Exception('Guide not found.');
      final cubit = readyCubit();
      await expectLater(
        cubit.submitBooking(repository: repo, uid: 'u1'),
        throwsA(predicate((e) => e.toString().contains('Guide not found'))),
      );
      expect(cubit.state.isSubmitting, isFalse);
      expect(MyBookingsPublic.bookedIds, isEmpty);
      await cubit.close();
    });

    test('private key changes with material fields', () {
      String key({int travelers = 2, int hours = 4}) =>
          BookingCubit.buildIdempotencyKey(
            uid: 'u1',
            guideId: 'guide1',
            appointmentAt: DateTime.utc(2026, 11, 2, 10),
            timeSlot: '9:00 AM',
            travelers: travelers,
            durationHours: hours,
            meetingPoint: 'Hotel Lobby',
            specialRequests: '',
            placeId: null,
          );
      expect(key(), key());
      expect(key(travelers: 3) == key(), isFalse);
      expect(key(hours: 2) == key(), isFalse);
    });
  });

  group('booking response model', () {
    test('BookingDoc reads the callable response shape', () {
      final doc = BookingDoc.fromMap({
        'touristId': 'u1',
        'bookingType': 'public',
        'tripId': 't1',
        'guideId': 'g1',
        'tripDate': '2026-11-02T10:00:00.000Z',
        'seats': 2,
        'unitPrice': 6000,
        'serviceFee': 600,
        'totalAmount': 12600,
        'currency': 'EGP',
        'status': 'pending',
        'paymentStatus': 'pending',
        'idempotencyKey': 'k',
      }, 'b1');
      expect(doc.id, 'b1');
      expect(doc.isPublic, isTrue);
      expect(doc.seats, 2);
      expect(doc.totalAmount, 12600);
      expect(doc.tripDate, DateTime.utc(2026, 11, 2, 10));
    });
  });
}
