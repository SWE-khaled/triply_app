import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/repositories/trips_repository.dart';
import 'package:triply/features/tourist/trips/cubit/trips_cubit.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

/// Focused local tests for the Trips feed bridge. No Firebase, no emulator:
/// the fake repository bypasses Firestore entirely (possible because
/// [TripsRepository] constructs lazily — building it never touches Firebase).
class _FakeTripsRepository extends TripsRepository {
  final FirestoreResult<List<Trip>> result;
  _FakeTripsRepository(this.result);

  @override
  Future<FirestoreResult<List<Trip>>> approvedTrips({
    String? category,
    int limit = 20,
    Object? startAfter,
  }) async => result;
}

const _remote = Trip(
  id: 'remote-1',
  title: 'Remote Nile Day',
  dateLabel: 'Nov 2',
  guideName: 'Remote Guide',
  peopleCount: 4,
  priceEgp: 5000,
  imageUrl: '',
  status: TripStatus.upcoming,
  category: 'historical',
  capacity: 12,
);

const _remoteCancelled = Trip(
  id: 'remote-2',
  title: 'Remote Cancelled',
  dateLabel: 'Nov 3',
  guideName: 'Remote Guide',
  peopleCount: 0,
  priceEgp: 1000,
  imageUrl: '',
  status: TripStatus.cancelled,
  category: 'historical',
  capacity: 12,
);

void main() {
  group('TripsCubit remote bridge', () {
    test('remote reads are enabled (Phase 1 activation)', () {
      // Was `isFalse` before Phase 1 connected the feed to Firestore.
      expect(TripsCubit.useRemote, isTrue);
    });

    test('initial state shows mocks (loading baseline, never blank)', () {
      final cubit = TripsCubit(_FakeTripsRepository(const FirestoreEmpty()));
      expect(cubit.state.trips, isNotEmpty);
      expect(
        cubit.state.trips.every((t) => t.status == TripStatus.upcoming),
        isTrue,
      );
      cubit.close();
    });

    test('loadRemote success replaces the list and reports true', () async {
      final cubit = TripsCubit(
        _FakeTripsRepository(const FirestoreOk<List<Trip>>([_remote])),
      );
      final ok = await cubit.loadRemote();
      expect(ok, isTrue);
      expect(cubit.state.trips.map((t) => t.id), ['remote-1']);
      await cubit.close();
    });

    test('loadRemote empty keeps mocks and reports false', () async {
      final cubit = TripsCubit(_FakeTripsRepository(const FirestoreEmpty()));
      final before = cubit.state.trips.map((t) => t.id).toList();
      final ok = await cubit.loadRemote();
      expect(ok, isFalse);
      expect(cubit.state.trips.map((t) => t.id).toList(), before);
      await cubit.close();
    });

    test('loadRemote failure keeps mocks and reports false', () async {
      final cubit = TripsCubit(
        _FakeTripsRepository(const FirestoreFailure<List<Trip>>('offline')),
      );
      final before = cubit.state.trips.map((t) => t.id).toList();
      final ok = await cubit.loadRemote();
      expect(ok, isFalse);
      expect(cubit.state.trips.map((t) => t.id).toList(), before);
      await cubit.close();
    });

    test('loadRemote success on empty tab emits honest empty + true', () async {
      // Remote fetch succeeded but nothing matches the selected tab:
      // the empty state is real data (not a failure), so no mock fallback.
      final cubit = TripsCubit(
        _FakeTripsRepository(const FirestoreOk<List<Trip>>([_remote])),
      );
      cubit.selectTab(TripStatus.completed);
      final ok = await cubit.loadRemote();
      expect(ok, isTrue);
      expect(cubit.state.trips, isEmpty);
      await cubit.close();
    });

    test('selectTab filters the remote cache, not mocks', () async {
      final cubit = TripsCubit(
        _FakeTripsRepository(
          const FirestoreOk<List<Trip>>([_remote, _remoteCancelled]),
        ),
      );
      await cubit.loadRemote();
      cubit.selectTab(TripStatus.cancelled);
      expect(cubit.state.trips.map((t) => t.id), ['remote-2']);
      cubit.selectTab(TripStatus.upcoming);
      expect(cubit.state.trips.map((t) => t.id), ['remote-1']);
      // Firestore has no tourist `completed` state: honest empty, no mocks.
      cubit.selectTab(TripStatus.completed);
      expect(cubit.state.trips, isEmpty);
      await cubit.close();
    });

    test('selectTab before any remote load still filters mocks', () {
      final cubit = TripsCubit(_FakeTripsRepository(const FirestoreEmpty()));
      cubit.selectTab(TripStatus.upcoming);
      expect(cubit.state.trips, isNotEmpty);
      expect(
        cubit.state.trips.every((t) => t.status == TripStatus.upcoming),
        isTrue,
      );
      cubit.close();
    });
  });
}
