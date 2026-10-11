import 'package:flutter_test/flutter_test.dart';
import 'package:triply/data/firestore/models/app_user_doc.dart';
import 'package:triply/features/common/AuthTourguide/data/tour_guide_auth_service.dart';
import 'package:triply/features/tourist/UserProfile/cubit/profile_cubit.dart';

/// Focused Phase 4 unit tests: profile model mapping (incl. legacy field
/// drift between tourist `fullName` and guide `name`) and the pure
/// in-memory tourist preference cubit. Firebase-touching auth/profile
/// flows are covered by emulator tests + the real-SDK probe instead:
/// `FirebaseAuth`/`FirebaseFirestore` channels don't exist on the VM.
/// These are UNIT tests, not integration tests.
void main() {
  group('AppUserDoc mapping', () {
    test('reads legacy guide `name` key and defaults role to tourist', () {
      final doc = AppUserDoc.fromMap({
        'name': 'Omar',
        'email': 'o@t.dev',
        'phone': '+2010',
      }, 'u1');
      expect(doc.uid, 'u1');
      expect(doc.fullName, 'Omar');
      expect(doc.role, 'tourist');
      expect(doc.isActive, isTrue);
    });

    test('explicit disabled flag survives mapping', () {
      final off = AppUserDoc.fromMap({
        'fullName': 'N',
        'isActive': false,
      }, 'u2');
      expect(off.isActive, isFalse);
      final missing = AppUserDoc.fromMap({'fullName': 'N'}, 'u3');
      expect(missing.isActive, isTrue);
    });

    test('avatarUrl reads key variants', () {
      expect(AppUserDoc.fromMap({'avatarUrl': 'a'}, 'u').avatarUrl, 'a');
      expect(AppUserDoc.fromMap({'photoUrl': 'p'}, 'u').avatarUrl, 'p');
      expect(AppUserDoc.fromMap({}, 'u').avatarUrl, isEmpty);
    });

    test('client payload excludes role/isActive', () {
      final payload = const AppUserDoc(
        uid: 'u',
        fullName: 'N',
        email: 'e',
        phone: 'p',
        role: 'admin',
      ).toClientMap();
      expect(payload['fullName'], 'N');
      expect(payload.containsKey('role'), isFalse);
      expect(payload.containsKey('isActive'), isFalse);
    });
  });

  group('TourGuideProfile mapping', () {
    test('fromMap tolerates missing keys with guide defaults', () {
      final p = TourGuideProfile.fromMap({'name': 'G'}, 'g1');
      expect(p.uid, 'g1');
      expect(p.role, 'guide');
      expect(p.isApproved, isFalse);
      expect(p.languages, isEmpty);
      expect(p.about, isEmpty);
    });
  });

  group('ProfileCubit preferences (in-memory)', () {
    test('initial language default, toggle + set language', () {
      final cubit = ProfileCubit();
      expect(cubit.state.selectedLanguage, isNotEmpty);
      expect(cubit.state.notificationsEnabled, isTrue);
      cubit.toggleNotifications(false);
      expect(cubit.state.notificationsEnabled, isFalse);
      cubit.setLanguage(cubit.languages.last);
      expect(cubit.state.selectedLanguage, cubit.languages.last);
      // Unknown languages are ignored (no invalid state).
      cubit.setLanguage('Klingon');
      expect(cubit.state.selectedLanguage, cubit.languages.last);
      cubit.close();
    });

    test('stats expose trips count with mock baselines', () {
      final cubit = ProfileCubit();
      expect(cubit.stats['trips'], isNotNull);
      expect(cubit.emergencyContacts, isNotEmpty);
      cubit.close();
    });
  });
}
