import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/tour_guide_profile.dart';

/// Handles the tour guide's profile, verification and public listing in
/// Firestore.
///
/// Authentication (sign up / sign in / sign out / role guards) lives in the
/// shared `AuthCubit` + `AuthRepository` under `features/common/auth`.
class TourGuideProfileService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  TourGuideProfileService({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  // ──────────────── Public profile ────────────────

  /// Firestore collection holding the public guide profiles.
  static const String guidesCollection = 'guides';

  /// Publishes the public profile of the signed-in guide.
  ///
  /// The tourists browse the approved guides, so the profile has to
  /// exist before they can see the guide. The document is created from
  /// the guide's own profile, and never overwrites the approval the
  /// admin wrote.
  Future<void> ensurePublicProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final profile = await fetchMyProfile();
      if (profile == null) return;
      final doc = _db.collection(guidesCollection).doc(uid);
      final existing = await doc.get();
      if (existing.exists) {
        // Only the fields the guide owns are refreshed — the approval
        // belongs to the admin.
        await doc.set({
          'name': profile.name,
          'location': profile.location,
          'about': profile.about,
          'languages': profile.languages,
          'pricePerHour': profile.pricePerHour,
          'avatarUrl': profile.photoUrl.isNotEmpty
              ? profile.photoUrl
              : (_auth.currentUser?.photoURL ?? ''),
        }, SetOptions(merge: true));
        return;
      }
      await doc.set({
        'guideId': uid,
        'name': profile.name,
        'specialty': '',
        'avatarUrl': profile.photoUrl,
        'coverUrl': '',
        'location': profile.location,
        'about': profile.about,
        'languages': profile.languages,
        'rating': 0,
        'reviewCount': 0,
        'pricePerHour': profile.pricePerHour,
        'currency': 'EGP',
        'isApproved': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // The profile is a convenience — the guide still works without it.
    }
  }

  // ──────────────── Verification ────────────────

  /// Updates the guide's verification submission with their documents.
  ///
  /// The submission lives in its own document (`guideVerifications/{uid}`)
  /// so the security rules can allow-list its keys exactly — the guide
  /// can only ever write a `pending` submission.
  Future<void> submitVerificationDocuments({
    required String idDocumentUrl,
    required String licenseDocumentUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not authenticated');
    }

    await _db.collection('guideVerifications').doc(uid).set({
      'guideId': uid,
      'idDocumentUrl': idDocumentUrl,
      'licenseDocumentUrl': licenseDocumentUrl,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────── Helpers ────────────────

  /// Fetches the signed-in guide's Firestore profile (phone, verification…).
  /// Returns null when signed out or when no profile document exists.
  /// Reads collection 'users', document uid, fields as written by [toMap].
  Future<TourGuideProfile?> fetchMyProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return TourGuideProfile.fromMap(doc.data()!, uid);
  }

  /// Watches the signed-in guide's name, live from Firestore.
  ///
  /// Firebase Auth's `displayName` is empty for e-mail sign-ups, so
  /// `users/{uid}.name` is the source of truth — this emits on every
  /// change (e.g. the guide typing a new name in Edit Profile).
  /// Emits '' when signed out or when the document carries no name.
  Stream<String> watchMyName() async* {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      yield '';
      return;
    }
    try {
      await for (final snapshot
          in _db.collection('users').doc(uid).snapshots()) {
        yield (((snapshot.data()?['name'] as String?) ?? '')).trim();
      }
    } on FirebaseException catch (error) {
      // Signing out revokes access before the dashboard route has finished
      // disposing its listener. Ignore only that expected shutdown race.
      if (error.code == 'permission-denied' && _auth.currentUser?.uid != uid) {
        yield '';
        return;
      }
      rethrow;
    }
  }

  /// Merges profile fields into the guide's Firestore document.
  /// Only non-null values are written; everything else is preserved.
  Future<void> updateProfileFields({
    String? name,
    String? about,
    String? location,
    String? phone,
    String? photoUrl,
    double? pricePerHour,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not authenticated');
    }
    final data = <String, dynamic>{
      'name': ?name,
      'about': ?about,
      'location': ?location,
      'phone': ?phone,
      'photoUrl': ?photoUrl,
      'pricePerHour': ?pricePerHour,
    };
    if (data.isEmpty) return;
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  /// Whether the signed-in guide's verification is approved.
  ///
  /// Reads guideVerifications/{uid}.status; anything other than
  /// 'approved' (including a missing document) counts as unverified, so
  /// the verification banner keeps showing until approval.
  Future<bool> isVerificationApproved() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      final doc = await _db.collection('guideVerifications').doc(uid).get();
      final data = doc.data();
      if (data != null && data['status'] == 'approved') return true;

      // Check users/{uid} as well so approval is permanently honored
      final userDoc = await _db.collection('users').doc(uid).get();
      final userData = userDoc.data();
      if (userData != null &&
          (userData['isApproved'] == true ||
              userData['status'] == 'approved')) {
        return true;
      }
      return false;
    } catch (_) {
      // Offline or no access — treat it as not approved.
      return false;
    }
  }

  /// Watches the signed-in guide's verification status in real time.
  ///
  /// Emits `true` when approved in either `guideVerifications/{uid}` or `users/{uid}`,
  /// `false` otherwise.
  Stream<bool> watchVerificationStatus() async* {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      yield false;
      return;
    }
    try {
      await for (final snapshot
          in _db.collection('guideVerifications').doc(uid).snapshots()) {
        final data = snapshot.data();
        if (data != null && data['status'] == 'approved') {
          yield true;
        } else {
          final userDoc = await _db.collection('users').doc(uid).get();
          final userData = userDoc.data();
          yield userData != null &&
              (userData['isApproved'] == true ||
                  userData['status'] == 'approved');
        }
      }
    } on FirebaseException catch (error) {
      // Signing out revokes access before the listener is torn down.
      if (error.code == 'permission-denied' && _auth.currentUser?.uid != uid) {
        yield false;
        return;
      }
      rethrow;
    }
  }

  /// Watches the signed-in guide's verification submission live: the
  /// whole `guideVerifications/{uid}` document.
  ///
  /// `null` when signed out or the submission does not exist yet.
  /// The verification screen listens to this so "under review /
  /// approved / rejected (+ reason)" always reflects the admin's
  /// decision the moment it is written.
  Stream<Map<String, dynamic>?> watchVerificationSubmission() async* {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      yield null;
      return;
    }
    try {
      await for (final snapshot
          in _db.collection('guideVerifications').doc(uid).snapshots()) {
        final data = snapshot.data();
        if (data != null && data['status'] == 'approved') {
          yield data;
        } else {
          final userDoc = await _db.collection('users').doc(uid).get();
          final userData = userDoc.data();
          if (userData != null &&
              (userData['isApproved'] == true ||
                  userData['status'] == 'approved')) {
            final merged = Map<String, dynamic>.of(data ?? {});
            merged['status'] = 'approved';
            yield merged;
          } else {
            yield data;
          }
        }
      }
    } on FirebaseException catch (error) {
      // Signing out revokes access before the listener is torn down.
      if (error.code == 'permission-denied' && _auth.currentUser?.uid != uid) {
        yield null;
        return;
      }
      rethrow;
    }
  }

  /// Fetches the role of the currently signed-in user.
  Future<String?> getCurrentUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }
}
