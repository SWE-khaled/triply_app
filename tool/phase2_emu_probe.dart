// Phase 2 emulator probe: REAL Flutter Firebase SDK (Auth + Firestore +
// Functions) against the LOCAL emulator suite. Run ONLY via:
//   flutter run -d chrome --target tool/phase2_emu_probe.dart
//     --dart-define=TRIPLY_EMULATOR_HOST=127.0.0.1:8090
//     --dart-define=TRIPLY_EMULATOR_AUTH_HOST=127.0.0.1:9099
//     --dart-define=TRIPLY_EMULATOR_FUNCTIONS_HOST=127.0.0.1
//     --dart-define=TRIPLY_EMULATOR_FUNCTIONS_PORT=5001
//     --dart-define=TRIPLY_EMULATOR_PROJECT=demo-phase2
//     --web-browser-flag=--headless=new
//
// (See tool/phase1_emu_probe.dart for why `flutter run` is required.)
// Isolation: DEFAULT app with demo options + emulator overrides applied
// BEFORE any Firebase/Firestore/Functions/Auth use. Production
// (DefaultFirebaseOptions / triply-f9b82) is never referenced here.
// Fixtures come from the out-of-repo phase2-seed.js (admin SDK).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:triply/core/data/my_bookings_public.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import 'package:triply/features/tourist/booking/cubit/booking_cubit.dart';
import 'package:triply/features/tourist/booking_public/cubit/booking_public_cubit.dart';
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
  defaultValue: 'demo-phase2',
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

const _tripA = Trip(
  id: 'bk-trip-a',
  title: 'Probe Nile Day',
  dateLabel: 'Oct 15, 2026 · 6:00 AM',
  guideName: 'Probe Guide',
  peopleCount: 1,
  priceEgp: 1000,
  imageUrl: '',
  status: TripStatus.upcoming,
  category: 'historical',
  capacity: 5,
);

Future<void> main() async {
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
    debugPrint('PROBE_INFO project=$_project fs=$_fsHost fn=$_fnHost:$_fnPort');

    // Tourist identity from the Auth emulator (real ID tokens).
    const email = 'probe-tourist@test.dev';
    const password = 'pass1234';
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    debugPrint('PROBE_INFO tourist=$uid');

    final repo = BookingsRepository();
    const keyA = 'probe-pub-key-0001';

    // 1. Public booking success: server totals, pending/pending.
    BookingDoc? first;
    try {
      first = await repo.createPublic(
        tripId: 'bk-trip-a',
        tripDate: null,
        seats: 2,
        idempotencyKey: keyA,
        specialRequests: 'window',
      );
      _check(
        'public-success',
        first.totalAmount == 2100 &&
            first.unitPrice == 1000 &&
            first.serviceFee == 100 &&
            first.status == 'pending' &&
            first.paymentStatus == 'pending' &&
            first.currency == 'EGP' &&
            first.id.isNotEmpty,
        'total=${first.totalAmount} id=${first.id}',
      );
    } catch (e) {
      _check('public-success', false, _err(e));
    }

    // 2. Capacity actually reserved (1 + 2 = 3 booked).
    try {
      final trip = await TripsDatasource().getById('bk-trip-a');
      _check(
        'capacity-reserved',
        trip != null && trip.bookedSeats == 3,
        'bookedSeats=${trip?.bookedSeats}',
      );
    } catch (e) {
      _check('capacity-reserved', false, _err(e));
    }

    // 3. Same-key retry returns the SAME booking (no double charge).
    try {
      final retry = await repo.createPublic(
        tripId: 'bk-trip-a',
        tripDate: null,
        seats: 2,
        idempotencyKey: keyA,
        specialRequests: 'window',
      );
      final trip = await TripsDatasource().getById('bk-trip-a');
      _check(
        'same-key-dedupe',
        retry.id == first?.id && (trip?.bookedSeats ?? -1) == 3,
        'id=${retry.id} bookedSeats=${trip?.bookedSeats}',
      );
    } catch (e) {
      _check('same-key-dedupe', false, _err(e));
    }

    // 4. Same key + different seats is rejected (never re-resolved).
    try {
      await repo.createPublic(
        tripId: 'bk-trip-a',
        tripDate: null,
        seats: 1,
        idempotencyKey: keyA,
        specialRequests: 'window',
      );
      _check('same-key-changed-rejected', false, 'unexpected success');
    } catch (e) {
      _check('same-key-changed-rejected', _err(e).isNotEmpty, _err(e));
    }

    // 5. Over-capacity rejected with seats-left message.
    try {
      await repo.createPublic(
        tripId: 'bk-trip-full',
        tripDate: null,
        seats: 1,
        idempotencyKey: 'probe-pub-key-full1',
      );
      _check('over-capacity-rejected', false, 'unexpected success');
    } catch (e) {
      _check(
        'over-capacity-rejected',
        _err(e).contains('Only 0 seats left'),
        _err(e),
      );
    }

    // 6. Unknown trip rejected.
    try {
      await repo.createPublic(
        tripId: 'bk-nope',
        tripDate: null,
        seats: 1,
        idempotencyKey: 'probe-pub-key-nope1',
      );
      _check('unknown-trip-rejected', false, 'unexpected success');
    } catch (e) {
      _check(
        'unknown-trip-rejected',
        _err(e).contains('Trip not found'),
        _err(e),
      );
    }

    // 7. Unauthenticated caller rejected (server requireAuth).
    try {
      await FirebaseAuth.instance.signOut();
      await repo.createPublic(
        tripId: 'bk-trip-a',
        tripDate: null,
        seats: 1,
        idempotencyKey: 'probe-pub-key-anon1',
      );
      _check('unauth-rejected', false, 'unexpected success');
    } catch (e) {
      _check('unauth-rejected', _err(e).contains('Please sign in'), _err(e));
    } finally {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }

    // 8. Private booking success with guide-profile price (250*2h*2=1050).
    try {
      final priv = await repo.createPrivate(
        guideId: 'guide-probe',
        appointmentAt: DateTime.utc(2026, 11, 2, 10),
        timeSlot: '9:00 AM',
        travelers: 2,
        durationHours: 2,
        idempotencyKey: 'probe-pvt-key-0001',
      );
      _check(
        'private-success',
        priv.totalAmount == 1050 &&
            priv.unitPrice == 250 &&
            priv.status == 'pending' &&
            priv.paymentStatus == 'pending',
        'total=${priv.totalAmount}',
      );
    } catch (e) {
      _check('private-success', false, _err(e));
    }

    // 9. Private unknown guide rejected.
    try {
      await repo.createPrivate(
        guideId: 'guide-ghost',
        appointmentAt: DateTime.utc(2026, 11, 2, 10),
        timeSlot: '',
        travelers: 1,
        durationHours: 1,
        idempotencyKey: 'probe-pvt-key-ghost1',
      );
      _check('private-unknown-guide', false, 'unexpected success');
    } catch (e) {
      _check(
        'private-unknown-guide',
        _err(e).contains('Guide not found'),
        _err(e),
      );
    }

    // 10. Public cubit end-to-end through the real repo.
    try {
      final cubit = BookingPublicCubit()..changeSeats(1);
      final doc = await cubit.submitBooking(
        repository: repo,
        uid: FirebaseAuth.instance.currentUser?.uid,
        trip: _tripA,
      );
      _check(
        'cubit-public-submit',
        doc != null && doc.totalAmount == 1050 && doc.seats == 1,
        'total=${doc?.totalAmount}',
      );
      await cubit.close();
    } catch (e) {
      _check('cubit-public-submit', false, _err(e));
    }

    // 11. Private cubit end-to-end through the real repo.
    try {
      final cubit = BookingCubit(guideId: 'guide-probe');
      cubit.setDate(DateTime.utc(2026, 11, 3, 10));
      cubit.setTimeSlot('9:00 AM');
      cubit.setDuration('4 hours');
      final doc = await cubit.submitBooking(
        repository: repo,
        uid: FirebaseAuth.instance.currentUser?.uid,
      );
      // 250 x 4h x 2 travelers = 2000 + 5% = 2100.
      _check(
        'cubit-private-submit',
        doc != null && doc.totalAmount == 2100,
        'total=${doc?.totalAmount}',
      );
      await cubit.close();
    } catch (e) {
      _check('cubit-private-submit', false, _err(e));
    }

    // 12. Submits never write local mock bookings by themselves.
    _check(
      'no-local-record',
      MyBookingsPublic.bookedIds.isEmpty,
      'local=${MyBookingsPublic.bookedIds.length}',
    );

    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  } catch (e) {
    debugPrint('PROBE_FATAL $e');
    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  }
}
