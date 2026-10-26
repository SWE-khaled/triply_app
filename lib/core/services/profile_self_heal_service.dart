import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// After a user signs in (or the app restores an existing session), makes
/// sure their own `users/{uid}` document carries `displayName` and
/// `avatarUrl` from Firebase Auth when they are missing.
///
/// Silent, idempotent and never blocks login:
/// - reads only the current user's own document,
/// - writes only what is missing, with a merge update,
/// - never touches `role`, `isActive` or `isApproved` (the rules require
///   them unchanged),
/// - swallows all errors,
/// - a second run finds the fields already written and does nothing
///   (at most one write per session).
class ProfileSelfHealService {
  ProfileSelfHealService({this.firestore, this.auth});

  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;
  String? _attemptedUid;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => auth ?? FirebaseAuth.instance;

  /// Ensures the signed-in user's profile has `displayName` and `avatarUrl`.
  ///
  /// Fire-and-forget: errors are swallowed so login is never delayed.
  Future<void> healAfterSignIn() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      // Auth can emit more than once for one restored/signed-in session.
      // Mark the attempt before I/O so an error remains silent and cannot
      // cause repeated reads or writes while that session is active.
      if (_attemptedUid == user.uid) return;
      _attemptedUid = user.uid;
      final doc = await _db.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data == null) return;

      final updates = decideProfileUpdates(
        currentDisplayName: (data['displayName'] as String?) ?? '',
        currentAvatarUrl: (data['avatarUrl'] as String?) ?? '',
        authDisplayName: user.displayName ?? '',
        authPhotoUrl: user.photoURL ?? '',
      );
      if (updates == null || updates.isEmpty) return;
      await _db
          .collection('users')
          .doc(user.uid)
          .set(updates, SetOptions(merge: true));
    } catch (_) {
      // Never block login — swallow and stay silent.
    }
  }

  /// Allows a later sign-in after an explicit sign-out to make one fresh,
  /// non-blocking self-heal attempt.
  void resetSession() {
    _attemptedUid = null;
  }

  /// Decides the merge updates needed to self-heal a profile. Pure — no
  /// Firebase — so it can be tested with plain strings (a fake seam).
  ///
  /// Returns null when nothing needs writing. Otherwise returns a map with
  /// `displayName` (when missing and Auth has one) and/or `avatarUrl` (when
  /// missing, from the Auth photo URL or '').
  Map<String, dynamic>? decideProfileUpdates({
    required String currentDisplayName,
    required String currentAvatarUrl,
    required String authDisplayName,
    required String authPhotoUrl,
  }) {
    final name = authDisplayName.trim();
    if (currentDisplayName.isEmpty && name.isNotEmpty) {
      final updates = <String, dynamic>{'displayName': name};
      if (currentAvatarUrl.isEmpty) {
        updates['avatarUrl'] = authPhotoUrl.trim();
      }
      return updates;
    }
    return null;
  }
}
