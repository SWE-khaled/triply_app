import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/repositories/trips_repository.dart';
import 'package:triply/features/tourist/trip_details/cubit/trip_details_cubit.dart';
import 'package:triply/features/tourist/trip_details/model/trip_details.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

/// Focused local tests for the Trip Details bridge. No Firebase, no emulator:
/// the fake repository bypasses Firestore entirely (possible because
/// [TripsRepository] constructs lazily — building it never touches Firebase).
class _FakeTripsRepository extends TripsRepository {
  final FirestoreResult<TripDetails> result;
  _FakeTripsRepository(this.result);

  @override
  Future<FirestoreResult<TripDetails>> tripDetails(String tripId) async =>
      result;
}

const _mockTrip = Trip(
  id: 't1',
  title: 'Mock Trip',
  dateLabel: 'Nov 2',
  guideName: 'Mock Guide',
  peopleCount: 4,
  priceEgp: 1000,
  imageUrl: '',
  status: TripStatus.upcoming,
  category: 'historical',
  capacity: 12,
);

const _remoteDetails = TripDetails(
  id: 'd-t1',
  tripId: 't1',
  tag: 'historical',
  title: 'Remote Trip',
  rating: 4.8,
  reviewsCount: 10,
  location: 'Luxor',
  duration: '5 hours',
  groupType: 'Group',
  languages: 'English',
  about: 'Remote about',
  highlights: ['a'],
  itinerary: [ItineraryStop(time: '9:00', title: 'Start')],
  notes: ['n'],
  meetingPoint: 'Gate',
  priceEgp: 1000,
  guideName: 'Remote Guide',
  guideAvatarUrl: '',
  guideRating: 4.9,
  guideReviews: 20,
  topRatedGuide: true,
  imageUrl: '',
);

void main() {
  group('TripDetailsCubit remote bridge', () {
    test('remote reads are enabled (Phase 1 activation)', () {
      // Was `isFalse` before Phase 1 connected details to Firestore.
      expect(TripDetailsCubit.useRemote, isTrue);
    });

    test('loadTrip baseline renders mock details without remote', () {
      final cubit = TripDetailsCubit(
        repository: _FakeTripsRepository(
          const FirestoreFailure<TripDetails>('must not be called'),
        ),
      );
      cubit.loadTrip(_mockTrip);
      expect(cubit.state.details, isNotNull);
      expect(cubit.state.details!.title, isNotEmpty);
      cubit.close();
    });

    test('loadRemote success replaces details and reports true', () async {
      final cubit = TripDetailsCubit(
        repository: _FakeTripsRepository(
          const FirestoreOk<TripDetails>(_remoteDetails),
        ),
      );
      cubit.loadTrip(_mockTrip);
      final ok = await cubit.loadRemote('t1');
      expect(ok, isTrue);
      expect(cubit.state.details!.title, 'Remote Trip');
      await cubit.close();
    });

    test('loadRemote missing keeps mock details and reports false', () async {
      final cubit = TripDetailsCubit(
        repository: _FakeTripsRepository(const FirestoreEmpty()),
      );
      cubit.loadTrip(_mockTrip);
      final before = cubit.state.details;
      final ok = await cubit.loadRemote('t1');
      expect(ok, isFalse);
      expect(identical(cubit.state.details, before), isTrue);
      await cubit.close();
    });

    test('loadRemote failure keeps mock details and reports false', () async {
      final cubit = TripDetailsCubit(
        repository: _FakeTripsRepository(
          const FirestoreFailure<TripDetails>('denied'),
        ),
      );
      cubit.loadTrip(_mockTrip);
      final before = cubit.state.details;
      final ok = await cubit.loadRemote('nope');
      expect(ok, isFalse);
      expect(identical(cubit.state.details, before), isTrue);
      await cubit.close();
    });

    test('unknown trip id yields honest shell, never another trip', () async {
      // t1 HAS mock details; `ghost` has none. The shell must carry only
      // the card fields with empty content sections — never t1's
      // about/highlights/itinerary/notes.
      const ghost = Trip(
        id: 'ghost',
        title: 'Ghost Trip',
        dateLabel: 'Dec 1',
        guideName: 'Ghost Guide',
        peopleCount: 2,
        priceEgp: 999,
        imageUrl: 'http://ghost',
        status: TripStatus.upcoming,
        category: 'historical',
        capacity: 5,
      );
      final cubit = TripDetailsCubit(
        repository: _FakeTripsRepository(const FirestoreEmpty()),
      );
      cubit.loadTrip(ghost);
      final shell = cubit.state.details!;
      expect(shell.tripId, 'ghost');
      expect(shell.title, 'Ghost Trip');
      expect(shell.priceEgp, 999);
      expect(shell.guideName, 'Ghost Guide');
      expect(shell.imageUrl, 'http://ghost');
      expect(shell.about, isEmpty);
      expect(shell.highlights, isEmpty);
      expect(shell.itinerary, isEmpty);
      expect(shell.notes, isEmpty);
      expect(shell.meetingPoint, isEmpty);
      // And the known trip still resolves its real mock details.
      cubit.loadTrip(_mockTrip);
      expect(cubit.state.details!.tripId, 't1');
      expect(cubit.state.details!.about, isNotEmpty);
      await cubit.close();
    });
  });
}
