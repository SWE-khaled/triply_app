// Phase 3 emulator probe: REAL Flutter SDK (Auth + Firestore + Functions)
// against the LOCAL emulator suite. Run ONLY via:
//   flutter run -d chrome --target tool/phase3_emu_probe.dart
//     --dart-define=TRIPLY_EMULATOR_HOST=127.0.0.1:8090
//     --dart-define=TRIPLY_EMULATOR_AUTH_HOST=127.0.0.1:9099
//     --dart-define=TRIPLY_EMULATOR_FUNCTIONS_HOST=127.0.0.1
//     --dart-define=TRIPLY_EMULATOR_FUNCTIONS_PORT=5001
//     --dart-define=TRIPLY_EMULATOR_PROJECT=demo-phase3
//     --web-browser-flag=--headless=new
//
// (See tool/phase1_emu_probe.dart for why `flutter run` is required.)
// Isolation: DEFAULT app with demo options + emulator overrides applied
// BEFORE any Firebase use. Fixtures come from the out-of-repo
// phase3-seed.js (fixed uids phase3A/phase3B). Production
// (DefaultFirebaseOptions / triply-f9b82) is never referenced here.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import 'package:triply/features/tourist/my_trips/cubit/my_trips_cubit.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

const _fsHost = String.fromEnvironment(
  'TRIPLY_EMULATOR_HOST',
  defaultValue: '127.0.0.1:8090',
);
const _authHost = String.fromEnvironment(
  'TRIPLY_EMULATOR_AUTH_HOST',
  defaultValue: '127.0.0.1:9099',
);
const _fnHost = String.fromEnvironment(
  'TRIPLY_EMULATOR_FUNCTIONS_HOST',
  defaultValue: '127.0.0.1',
);
const _fnPort = int.fromEnvironment(
  'TRIPLY_EMULATOR_FUNCTIONS_PORT',
  defaultValue: 5001,
);
const _project = String.fromEnvironment(
  'TRIPLY_EMULATOR_PROJECT',
  defaultValue: 'demo-phase3',
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

String _err(Object e) {
  const prefix = 'Exception: ';
  final t = e.toString();
  return t.startsWith(prefix) ? t.substring(prefix.length) : t;
}

Future<void> _signIn(String email) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: 'pass1234',
    );
  } catch (e) {
    debugPrint('PROBE_FATAL sign-in $email: $e');
    rethrow;
  }
}

void main() {
  run();
}

Future<void> run() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Emulator overrides BEFORE any Firebase/Firestore/Functions/Auth use.
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'emulator-only',
        appId: '1:1:web:1',
        messagingSenderId: '1',
        projectId: _project,
      ),
    );
    final authHostParts = _authHost.split(':');
    await FirebaseAuth.instance.useAuthEmulator(
      authHostParts[0],
      int.parse(authHostParts[1]),
    );
    FirebaseFirestore.instance.settings = Settings(
      host: _fsHost,
      sslEnabled: false,
      persistenceEnabled: false,
    );
    FirebaseFunctions.instance.useFunctionsEmulator(_fnHost, _fnPort);
    debugPrint('PROBE_INFO project=$_project fs=$_fsHost');

    await _signIn('phase3a@test.dev');
    final uidA = FirebaseAuth.instance.currentUser!.uid;
    final cubit = MyTripsCubit();

    // 1. Server list: two cards for one twice-booked trip + private card.
    var ok = await cubit.loadRemote(uidA);
    final upcoming = cubit.state.trips.where(
      (t) => t.status == TripStatus.upcoming,
    );
    final upIds = upcoming.map((t) => t.id).toList();
    final upBookings = upcoming.map((t) => t.bookingId).toList();
    _check(
      'list-upcoming',
      ok &&
          upIds.where((id) => id == 'p3-trip-a').length == 2 &&
          upIds.any((id) => id == 'p3-private') &&
          upBookings.toSet().length == 3 &&
          !upIds.contains('p3-other') &&
          cubit.state.error == null,
      upIds.join(','),
    );

    // 2. Server values on cards (no mock data).
    final first = upcoming.firstWhere((t) => t.id == 'p3-trip-a');
    _check(
      'card-values',
      first.title == 'P3 Nile Day' &&
          first.priceEgp == 1050 &&
          first.peopleCount == 1 &&
          cubit.isPendingApproval(first.bookingId) &&
          !cubit.isPrivateBooking(first.bookingId) &&
          cubit.currencyFor(first.bookingId) == 'EGP' &&
          cubit.isCancellable(first.bookingId),
    );
    final priv = upcoming.firstWhere((t) => t.id == 'p3-private');
    _check(
      'private-card',
      priv.title == 'Private tour with P3 Guide' &&
          priv.priceEgp == 2100 &&
          cubit.isPrivateBooking(priv.bookingId),
      priv.title,
    );

    // 3. Cancelled tab shows the cancelled booking only.
    cubit.selectTab(TripStatus.cancelled);
    _check(
      'cancelled-tab',
      cubit.state.trips.map((t) => t.bookingId).toList().join(',') ==
          'p3-cancelled',
    );
    cubit.selectTab(TripStatus.upcoming);

    // 4. Cancel the UNPAID booking via the real callable: 'none' + refresh.
    // (Two cards share trip p3-trip-a; target the exact booking id so the
    // paid one survives.)
    final unpaidCard = upcoming.firstWhere(
      (t) => t.bookingId == 'p3-unpaid',
    );
    var refund = await cubit.cancelBooking(
      uid: uidA,
      bookingId: unpaidCard.bookingId,
    );
    final afterCancel = cubit.state.trips
        .where((t) => t.status == TripStatus.upcoming)
        .map((t) => t.bookingId)
        .toList();
    _check(
      'cancel-unpaid',
      refund == 'none' &&
          !afterCancel.contains('p3-unpaid') &&
          afterCancel.contains('p3-paid') &&
          cubit.state.cancellingIds.isEmpty,
      'refund=$refund remaining=${afterCancel.join(',')}',
    );

    // 5. Capacity restored atomically by the trigger (1 -> 0). The
    // trigger runs async after the callable write, so poll briefly.
    var seats = -1;
    for (var i = 0; i < 30; i++) {
      final trip = await TripsDatasource().getById('p3-trip-a');
      seats = trip?.bookedSeats ?? -1;
      if (seats == 0) break;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    _check('capacity-restored', seats == 0, 'bookedSeats=$seats');

    // 6. Cancel paid booking: 'owed', never an amount/visa claim.
    final paidCard = cubit.state.trips.firstWhere(
      (t) => t.bookingId == 'p3-paid',
    );
    refund = await cubit.cancelBooking(
      uid: uidA,
      bookingId: paidCard.bookingId,
    );
    _check('cancel-paid-owed', refund == 'owed', 'refund=$refund');
    _check(
      'paid-card-gone',
      !cubit.state.trips.any((t) => t.bookingId == 'p3-paid'),
    );
    await cubit.close();

    // 7. Stranger cannot cancel another user's booking (server denial).
    await _signIn('phase3b@test.dev');
    final uidB = FirebaseAuth.instance.currentUser!.uid;
    final repo = BookingsRepository();
    try {
      await repo.cancelViaServer('p3-private');
      _check('stranger-cancel-denied', false, 'unexpected success');
    } catch (e) {
      _check(
        'stranger-cancel-denied',
        _err(e).contains('Not your booking'),
        _err(e),
      );
    }

    // 8. Stranger list shows only their own booking.
    final cubitB = MyTripsCubit();
    await cubitB.loadRemote(uidB);
    _check(
      'stranger-list-isolated',
      cubitB.state.trips.length == 1 &&
          cubitB.state.trips.single.bookingId == 'p3-other',
      cubitB.state.trips.map((t) => t.bookingId).join(','),
    );
    await cubitB.close();

    // 9. Unauthenticated load fails with an explicit error.
    final cubitC = MyTripsCubit();
    final okC = await cubitC.loadRemote(null);
    _check(
      'unauth-load',
      okC == false && (cubitC.state.error ?? '').contains('sign in'),
    );
    await cubitC.close();

    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  } catch (e) {
    debugPrint('PROBE_FATAL $e');
    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  }
}
