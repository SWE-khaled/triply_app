import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/services/profile_self_heal_service.dart';

/// Pure decision logic: given the current Firestore fields and the Firebase
/// Auth values, what merge updates (if any) should be written? No real
/// Firestore is involved — a fake seam.
void main() {
  late ProfileSelfHealService service;

  setUp(() => service = ProfileSelfHealService());

  Map<String, dynamic>? decide({
    required String currentDisplayName,
    required String currentAvatarUrl,
    required String authDisplayName,
    required String authPhotoUrl,
  }) {
    return service.decideProfileUpdates(
      currentDisplayName: currentDisplayName,
      currentAvatarUrl: currentAvatarUrl,
      authDisplayName: authDisplayName,
      authPhotoUrl: authPhotoUrl,
    );
  }

  group('write needed', () {
    test('displayName missing, auth has name and photo → both written', () {
      final updates = decide(
        currentDisplayName: '',
        currentAvatarUrl: '',
        authDisplayName: 'Ada Lovelace',
        authPhotoUrl: 'https://example.com/ada.jpg',
      );
      expect(updates, isNotNull);
      expect(updates!['displayName'], 'Ada Lovelace');
      expect(updates['avatarUrl'], 'https://example.com/ada.jpg');
    });

    test('displayName missing, auth has name but no photo → avatarUrl empty', () {
      final updates = decide(
        currentDisplayName: '',
        currentAvatarUrl: '',
        authDisplayName: 'Ada Lovelace',
        authPhotoUrl: '',
      );
      expect(updates, isNotNull);
      expect(updates!['displayName'], 'Ada Lovelace');
      expect(updates['avatarUrl'], '');
    });

    test('displayName missing, avatar already present → only displayName', () {
      final updates = decide(
        currentDisplayName: '',
        currentAvatarUrl: 'https://example.com/ada.jpg',
        authDisplayName: 'Ada Lovelace',
        authPhotoUrl: 'https://example.com/new.jpg',
      );
      expect(updates, isNotNull);
      expect(updates!['displayName'], 'Ada Lovelace');
      expect(updates.containsKey('avatarUrl'), isFalse);
    });
  });

  group('no write needed', () {
    test('displayName already present → null (never touches role)', () {
      expect(
        decide(
          currentDisplayName: 'Ada Lovelace',
          currentAvatarUrl: '',
          authDisplayName: 'Someone Else',
          authPhotoUrl: '',
        ),
        isNull,
      );
    });

    test('displayName missing but Auth has no name → null', () {
      expect(
        decide(
          currentDisplayName: '',
          currentAvatarUrl: '',
          authDisplayName: '',
          authPhotoUrl: '',
        ),
        isNull,
      );
    });

    test('whitespace-only Auth name counts as absent → null', () {
      expect(
        decide(
          currentDisplayName: '',
          currentAvatarUrl: '',
          authDisplayName: '   ',
          authPhotoUrl: 'https://example.com/ada.jpg',
        ),
        isNull,
      );
    });
  });
}
