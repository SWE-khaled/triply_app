import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/remote/firestore_service.dart';
import 'package:triply/core/data/repositories/admin_guides_repository.dart';

class FakeFirestoreService extends FirestoreService {
  final Map<String, Map<String, dynamic>> storage = {};
  bool throwOnVerifications = false;

  String _key(String path, String id) => '$path/$id';

  @override
  Future<Map<String, dynamic>?> readDoc(String path, String id) async {
    return storage[_key(path, id)];
  }

  @override
  Future<void> writeDoc(
    String path,
    String id,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    if (throwOnVerifications && path == AdminGuidesRepository.verificationsCollection) {
      throw Exception('Permission denied on guideVerifications');
    }
    final key = _key(path, id);
    if (merge && storage.containsKey(key)) {
      storage[key]!.addAll(Map<String, dynamic>.of(data));
    } else {
      storage[key] = Map<String, dynamic>.of(data);
    }
  }

  @override
  Future<void> deleteDoc(String path, String id) async {
    storage.remove(_key(path, id));
  }
}

void main() {
  group('AdminGuidesRepository approval persistence', () {
    late FakeFirestoreService fakeFirestore;
    late AdminGuidesRepository repository;

    setUp(() {
      fakeFirestore = FakeFirestoreService();
      repository = AdminGuidesRepository(firestore: fakeFirestore);
    });

    test('decideVerification successfully persists approval to users collection', () async {
      const guideId = 'guide_123';

      final ok = await repository.decideVerification(
        guideId: guideId,
        approve: true,
      );

      expect(ok, isTrue);

      final userDoc = await fakeFirestore.readDoc(
        AdminGuidesRepository.usersCollection,
        guideId,
      );
      expect(userDoc, isNotNull);
      expect(userDoc!['isApproved'], isTrue);
      expect(userDoc['status'], 'approved');
      expect(userDoc['isActive'], isTrue);
      expect(userDoc['verification']['reviewStatus'], 'approved');

      final publicProfile = await fakeFirestore.readDoc(
        AdminGuidesRepository.guidesCollection,
        guideId,
      );
      expect(publicProfile, isNotNull);
      expect(publicProfile!['isApproved'], isTrue);
      expect(publicProfile['status'], 'approved');
    });

    test('decideVerification persists approval to users even when guideVerifications throws', () async {
      const guideId = 'guide_unverified_docs';
      fakeFirestore.throwOnVerifications = true;

      final ok = await repository.decideVerification(
        guideId: guideId,
        approve: true,
      );

      // Must succeed in persisting to users collection despite verification failure
      expect(ok, isTrue);

      final userDoc = await fakeFirestore.readDoc(
        AdminGuidesRepository.usersCollection,
        guideId,
      );
      expect(userDoc, isNotNull);
      expect(userDoc!['isApproved'], isTrue);
      expect(userDoc['status'], 'approved');
      expect(userDoc['isActive'], isTrue);
    });

    test('suspendGuide persists suspension to users and guides collection', () async {
      const guideId = 'guide_456';

      final ok = await repository.suspendGuide(guideId);
      expect(ok, isTrue);

      final userDoc = await fakeFirestore.readDoc(
        AdminGuidesRepository.usersCollection,
        guideId,
      );
      expect(userDoc, isNotNull);
      expect(userDoc!['isApproved'], isFalse);
      expect(userDoc['status'], 'suspended');
      expect(userDoc['isActive'], isFalse);
      expect(userDoc['verification']['reviewStatus'], 'rejected');
    });
  });
}

