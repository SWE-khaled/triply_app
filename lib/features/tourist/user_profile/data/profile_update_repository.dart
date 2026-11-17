import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../common/auth/data/auth_repository.dart';

/// The single Firestore/Auth write used by the Edit profile sheet.
class ProfileUpdateRepository {
  ProfileUpdateRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = authRepository ?? AuthRepository();

  final FirebaseFirestore _firestore;
  final AuthRepository _auth;

  Future<void> update({
    required String uid,
    required String name,
    required String city,
    required String country,
    required String bio,
    required String photo,
    required bool updatePhoto,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'fullName': name,
      'displayName': name,
      'avatarUrl': photo,
      'city': city,
      'country': country,
      'bio': bio,
    }, SetOptions(merge: true));

    final user = _auth.currentUser;
    await user?.updateDisplayName(name);
    if (updatePhoto) {
      await user?.updatePhotoURL(photo.isEmpty ? null : photo);
    }
  }
}
