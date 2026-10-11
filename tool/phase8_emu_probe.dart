// Phase 8 emulator probe: REAL Flutter SDK (Auth + Firestore + Functions)
// against the LOCAL emulator suite. NO provider key exists here, so Paymob
// itself is never contacted: this probe proves the app never marks paid
// without server confirmation, plus the pending/replay/denial paths.
// Run ONLY via:
//   flutter run -d chrome --target tool/phase8_emu_probe.dart
//     --dart-define=TRIPLY_EMULATOR_HOST=127.0.0.1:8090
//     --dart-define=TRIPLY_EMULATOR_AUTH_HOST=127.0.0.1:9099
//     --dart-define=TRIPLY_EMULATOR_FUNCTIONS_HOST=127.0.0.1
//     --dart-define=TRIPLY_EMULATOR_FUNCTIONS_PORT=5001
//     --dart-define=TRIPLY_EMULATOR_PROJECT=demo-phase8
//     --web-browser-flag=--headless=new
//
// (See tool/phase1_emu_probe.dart for why `flutter run` is required.)
// Isolation: DEFAULT app with demo options + emulator overrides applied
// BEFORE any Firebase use. Fixtures come from the out-of-repo
// phase8-seed.js (fixed uids). Production (DefaultFirebaseOptions /
// triply-f9b82) and live Paymob are never referenced here.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import 'package:triply/features/tourist/my_trips/cubit/my_trips_cubit.dart';

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
  defaultValue: 'demo-phase8',
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
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: 'pass1234',
  );
}

Future<Map<String, dynamic>?> _read(String collection, String id) async {
  final doc = await FirebaseFirestore.instance
      .collection(collection)
      .doc(id)
      .get();
  return doc.exists ? doc.data() : null;
}

void main() {
  run();
}

Future<void> run() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Emulator overrides BEFORE any Firebase use.
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
    debugPrint('PROBE_INFO project=$_project fs=$_fsHost (no provider key)');

    await _signIn('payt8@test.dev');
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final repo = BookingsRepository();

    // 1. Real booking via the callable (server totals, pending/pending).
    final booking = await repo.createPublic(
      tripId: 'ptrip8',
      tripDate: null,
      seats: 1,
      idempotencyKey: 'probe-p8-k1',
      specialRequests: '',
    );
    _check(
      'booking-created',
      booking.totalAmount == 1050 &&
          booking.status == 'pending' &&
          booking.paymentStatus == 'pending',
      'total=${booking.totalAmount}',
    );

    // 2. Pending reconciliation record through the real rules.
    final paymentId = await repo.createPendingPayment(
      bookingId: booking.id,
      touristId: uid,
      amount: booking.totalAmount,
      providerReference: 'order-probe-1',
    );
    final payment = await _read('payments', paymentId);
    _check(
      'pending-record',
      paymentId.isNotEmpty &&
          payment?['status'] == 'pending' &&
          payment?['bookingId'] == booking.id &&
          (payment?['amount'] as num?)?.toDouble() == 1050,
      'id=$paymentId',
    );

    // 3. Verify without a configured provider: honest failure, and
    // NOTHING flips to paid (no false confirmation possible).
    try {
      await repo.verifyPayment(paymentId);
      _check('unconfigured-verify', false, 'unexpected success');
    } catch (e) {
      final afterPayment = await _read('payments', paymentId);
      final afterBooking = await _read('bookings', booking.id);
      _check(
        'unconfigured-verify',
        _err(e).contains('not configured') &&
            afterPayment?['status'] == 'pending' &&
            afterBooking?['status'] == 'pending' &&
            afterBooking?['paymentStatus'] == 'pending',
        _err(e),
      );
    }

    // 4. Succeeded payment replays as succeeded (deduped, no changes).
    final replay = await repo.verifyPayment('payDone8');
    _check(
      'replay-deduped',
      replay.status == 'succeeded' && replay.deduped == true,
    );

    // 5. Stranger cannot verify my payment; states untouched.
    await FirebaseAuth.instance.signOut();
    await _signIn('payu8@test.dev');
    try {
      await repo.verifyPayment(paymentId);
      _check('stranger-verify-denied', false, 'unexpected success');
    } catch (e) {
      _check(
        'stranger-verify-denied',
        _err(e).contains('Not your payment'),
        _err(e),
      );
    }

    // 6. Unauthenticated pending-create denied by rules.
    await FirebaseAuth.instance.signOut();
    try {
      await repo.createPendingPayment(
        bookingId: booking.id,
        touristId: uid,
        amount: 1050,
        providerReference: 'order-x',
      );
      _check('unauth-pending-denied', false, 'unexpected success');
    } catch (_) {
      _check('unauth-pending-denied', true);
    }

    // 7. My Trips shows the booking still pending (regression).
    await _signIn('payt8@test.dev');
    final myTrips = MyTripsCubit();
    final ok = await myTrips.loadRemote(FirebaseAuth.instance.currentUser?.uid);
    _check(
      'mytrips-pending',
      ok &&
          myTrips.state.trips.any(
            (t) => t.bookingId == booking.id && t.status.name == 'upcoming',
          ) &&
          myTrips.isPendingApproval(booking.id),
    );
    await myTrips.close();

    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  } catch (e) {
    debugPrint('PROBE_FATAL $e');
    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  }
}
