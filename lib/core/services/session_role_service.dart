import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Reads the session data the launch screen needs: the Firebase user, the
/// role stored on `users/{uid}` and the guide verification decision.
class SessionRoleService {
  SessionRoleService({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  static const Duration _timeout = Duration(seconds: 4);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  /// Waits for the first Firebase auth event so a restored session is not
  /// missed (on web the restore can arrive after the first frame). Falls
  /// back to the synchronously available current user on timeout.
  Future<User?> waitForAuth() async {
    try {
      return await _auth.authStateChanges().first.timeout(_timeout);
    } catch (_) {
      return _auth.currentUser;
    }
  }

  /// The `role` stored on the user's Firestore document, or null when it
  /// cannot be read (offline, missing document, rules).
  Future<String?> roleOf(String uid) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(_timeout);
      final role = doc.data()?['role'];
      return role is String && role.trim().isNotEmpty ? role.trim() : null;
    } catch (_) {
      return null;
    }
  }

  /// Whether the guide is approved.
  ///
  /// Returns `true` / `false` when Firestore answered, and `null` when it
  /// could not be reached so the caller can fall back to its cache.
  Future<bool?> checkGuideApproved(String uid) async {
    try {
      final verification = await _db
          .collection('guideVerifications')
          .doc(uid)
          .get()
          .timeout(_timeout);
      if (verification.data()?['status'] == 'approved') return true;

      final userDoc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(_timeout);
      final data = userDoc.data();
      if (data == null) return false;
      return data['isApproved'] == true || data['status'] == 'approved';
    } catch (_) {
      return null;
    }
  }
}
