import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/repositories/places_repository.dart';
import 'package:triply/data/firestore/repositories/trips_repository.dart';
import 'package:triply/features/tourist/map/model/place.dart';
import 'package:triply/features/tourist/place_details/cubit/place_detail_cubit.dart';
import 'package:triply/features/tourist/place_details/model/trip.dart'
    as place_trip;

/// Focused local tests for the Place header bridge (tabs stay on mocks by
/// design). No Firebase, no emulator: the fake repository bypasses Firestore
/// entirely (possible because [PlacesRepository] constructs lazily).
class _FakePlacesRepository extends PlacesRepository {
  final FirestoreResult<Place> result;
  _FakePlacesRepository(this.result);

  @override
  Future<FirestoreResult<Place>> byId(String id, {Place? mockFallback}) async =>
      result;
}

/// Fake for the Trips-tab bridge only. No Firebase, no emulator.
class _FakeTripsRepository extends TripsRepository {
  final FirestoreResult<List<place_trip.Trip>> result;
  _FakeTripsRepository(this.result);

  @override
  Future<FirestoreResult<List<place_trip.Trip>>> tripsByPlace(
    String placeId, {
    int limit = 20,
  }) async => result;
}

place_trip.Trip _placeTrip(String id) => place_trip.Trip(
  id: id,
  placeId: 'giza_pyramids',
  title: 'Remote Place Trip',
  dateTime: 'Nov 2',
  guideName: 'Remote Guide',
  peopleCount: 4,
  price: 5000,
  currency: 'EGP',
  imageUrl: '',
);

Place _place(String name) => Place(
  id: 'giza_pyramids',
  name: name,
  city: 'Giza',
  category: 'Historical',
  rating: 4.9,
  reviewsCount: 100,
  shortDescription: 'short',
  about: 'about',
  highlights: const ['h'],
  imageUrl: '',
);

void main() {
  group('PlaceDetailCubit remote header bridge', () {
    test('remote reads are disabled by default (kill-switch)', () {
      expect(PlaceDetailCubit.useRemote, isFalse);
    });

    test('constructor baseline renders mock header without remote', () {
      final cubit = PlaceDetailCubit(
        placeId: 'giza_pyramids',
        places: _FakePlacesRepository(
          const FirestoreFailure<Place>('must not be called'),
        ),
      );
      expect(cubit.place.id, 'giza_pyramids');
      cubit.close();
    });

    test(
      'loadRemotePlace success swaps header, keeps favorite + tabs',
      () async {
        final cubit = PlaceDetailCubit(
          placeId: 'giza_pyramids',
          places: _FakePlacesRepository(
            FirestoreOk<Place>(_place('Remote Name')),
          ),
        );
        cubit.toggleFavorite();
        final guides = cubit.guides;
        final ok = await cubit.loadRemotePlace();
        expect(ok, isTrue);
        expect(cubit.place.name, 'Remote Name');
        expect(cubit.place.isFavorite, isTrue);
        expect(identical(cubit.guides, guides), isTrue);
        await cubit.close();
      },
    );

    test(
      'loadRemotePlace missing keeps mock header and reports false',
      () async {
        final cubit = PlaceDetailCubit(
          placeId: 'giza_pyramids',
          places: _FakePlacesRepository(const FirestoreEmpty()),
        );
        final before = cubit.place;
        final ok = await cubit.loadRemotePlace();
        expect(ok, isFalse);
        expect(identical(cubit.place, before), isTrue);
        await cubit.close();
      },
    );

    test(
      'loadRemotePlace failure keeps mock header and reports false',
      () async {
        final cubit = PlaceDetailCubit(
          placeId: 'giza_pyramids',
          places: _FakePlacesRepository(
            const FirestoreFailure<Place>('denied'),
          ),
        );
        final before = cubit.place;
        final ok = await cubit.loadRemotePlace();
        expect(ok, isFalse);
        expect(identical(cubit.place, before), isTrue);
        await cubit.close();
      },
    );
  });

  group('PlaceDetailCubit remote trips tab (Phase 1)', () {
    test('header remote stays disabled; trips tab is enabled', () {
      expect(PlaceDetailCubit.useRemote, isFalse);
      expect(PlaceDetailCubit.useRemoteTrips, isTrue);
    });

    test(
      'loadRemoteTrips success replaces the tab list, keeps header',
      () async {
        final cubit = PlaceDetailCubit(
          placeId: 'giza_pyramids',
          places: _FakePlacesRepository(const FirestoreEmpty()),
          trips: _FakeTripsRepository(
            FirestoreOk<List<place_trip.Trip>>([_placeTrip('remote-pt-1')]),
          ),
        );
        final beforePlace = cubit.place;
        final ok = await cubit.loadRemoteTrips();
        expect(ok, isTrue);
        expect(cubit.trips.map((t) => t.id), ['remote-pt-1']);
        expect(identical(cubit.place, beforePlace), isTrue);
        await cubit.close();
      },
    );

    test('loadRemoteTrips empty keeps mock tab and reports false', () async {
      final cubit = PlaceDetailCubit(
        placeId: 'giza_pyramids',
        places: _FakePlacesRepository(const FirestoreEmpty()),
        trips: _FakeTripsRepository(const FirestoreEmpty()),
      );
      final before = cubit.trips.map((t) => t.id).toList();
      final ok = await cubit.loadRemoteTrips();
      expect(ok, isFalse);
      expect(cubit.trips.map((t) => t.id).toList(), before);
      await cubit.close();
    });

    test('loadRemoteTrips failure keeps mock tab and reports false', () async {
      final cubit = PlaceDetailCubit(
        placeId: 'giza_pyramids',
        places: _FakePlacesRepository(const FirestoreEmpty()),
        trips: _FakeTripsRepository(
          const FirestoreFailure<List<place_trip.Trip>>('offline'),
        ),
      );
      final before = cubit.trips.map((t) => t.id).toList();
      final ok = await cubit.loadRemoteTrips();
      expect(ok, isFalse);
      expect(cubit.trips.map((t) => t.id).toList(), before);
      await cubit.close();
    });
  });
}
