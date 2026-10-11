// Phase 4 emulator probe: REAL Flutter SDK (Auth + Firestore) against the
// LOCAL emulator suite. Run ONLY via:
//   flutter run -d chrome --target tool/phase4_emu_probe.dart
//     --dart-define=TRIPLY_EMULATOR_HOST=127.0.0.1:8090
//     --dart-define=TRIPLY_EMULATOR_AUTH_HOST=127.0.0.1:9099
//     --dart-define=TRIPLY_EMULATOR_PROJECT=demo-phase4
//     --web-browser-flag=--headless=new
//
// (See tool/phase1_emu_probe.dart for why `flutter run` is required.)
// Isolation: DEFAULT app with demo options + emulator overrides applied
// BEFORE any Firebase use. Fixtures come from the out-of-repo
// phase4-seed.js (fixed uids). Production (DefaultFirebaseOptions /
// triply-f9b82) is never referenced here. Google sign-in cannot run
// against an emulator (needs real Google) and is covered by code review +
// the shared `_ensureUserDoc` path exercised below via email sign-up.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:triply/core/data/my_bookings_public.dart';
import 'package:triply/data/firestore/datasources/guide_profiles_datasource.dart';
import 'package:triply/data/firestore/datasources/users_datasource.dart';
import 'package:triply/features/common/AuthTourguide/data/tour_guide_auth_service.dart';
import 'package:triply/features/common/AuthTourist/data/auth_repository.dart';
import 'package:triply/features/common/AuthTourist/providers/auth_provider.dart'
    as tourist_auth;

const _fsHost = String.fromEnvironment(
  'TRIPLY_EMULATOR_HOST',
  defaultValue: '127.0.0.1:8090',
);
const _authHost = String.fromEnvironment(
  'TRIPLY_EMULATOR_AUTH_HOST',
  defaultValue: '127.0.0.1:9099',
);
const _project = String.fromEnvironment(
  'TRIPLY_EMULATOR_PROJECT',
  defaultValue: 'demo-phase4',
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
    debugPrint('PROBE_INFO project=$_project fs=$_fsHost');

    final users = UsersDatasource();
    final guides = GuideProfilesDatasource();
    final authRepo = AuthRepository();
    final guideSvc = TourGuideAuthService();
    final stamp = DateTime.now().millisecondsSinceEpoch;

    // 1. Tourist email sign-up creates the users doc (role/isActive).
    final emailA = 'phase4a-$stamp@test.dev';
    final cred = await authRepo.signUpWithEmail(
      email: emailA,
      password: 'pass1234',
      fullName: 'Probe Tourist',
      phone: '+201001234567',
    );
    final uidA = cred.user!.uid;
    final docA = await users.getById(uidA);
    _check(
      'tourist-signup-doc',
      docA != null &&
          docA.role == 'tourist' &&
          docA.isActive &&
          docA.fullName == 'Probe Tourist' &&
          docA.phone == '+201001234567',
      'role=${docA?.role}',
    );

    // 2. Sign-in works after sign-out (state restore within session).
    await authRepo.signOut();
    await authRepo.signInWithEmail(email: emailA, password: 'pass1234');
    _check('tourist-signin', FirebaseAuth.instance.currentUser?.uid == uidA);

    // 3. Disabled account is signed back out with a clear error.
    try {
      await authRepo.signInWithEmail(
        email: 'disabled@test.dev',
        password: 'pass1234',
      );
      _check('disabled-blocked', false, 'unexpected success');
    } catch (e) {
      _check(
        'disabled-blocked',
        e.toString().contains('disabled') &&
            FirebaseAuth.instance.currentUser == null,
        e.toString().split(':').last.trim(),
      );
    }
    await authRepo.signInWithEmail(email: emailA, password: 'pass1234');

    // 4. Tourist profile sync: Auth + users/ round-trip (edit-sheet path).
    await FirebaseAuth.instance.currentUser!.updateDisplayName(
      'Probe Tourist 2',
    );
    await users.updateFields(uidA, {
      'fullName': 'Probe Tourist 2',
      'avatarUrl': 'http://avatar/2',
    });
    final docA2 = await users.getById(uidA);
    _check(
      'tourist-profile-sync',
      FirebaseAuth.instance.currentUser!.displayName == 'Probe Tourist 2' &&
          docA2?.fullName == 'Probe Tourist 2' &&
          docA2?.avatarUrl == 'http://avatar/2' &&
          docA2?.role == 'tourist' &&
          docA2?.isActive == true,
    );

    // 5. Logout clears the session booking store + Firebase session.
    MyBookingsPublic.record('probe-trip', 1, totalPaid: 5);
    final provider = tourist_auth.AuthProvider();
    await provider.signOut();
    _check(
      'logout-clears',
      FirebaseAuth.instance.currentUser == null &&
          MyBookingsPublic.bookedIds.isEmpty,
    );
    await authRepo.signInWithEmail(email: emailA, password: 'pass1234');

    // 6. Guide registration writes users (role guide) + public mirror.
    final emailG = 'phase4g-$stamp@test.dev';
    final gCred = await guideSvc.registerGuide(
      name: 'Probe Guide',
      email: emailG,
      password: 'pass1234',
      phone: '+201009998877',
      licenseNumber: '',
      languages: const ['Arabic', 'English'],
    );
    final uidG = gCred.user!.uid;
    final gDoc = await users.getById(uidG);
    final gMirror = await guides.getByUserId(uidG);
    _check(
      'guide-register-docs',
      gDoc != null &&
          gDoc.role == 'guide' &&
          gMirror != null &&
          gMirror.displayName == 'Probe Guide' &&
          gMirror.contactPhone == '+201009998877',
    );

    // 7. Verification submit writes pending to both docs; gate stays shut.
    await guideSvc.submitVerificationDocuments(
      idDocumentUrl: 'http://doc/id',
      licenseDocumentUrl: 'http://doc/lic',
    );
    final pending = await guideSvc.getVerificationStatus();
    _check(
      'verification-submit-pending',
      pending != null && pending.status == 'pending',
      'status=${pending?.status}',
    );
    _check(
      'pending-not-approved',
      await guideSvc.isVerificationApproved() == false,
    );

    // 8. Rejected fixture surfaces status + reason, never approval.
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'rejected@test.dev',
      password: 'pass1234',
    );
    final rej = await guideSvc.getVerificationStatus();
    _check(
      'rejected-status',
      rej != null &&
          rej.status == 'rejected' &&
          rej.rejectionReason == 'Blurry photo' &&
          await guideSvc.isVerificationApproved() == false,
      '${rej?.status}/${rej?.rejectionReason}',
    );

    // 9. Approved fixture opens the gate (canonical source).
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'approved@test.dev',
      password: 'pass1234',
    );
    _check(
      'approved-opens-gate',
      await guideSvc.isVerificationApproved() == true,
    );

    // 10. Client self-approve is rejected by rules (real SDK proof).
    try {
      await FirebaseFirestore.instance
          .collection('guideVerifications')
          .doc('guideok')
          .set({'status': 'approved'}, SetOptions(merge: true));
      _check('self-approve-denied', false, 'unexpected success');
    } catch (e) {
      _check(
        'self-approve-denied',
        e.toString().contains('permission-denied'),
        e.toString().split(']').first,
      );
    }

    // 11. Spoofed legacy `users.verification.approved` grants NOTHING.
    // (Signed back in as the fresh guide first: they own uidG, so the
    // legacy write itself is allowed — but the gate must stay shut.)
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailG,
      password: 'pass1234',
    );
    await FirebaseFirestore.instance.collection('users').doc(uidG).set({
      'verification': {'reviewStatus': 'approved'},
    }, SetOptions(merge: true));
    _check(
      'legacy-spoof-grants-nothing',
      await guideSvc.isVerificationApproved() == false,
    );

    // 12. Guide profile edit syncs users/ + guideProfiles/ and reloads.
    await FirebaseAuth.instance.currentUser!.updateDisplayName('Probe Guide 2');
    await guideSvc.updateProfileFields(
      name: 'Probe Guide 2',
      about: 'Nile expert',
      location: 'Aswan',
      phone: '+201008887776',
    );
    await guides.updatePublicFields(
      uidG,
      displayName: 'Probe Guide 2',
      contactPhone: '+201008887776',
      about: 'Nile expert',
      location: 'Aswan',
      coverUrl: 'http://avatar/g2',
    );
    final reloaded = await guideSvc.fetchMyProfile();
    final reloadedMirror = await guides.getByUserId(uidG);
    _check(
      'guide-profile-sync',
      reloaded?.name == 'Probe Guide 2' &&
          reloaded?.about == 'Nile expert' &&
          reloaded?.location == 'Aswan' &&
          reloaded?.phone == '+201008887776' &&
          reloadedMirror?.displayName == 'Probe Guide 2' &&
          reloadedMirror?.contactPhone == '+201008887776' &&
          reloadedMirror?.coverUrl == 'http://avatar/g2' &&
          reloadedMirror?.isVerified == false,
    );

    // 13. Reload persistence across sign-out/sign-in.
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailG,
      password: 'pass1234',
    );
    final relogin = await guideSvc.fetchMyProfile();
    _check(
      'reload-persists',
      relogin?.name == 'Probe Guide 2' &&
          FirebaseAuth.instance.currentUser?.displayName == 'Probe Guide 2',
    );

    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  } catch (e) {
    debugPrint('PROBE_FATAL $e');
    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  }
}
