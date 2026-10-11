// Phase 1 emulator chain verification: REAL TripsDatasource/TripsRepository
// (+ real cubits) against the LOCAL Firestore emulator.
//
// SKIPPED unless run explicitly with:
//   flutter test -d chrome
//     --dart-define=TRIPLY_EMULATOR_TESTS=true
//     test/phase1_emulator_chain_test.dart
//
// Requires the isolated emulator (demo project, seeded by the out-of-repo
// Node script). NEVER points at production: host/project come from
// --dart-define with local-only defaults. Plain `flutter test` (VM)
// skips every test here without touching Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/repositories/trips_repository.dart';
import 'package:triply/features/tourist/place_details/cubit/place_detail_cubit.dart';
import 'package:triply/features/tourist/trip_details/cubit/trip_details_cubit.dart';
import 'package:triply/features/tourist/trips/cubit/trips_cubit.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

const _runEmu = bool.fromEnvironment('TRIPLY_EMULATOR_TESTS');
const _emuHost = String.fromEnvironment(
  'TRIPLY_EMULATOR_HOST',
  defaultValue: '127.0.0.1:8090',
);
const _emuProject = String.fromEnvironment(
  'TRIPLY_EMULATOR_PROJECT',
  defaultValue: 'demo-phase1',
);

TripsRepository? _repo;

Future<TripsRepository> _realRepo() async {
  final existing = _repo;
  if (existing != null) return existing;
  final app = await Firebase.initializeApp(
    name: 'phase1verify',
    options: FirebaseOptions(
      apiKey: 'emulator-only',
      appId: '1:1:web:1',
      messagingSenderId: '1',
      projectId: _emuProject,
    ),
  );
  final db = FirebaseFirestore.instanceFor(app: app);
  db.settings = Settings(
    host: _emuHost,
    sslEnabled: false,
    persistenceEnabled: false,
  );
  final repo = TripsRepository(TripsDatasource(db));
  _repo = repo;
  return repo;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Plain `flutter test` (VM): no-op, zero Firebase contact.
    if (!_runEmu) return;
    await _realRepo();
  });

  group('Phase 1 emulator chain (local only)', () {
    test('repository.approvedTrips returns seeded approved trips', () async {
      final repo = await _realRepo();
      final result = await repo.approvedTrips();
      expect(result, isA<FirestoreOk<List<Trip>>>());
      final trips = (result as FirestoreOk<List<Trip>>).data;
      expect(trips.map((t) => t.id).toList(), [
        'pa-min',
        'pa-other',
        'pa-full',
      ]);
      expect(
        trips.every((t) => t.status == TripStatus.upcoming),
        isTrue,
      );
      final full = trips.firstWhere((t) => t.id == 'pa-full');
      expect(full.title, 'Giza Dawn');
      expect(full.priceEgp, 6000);
      expect(full.capacity, 12);
    }, skip: !_runEmu);

    test('repository.tripDetails maps real rating aggregates', () async {
      final repo = await _realRepo();
      final result = await repo.tripDetails('pa-full');
      expect(result, isA<FirestoreOk>());
      final details = (result as FirestoreOk).data;
      expect(details.tripId, 'pa-full');
      expect(details.rating, 4.5);
      expect(details.reviewsCount, 12);
      expect(details.about, 'Early access tour');
    }, skip: !_runEmu);

    test('repository.tripDetails on missing id reports failure', () async {
      // Emulator rules deny get on non-existent docs (null resource), so
      // the app takes the explicit Failure path (notice, no wrong trip).
      final repo = await _realRepo();
      final result = await repo.tripDetails('no-such-trip');
      expect(result, isA<FirestoreFailure>());
    }, skip: !_runEmu);

    test('repository.tripsByPlace returns only matching approved trips',
        () async {
      final repo = await _realRepo();
      final giza = await repo.tripsByPlace('place-giza');
      expect(giza, isA<FirestoreOk>());
      final ids = (giza as FirestoreOk).data.map((t) => t.id).toList()
        ..sort();
      expect(ids, ['pa-full', 'pa-min']);
      final nowhere = await repo.tripsByPlace('place-nowhere');
      expect(nowhere, isA<FirestoreEmpty>());
    }, skip: !_runEmu);

    test('TripsCubit.loadRemote loads live trips through the repo', () async {
      final cubit = TripsCubit(await _realRepo());
      final ok = await cubit.loadRemote();
      expect(ok, isTrue);
      expect(cubit.state.trips.map((t) => t.id).toList(), [
        'pa-min',
        'pa-other',
        'pa-full',
      ]);
      await cubit.close();
    }, skip: !_runEmu);

    test('TripDetailsCubit.loadRemote loads live details through the repo',
        () async {
      final cubit = TripDetailsCubit(repository: await _realRepo());
      final ok = await cubit.loadRemote('pa-full');
      expect(ok, isTrue);
      expect(cubit.state.details!.tripId, 'pa-full');
      expect(cubit.state.details!.rating, 4.5);
      await cubit.close();
    }, skip: !_runEmu);

    test('PlaceDetailCubit.loadRemoteTrips loads live tab through the repo',
        () async {
      final cubit = PlaceDetailCubit(
        placeId: 'place-giza',
        trips: await _realRepo(),
      );
      final ok = await cubit.loadRemoteTrips();
      expect(ok, isTrue);
      final ids = cubit.trips.map((t) => t.id).toList()..sort();
      expect(ids, ['pa-full', 'pa-min']);
      await cubit.close();
    }, skip: !_runEmu);
  });
}
