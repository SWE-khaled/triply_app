// Phase 1 emulator probe: REAL Flutter Firebase SDK against the LOCAL
// Firestore emulator. Run ONLY via:
//   flutter run -d chrome --target tool/phase1_emu_probe.dart \
//     --dart-define=TRIPLY_EMULATOR_HOST=127.0.0.1:8090 \
//     --dart-define=TRIPLY_EMULATOR_PROJECT=demo-phase1
//
// Why `flutter run` and not `flutter test`: `flutter test -d chrome`
// builds test bundles WITHOUT the web plugin registrant, so
// Firebase.initializeApp falls back to MethodChannelFirebase and fails
// with FirebaseCoreHostApi channel-error. `flutter run` builds a real app
// bundle WITH the registrant (firebase_core_web), so the real web SDK is
// used. This file is under tool/ so `flutter test` never picks it up.
//
// Isolation: demo Firebase app + explicit emulator Settings applied BEFORE
// any Firestore use. Defaults are local-only. Production
// (DefaultFirebaseOptions / triply-f9b82) is never referenced here.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/repositories/trips_repository.dart';
import 'package:triply/features/tourist/place_details/cubit/place_detail_cubit.dart';
import 'package:triply/features/tourist/trip_details/cubit/trip_details_cubit.dart';
import 'package:triply/features/tourist/trips/cubit/trips_cubit.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

const _host = String.fromEnvironment(
  'TRIPLY_EMULATOR_HOST',
  defaultValue: '127.0.0.1:8090',
);
const _project = String.fromEnvironment(
  'TRIPLY_EMULATOR_PROJECT',
  defaultValue: 'demo-phase1',
);

int _pass = 0;
int _fail = 0;

void _check(String name, bool ok, [String detail = '']) {
  if (ok) {
    _pass++;
    debugPrint('PROBE_PASS $name $detail');
  } else {
    _fail++;
    debugPrint('PROBE_FAIL $name $detail');
  }
}

bool _ids(List<Trip> trips, List<String> want) {
  final got = trips.map((t) => t.id).toList();
  if (got.length != want.length) return false;
  for (var i = 0; i < want.length; i++) {
    if (got[i] != want[i]) return false;
  }
  return true;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Endpoint override BEFORE any Firebase/Firestore instance is used.
    final app = await Firebase.initializeApp(
      name: 'phase1probe',
      options: FirebaseOptions(
        apiKey: 'emulator-only',
        appId: '1:1:web:1',
        messagingSenderId: '1',
        projectId: _project,
      ),
    );
    final db = FirebaseFirestore.instanceFor(app: app);
    db.settings = Settings(
      host: _host,
      sslEnabled: false,
      persistenceEnabled: false,
    );
    debugPrint('PROBE_INFO app=${app.options.projectId} host=$_host');

    final repo = TripsRepository(TripsDatasource(db));

    // 1. Approved trips through the real repository/datasource.
    try {
      final res = await repo.approvedTrips();
      _check(
        'approvedTrips',
        res is FirestoreOk<List<Trip>> &&
            _ids(res.data, ['pa-min', 'pa-other', 'pa-full']),
        res is FirestoreOk<List<Trip>>
            ? res.data.map((t) => t.id).join(',')
            : res.runtimeType.toString(),
      );
    } catch (e) {
      _check('approvedTrips', false, 'threw $e');
    }

    // 2. Existing trip by ID (incl. real rating aggregates).
    try {
      final res = await repo.tripDetails('pa-full');
      final ok =
          res is FirestoreOk &&
          (res as FirestoreOk).data.tripId == 'pa-full' &&
          (res as FirestoreOk).data.rating == 4.5 &&
          (res as FirestoreOk).data.reviewsCount == 12;
      _check('tripDetails-pa-full', ok);
    } catch (e) {
      _check('tripDetails-pa-full', false, 'threw $e');
    }

    // 3. Missing trip ID: explicit failure + honest shell, no mock content.
    try {
      final detailsCubit = TripDetailsCubit(repository: repo);
      const ghost = Trip(
        id: 'ghost-id',
        title: 'Ghost Trip',
        dateLabel: 'Dec 1',
        guideName: 'Ghost Guide',
        peopleCount: 2,
        priceEgp: 999,
        imageUrl: '',
        status: TripStatus.upcoming,
        category: 'historical',
        capacity: 5,
      );
      detailsCubit.loadTrip(ghost);
      final ok = await detailsCubit.loadRemote('ghost-id');
      final shell = detailsCubit.state.details!;
      _check(
        'missing-trip-no-mock-leak',
        ok == false &&
            shell.tripId == 'ghost-id' &&
            shell.title == 'Ghost Trip' &&
            shell.about.isEmpty &&
            shell.highlights.isEmpty &&
            shell.itinerary.isEmpty,
        'ok=$ok about=${shell.about.length}',
      );
      await detailsCubit.close();
    } catch (e) {
      _check('missing-trip-no-mock-leak', false, 'threw $e');
    }

    // 4. Trips for a specific place through the real repository.
    try {
      final res = await repo.tripsByPlace('place-giza');
      var ok = false;
      var detail = res.runtimeType.toString();
      if (res is FirestoreOk) {
        final ids = (res as FirestoreOk).data.map((t) => t.id).toList()..sort();
        ok = ids.join(',') == 'pa-full,pa-min';
        detail = ids.join(',');
      }
      _check('tripsByPlace-giza', ok, detail);
      final empty = await repo.tripsByPlace('place-nowhere');
      _check('tripsByPlace-empty', empty is FirestoreEmpty);
    } catch (e) {
      _check('tripsByPlace', false, 'threw $e');
    }

    // 5. Full cubit chains against live data.
    try {
      final tripsCubit = TripsCubit(repo);
      final ok = await tripsCubit.loadRemote();
      _check(
        'TripsCubit.loadRemote',
        ok && _ids(tripsCubit.state.trips, ['pa-min', 'pa-other', 'pa-full']),
      );
      await tripsCubit.close();

      final dCubit = TripDetailsCubit(repository: repo);
      final dOk = await dCubit.loadRemote('pa-full');
      _check(
        'TripDetailsCubit.loadRemote',
        dOk && dCubit.state.details!.rating == 4.5,
      );
      await dCubit.close();

      final pCubit = PlaceDetailCubit(placeId: 'place-giza', trips: repo);
      final pOk = await pCubit.loadRemoteTrips();
      final pIds = pCubit.trips.map((t) => t.id).toList()..sort();
      _check(
        'PlaceDetailCubit.loadRemoteTrips',
        pOk && pIds.join(',') == 'pa-full,pa-min',
        pIds.join(','),
      );
      await pCubit.close();
    } catch (e) {
      _check('cubit-chains', false, 'threw $e');
    }

    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  } catch (e) {
    debugPrint('PROBE_FATAL $e');
    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  }
}
