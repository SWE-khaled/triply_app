import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/guide_profiles_datasource.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/models/guide_profile_doc.dart';
import 'package:triply/data/firestore/models/trip_doc.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import 'package:triply/features/tourist/my_trips/cubit/my_trips_cubit.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

/// Focused Phase 3 unit tests: server list mapping + server cancellation.
/// Fakes override the repository/datasource boundary (possible because all
/// constructors are lazy — building them never touches Firebase). These are
/// UNIT tests, not emulator integration tests.
class _FakeBookingsRepository extends BookingsRepository {
  FirestoreResult<List<BookingDoc>> listResult =
      const FirestoreOk<List<BookingDoc>>([]);
  int myBookingsCalls = 0;
  int cancelCalls = 0;
  String cancelResult = 'none';
  Object? cancelError;
  bool cancelPending = false;

  /// When true, a successful cancel drops that booking from the scripted
  /// list, mirroring the server's post-cancel state on reload.
  bool dropCancelled = false;

  @override
  Future<FirestoreResult<List<BookingDoc>>> myBookings(
    String touristId, {
    int limit = 20,
    Object? startAfter,
  }) async {
    myBookingsCalls++;
    return listResult;
  }

  @override
  Future<String> cancelViaServer(String bookingId, {String reason = ''}) async {
    cancelCalls++;
    if (cancelPending) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (cancelError != null) throw cancelError!;
    if (dropCancelled && listResult is FirestoreOk<List<BookingDoc>>) {
      final items = (listResult as FirestoreOk<List<BookingDoc>>).data
          .where((b) => b.id != bookingId)
          .toList();
      listResult = FirestoreOk<List<BookingDoc>>(items);
    }
    return cancelResult;
  }
}

class _FakeTripsDatasource extends TripsDatasource {
  final Map<String, TripDoc> docs;
  _FakeTripsDatasource(this.docs);

  @override
  Future<TripDoc?> getById(String id) async => docs[id];
}

class _FakeGuidesDatasource extends GuideProfilesDatasource {
  final Map<String, GuideProfileDoc> docs;
  _FakeGuidesDatasource(this.docs);

  @override
  Future<GuideProfileDoc?> getByUserId(String uid) async => docs[uid];
}

const _tripDoc = TripDoc(
  id: 'trip-1',
  guideId: 'guide-1',
  guideName: 'Omar',
  title: 'Nile Day',
  dateLabel: 'Oct 15',
  priceEgp: 1000,
  capacity: 10,
  bookedSeats: 2,
  coverImageUrl: 'http://img',
  approvalStatus: 'approved',
);

BookingDoc _publicBooking({
  String id = 'b1',
  String status = 'pending',
  String tripId = 'trip-1',
  int seats = 2,
  double total = 2100,
}) => BookingDoc(
  id: id,
  touristId: 'u1',
  bookingType: 'public',
  tripId: tripId,
  guideId: 'guide-1',
  seats: seats,
  unitPrice: 1000,
  serviceFee: 100,
  totalAmount: total,
  currency: 'EGP',
  status: status,
  paymentStatus: 'pending',
  idempotencyKey: 'k-$id',
);

BookingDoc _privateBooking({String id = 'b2', String status = 'pending'}) =>
    BookingDoc(
      id: id,
      touristId: 'u1',
      bookingType: 'private',
      guideId: 'guide-1',
      seats: 2,
      durationHours: 4,
      unitPrice: 100,
      serviceFee: 40,
      totalAmount: 840,
      currency: 'EGP',
      status: status,
      paymentStatus: 'pending',
      idempotencyKey: 'k-$id',
    );

const _guideProfile = GuideProfileDoc(
  userId: 'guide-1',
  displayName: 'Omar',
  coverUrl: 'http://avatar',
);

MyTripsCubit _cubit({
  required _FakeBookingsRepository repo,
  Map<String, TripDoc> trips = const {},
  Map<String, GuideProfileDoc> guides = const {},
}) => MyTripsCubit(
  bookings: repo,
  trips: _FakeTripsDatasource(trips),
  guides: _FakeGuidesDatasource(guides),
);

void main() {
  group('MyTripsCubit remote list', () {
    test('remote mode is enabled (Phase 3 activation)', () {
      expect(MyTripsCubit.useRemote, isTrue);
    });

    test('loads public + private bookings with server values', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = FirestoreOk<List<BookingDoc>>([
          _publicBooking(),
          _privateBooking(),
        ]);
      final cubit = _cubit(
        repo: repo,
        trips: {'trip-1': _tripDoc},
        guides: {'guide-1': _guideProfile},
      );
      final ok = await cubit.loadRemote('u1');
      expect(ok, isTrue);
      expect(cubit.state.error, isNull);
      // Both active bookings land on Upcoming.
      expect(cubit.state.trips.map((t) => t.id), ['trip-1', 'b2']);
      final pub = cubit.state.trips.first;
      expect(pub.title, 'Nile Day');
      expect(pub.peopleCount, 2);
      expect(pub.priceEgp, 2100);
      expect(cubit.isPrivateBooking('b1'), isFalse);
      expect(cubit.isPendingApproval('b1'), isTrue);
      expect(cubit.currencyFor('b1'), 'EGP');
      final priv = cubit.state.trips[1];
      expect(priv.title, 'Private tour with Omar');
      expect(priv.priceEgp, 840);
      expect(cubit.isPrivateBooking('b2'), isTrue);
      await cubit.close();
    });

    test('cancelled bookings map to the Cancelled tab only', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = FirestoreOk<List<BookingDoc>>([
          _publicBooking(status: 'cancelled'),
        ]);
      final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
      await cubit.loadRemote('u1');
      expect(cubit.state.trips, isEmpty);
      cubit.selectTab(TripStatus.cancelled);
      expect(cubit.state.trips.map((t) => t.id), ['trip-1']);
      expect(cubit.isCancellable('b1'), isFalse);
      await cubit.close();
    });

    test(
      'two bookings on one trip render two cards; cancel one keeps other',
      () async {
        final second = _publicBooking(id: 'b1b', seats: 1, total: 1050);
        final repo = _FakeBookingsRepository()
          ..listResult = FirestoreOk<List<BookingDoc>>([
            _publicBooking(),
            second,
          ])
          ..dropCancelled = true;
        final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
        await cubit.loadRemote('u1');
        expect(cubit.state.trips.map((t) => t.id), ['trip-1', 'trip-1']);
        expect(cubit.state.trips.map((t) => t.bookingId), ['b1', 'b1b']);
        final refund = await cubit.cancelBooking(uid: 'u1', bookingId: 'b1');
        expect(refund, 'none');
        // The surviving booking still renders its own card.
        expect(cubit.state.trips.map((t) => t.bookingId), ['b1b']);
        await cubit.close();
      },
    );

    test('empty server response stays empty (no mock fallback)', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = const FirestoreEmpty();
      final cubit = _cubit(repo: repo);
      final ok = await cubit.loadRemote('u1');
      expect(ok, isTrue);
      expect(cubit.state.trips, isEmpty);
      expect(cubit.state.error, isNull);
      cubit.selectTab(TripStatus.completed);
      expect(cubit.state.trips, isEmpty);
      await cubit.close();
    });

    test('failure keeps an explicit error and reports false', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = const FirestoreFailure<List<BookingDoc>>('offline');
      final cubit = _cubit(repo: repo);
      final ok = await cubit.loadRemote('u1');
      expect(ok, isFalse);
      expect(cubit.state.trips, isEmpty);
      expect(cubit.state.error, isNotNull);
      await cubit.close();
    });

    test('unauthenticated load fails without a backend call', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = FirestoreOk<List<BookingDoc>>([_publicBooking()]);
      final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
      final ok = await cubit.loadRemote(null);
      expect(ok, isFalse);
      expect(repo.myBookingsCalls, 0);
      expect(cubit.state.error, contains('sign in'));
      await cubit.close();
    });

    test('private booking without a guide profile still renders', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = FirestoreOk<List<BookingDoc>>([_privateBooking()]);
      final cubit = _cubit(repo: repo);
      await cubit.loadRemote('u1');
      expect(cubit.state.trips.map((t) => t.id), ['b2']);
      expect(cubit.state.trips.single.title, 'Private tour');
      expect(cubit.state.trips.single.priceEgp, 840);
      await cubit.close();
    });

    test(
      'public booking with an unresolvable trip renders booking data',
      () async {
        final repo = _FakeBookingsRepository()
          ..listResult = FirestoreOk<List<BookingDoc>>([_publicBooking()]);
        final cubit = _cubit(repo: repo);
        await cubit.loadRemote('u1');
        // Real booking fields only: never hidden, never another trip's data.
        expect(cubit.state.trips.map((t) => t.id), ['trip-1']);
        expect(cubit.state.trips.single.title, 'Booked trip');
        expect(cubit.state.trips.single.priceEgp, 2100);
        await cubit.close();
      },
    );

    test('booking without a trip reference is skipped', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = FirestoreOk<List<BookingDoc>>([
          _publicBooking(tripId: ''),
        ]);
      final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
      await cubit.loadRemote('u1');
      expect(cubit.state.trips, isEmpty);
      await cubit.close();
    });
  });

  group('MyTripsCubit cancellation', () {
    test('unpaid cancel returns none and reloads the list', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = FirestoreOk<List<BookingDoc>>([_publicBooking()])
        ..dropCancelled = true;
      final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
      await cubit.loadRemote('u1');
      final refund = await cubit.cancelBooking(uid: 'u1', bookingId: 'b1');
      expect(refund, 'none');
      expect(repo.cancelCalls, 1);
      expect(repo.myBookingsCalls, 2);
      expect(cubit.state.cancellingIds, isEmpty);
      await cubit.close();
    });

    test(
      'paid cancel returns owed (manual handling, no amounts claimed)',
      () async {
        final repo = _FakeBookingsRepository()
          ..listResult = FirestoreOk<List<BookingDoc>>([_publicBooking()])
          ..cancelResult = 'owed';
        final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
        await cubit.loadRemote('u1');
        final refund = await cubit.cancelBooking(uid: 'u1', bookingId: 'b1');
        // Raw server status only: the View maps this to wording without
        // amounts or visa claims.
        expect(refund, 'owed');
        await cubit.close();
      },
    );

    test('server rejection propagates and the list is untouched', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = FirestoreOk<List<BookingDoc>>([_publicBooking()])
        ..cancelError = Exception('Booking is confirmed.');
      final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
      await cubit.loadRemote('u1');
      final before = cubit.state.trips.map((t) => t.id).toList();
      await expectLater(
        cubit.cancelBooking(uid: 'u1', bookingId: 'b1'),
        throwsA(predicate((e) => e.toString().contains('confirmed'))),
      );
      expect(cubit.state.trips.map((t) => t.id).toList(), before);
      expect(cubit.state.cancellingIds, isEmpty);
      expect(repo.myBookingsCalls, 1);
      await cubit.close();
    });

    test(
      'duplicate in-flight cancel is rejected before a second call',
      () async {
        final repo = _FakeBookingsRepository()
          ..listResult = FirestoreOk<List<BookingDoc>>([_publicBooking()])
          ..cancelPending = true;
        final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
        await cubit.loadRemote('u1');
        final first = cubit.cancelBooking(uid: 'u1', bookingId: 'b1');
        await expectLater(
          cubit.cancelBooking(uid: 'u1', bookingId: 'b1'),
          throwsA(
            predicate((e) => e.toString().contains('already in progress')),
          ),
        );
        expect(await first, 'none');
        expect(repo.cancelCalls, 1);
        expect(cubit.state.cancellingIds, isEmpty);
        await cubit.close();
      },
    );

    test('already-cancelled booking fails before any server call', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = FirestoreOk<List<BookingDoc>>([
          _publicBooking(status: 'cancelled'),
        ]);
      final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
      await cubit.loadRemote('u1');
      await expectLater(
        cubit.cancelBooking(uid: 'u1', bookingId: 'b1'),
        throwsA(predicate((e) => e.toString().contains('already cancelled'))),
      );
      expect(repo.cancelCalls, 0);
      await cubit.close();
    });

    test('completed booking is not cancellable', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = FirestoreOk<List<BookingDoc>>([
          _publicBooking(status: 'completed'),
        ]);
      final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
      await cubit.loadRemote('u1');
      expect(cubit.isCancellable('b1'), isFalse);
      await expectLater(
        cubit.cancelBooking(uid: 'u1', bookingId: 'b1'),
        throwsA(
          predicate((e) => e.toString().contains('no longer be cancelled')),
        ),
      );
      expect(repo.cancelCalls, 0);
      await cubit.close();
    });

    test('unknown trip id fails without a server call', () async {
      final repo = _FakeBookingsRepository()
        ..listResult = FirestoreOk<List<BookingDoc>>([_publicBooking()]);
      final cubit = _cubit(repo: repo, trips: {'trip-1': _tripDoc});
      await cubit.loadRemote('u1');
      await expectLater(
        cubit.cancelBooking(uid: 'u1', bookingId: 'ghost'),
        throwsA(predicate((e) => e.toString().contains('not found'))),
      );
      expect(repo.cancelCalls, 0);
      await cubit.close();
    });
  });
}
