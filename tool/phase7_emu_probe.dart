// Phase 7 emulator probe: REAL Flutter SDK (Auth + Firestore + Functions)
// against the LOCAL emulator suite. Run ONLY via:
//   flutter run -d chrome --target tool/phase7_emu_probe.dart
//     --dart-define=TRIPLY_EMULATOR_HOST=127.0.0.1:8090
//     --dart-define=TRIPLY_EMULATOR_AUTH_HOST=127.0.0.1:9099
//     --dart-define=TRIPLY_EMULATOR_FUNCTIONS_HOST=127.0.0.1
//     --dart-define=TRIPLY_EMULATOR_FUNCTIONS_PORT=5001
//     --dart-define=TRIPLY_EMULATOR_PROJECT=demo-phase7
//     --web-browser-flag=--headless=new
//
// (See tool/phase1_emu_probe.dart for why `flutter run` is required.)
// Isolation: DEFAULT app with demo options + emulator overrides applied
// BEFORE any Firebase use. Fixtures come from the out-of-repo
// phase7-seed.js (fixed uids). Production (DefaultFirebaseOptions /
// triply-f9b82) is never referenced here.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:triply/data/firestore/repositories/admin_repository.dart';
import 'package:triply/features/admin_dashboard/d_auth/cubit/admin_auth_cubit.dart';
import 'package:triply/features/admin_dashboard/d_auth/cubit/admin_auth_state.dart';
import 'package:triply/features/common/AuthTourguide/data/tour_guide_auth_service.dart';

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
  defaultValue: 'demo-phase7',
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

Future<void> _signIn(String email, [String password = 'pass1234']) async {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
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
    debugPrint('PROBE_INFO project=$_project fs=$_fsHost');

    final repo = AdminRepository();

    // A. Real admin login/logout/restore through AdminAuthCubit.
    var cubit = AdminAuthCubit();
    var ok = await cubit.login(email: 'admin7@test.dev', password: 'pass1234');
    _check(
      'admin-login',
      ok && cubit.state.session?.email == 'admin7@test.dev',
    );
    await cubit.close();

    cubit = AdminAuthCubit();
    ok = await cubit.login(email: 'admin7@test.dev', password: 'wrongpass');
    _check('admin-wrong-password', ok == false && cubit.state.session == null);
    await cubit.close();

    cubit = AdminAuthCubit();
    ok = await cubit.login(email: 'tourist7@test.dev', password: 'pass1234');
    _check(
      'tourist-login-denied',
      ok == false &&
          cubit.state.errorMessage != null &&
          FirebaseAuth.instance.currentUser == null,
      cubit.state.errorMessage ?? '',
    );
    await cubit.close();

    // Restore: a fresh cubit picks up the persisted admin session.
    await _signIn('admin7@test.dev');
    final restored = AdminAuthCubit();
    var restoredOk = false;
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (restored.state.status == AdminAuthStatus.success) {
        restoredOk = true;
        break;
      }
    }
    _check(
      'admin-restore',
      restoredOk && restored.state.session?.email == 'admin7@test.dev',
    );
    await restored.logout();
    _check(
      'admin-logout',
      restored.state.status == AdminAuthStatus.loggedOut &&
          FirebaseAuth.instance.currentUser == null,
    );
    await restored.close();

    // Pre-auth provisioning attempt is honestly denied.
    final anonCubit = AdminAuthCubit();
    final anonOk = await anonCubit.createAccount(
      name: 'Nobody',
      email: 'nobody@test.dev',
      password: 'pass1234',
    );
    _check(
      'provision-preauth-denied',
      anonOk == false && anonCubit.state.errorMessage != null,
      anonCubit.state.errorMessage ?? '',
    );
    await anonCubit.close();

    // Overview BEFORE provisioning (exact seeded numbers).
    await _signIn('admin7@test.dev');
    final overview = await repo.overviewCounts();
    _check(
      'overview-counts',
      overview.usersTotal == 3 &&
          overview.guidesTotal == 1 &&
          overview.tripsTotal == 3 &&
          overview.bookingsTotal == 2 &&
          overview.pendingGuides == 1 &&
          overview.pendingTrips == 2 &&
          overview.totalPending == 3 &&
          overview.earnings == 100,
      'u=${overview.usersTotal} t=${overview.tripsTotal} '
          'b=${overview.bookingsTotal} e=${overview.earnings}',
    );

    // Provision a new admin while signed in, then use the new session.
    final provisionCubit = AdminAuthCubit();
    final provisionOk = await provisionCubit.createAccount(
      name: 'New Admin',
      email: 'newadmin7@test.dev',
      password: 'newpass123',
    );
    _check(
      'provision-then-login',
      provisionOk &&
          FirebaseAuth.instance.currentUser?.email == 'newadmin7@test.dev',
    );
    await provisionCubit.close();

    // Guide verification queue + decision (closes the Phase 4 loop live).
    final pending = await repo.pendingVerifications();
    _check(
      'pending-queue',
      pending.any((r) => r.guideId == 'guide7') &&
          pending.firstWhere((r) => r.guideId == 'guide7').displayName ==
              'G Seven',
    );
    final status = await repo.decideVerification(
      guideId: 'guide7',
      approved: true,
    );
    _check('decide-approve', status == 'approved', status);
    await FirebaseAuth.instance.signOut();
    await _signIn('guide7@test.dev');
    _check(
      'guide-gate-opens',
      await TourGuideAuthService().isVerificationApproved() == true,
    );
    await FirebaseAuth.instance.signOut();
    await _signIn('admin7@test.dev');
    final history = await repo.recentVerifications();
    _check(
      'history-shows-approved',
      history
          .where((r) => r.guideId == 'guide7')
          .every((r) => r.status == 'approved'),
    );

    // Trip moderation.
    await _signIn('admin7@test.dev');
    final queue = await repo.pendingTrips();
    _check('trip-queue', queue.any((t) => t.id == 'ptrip7'));
    final decided = await repo.decideTripStatus(
      tripId: 'ptrip7',
      decision: 'approved',
    );
    _check('trip-approve', decided == 'approved', decided);
    final rej = await repo.decideTripStatus(
      tripId: 'ptrip7b',
      decision: 'rejected',
      rejectionReason: 'Blurry itinerary',
    );
    _check('trip-reject', rej == 'rejected', rej);
    final all = await repo.allTrips();
    _check(
      'trip-cancel',
      all.length == 3 &&
          await repo.decideTripStatus(
                tripId: 'atrip7',
                decision: 'cancelled',
              ) ==
              'cancelled',
    );

    // Bookings + users + posts + settings.
    final bookings = await repo.recentBookings();
    _check(
      'bookings-list',
      bookings.length == 2 && bookings.every((b) => b.touristId == 'tourist7'),
    );
    final users = await repo.listUsers();
    _check(
      'users-list',
      users.any((u) => u.uid == 'tourist7') &&
          users.any((u) => u.uid == 'guide7') &&
          users.firstWhere((u) => u.uid == 'guide7').typeLabel == 'Guide',
    );
    await repo.setUserActive('tourist7', false);
    var toggled = (await repo.listUsers()).firstWhere(
      (u) => u.uid == 'tourist7',
    );
    final suspendedOk = toggled.isActive == false;
    await repo.setUserActive('tourist7', true);
    toggled = (await repo.listUsers()).firstWhere((u) => u.uid == 'tourist7');
    _check('user-toggle', suspendedOk && toggled.isActive == true);
    final posts = await repo.recentPosts();
    _check('posts-list', posts.any((p) => p.id == 'seed-post7'));
    await repo.deletePost('seed-post7');
    _check(
      'post-delete',
      (await repo.recentPosts()).every((p) => p.id != 'seed-post7'),
    );
    final fee = await repo.serviceFeeRate();
    _check('fee-fallback', fee == 0.05, 'fee=$fee');
    await repo.saveServiceFeeRate(0.12, updatedBy: 'admin7');
    _check('fee-save', await repo.serviceFeeRate() == 0.12);
    try {
      await repo.saveServiceFeeRate(2.0);
      _check('fee-invalid-rejected', false, 'unexpected success');
    } catch (_) {
      _check('fee-invalid-rejected', true);
    }

    // Non-admin enforcement through the real SDK (not UI hiding).
    await FirebaseAuth.instance.signOut();
    await _signIn('tourist7@test.dev');
    try {
      await repo.decideVerification(guideId: 'guide7', approved: true);
      _check('nonadmin-decide-denied', false, 'unexpected success');
    } catch (e) {
      _check(
        'nonadmin-decide-denied',
        e.toString().contains('Admin access'),
        e.toString().split(':').last.trim(),
      );
    }
    try {
      await repo.overviewCounts();
      _check('nonadmin-overview-denied', false, 'unexpected success');
    } catch (e) {
      _check(
        'nonadmin-overview-denied',
        true,
        e.toString().split(':').last.trim(),
      );
    }

    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  } catch (e) {
    debugPrint('PROBE_FATAL $e');
    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  }
}
