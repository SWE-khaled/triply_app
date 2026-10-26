import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A cross-role sign-in attempt: the account belongs to the other app.
///
/// Thrown when the signed-in account is recorded in Firestore as a
/// `guide` — the session is signed out immediately so nothing of it
/// survives. `AuthCubit` shows [message] through `getErrorMessage`.
class RoleMismatchException implements Exception {
  final String message;

  RoleMismatchException(this.message);

  @override
  String toString() => message;
}

/// Talks to Firebase directly. No UI logic here.
class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(fullName);
    // Best-effort user profile save (never fails sign-up when offline
    // or when Firestore rules/connection are unavailable).
    try {
      final uid = credential.user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fullName': fullName,
          'displayName': fullName,
          'email': email,
          // The rules read the role with a dot-access, so the field has
          // to be there — without it the whole document is refused and
          // the profile never exists.
          'role': 'tourist',
          'avatarUrl': '',
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
    return credential;
  }

  /// Saved phone number (e.g. +2010...) or null when absent/unreachable.
  Future<String?> getUserPhone(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final phone = doc.data()?['phone'];
      if (phone is String && phone.trim().isNotEmpty) return phone.trim();
    } catch (_) {}
    return null;
  }

  /// Phone of a registered guide matched by display name (same name
  /// matching the trip screens already use), or null when no registered
  /// guide with a saved phone exists. Never invents a number.
  Future<String?> getGuidePhoneByName(String guideName) async {
    final name = guideName.trim();
    if (name.isEmpty) return null;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'guide')
          .get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if ((data['name'] as String?)?.trim() == name) {
          final phone = data['phone'];
          if (phone is String && phone.trim().isNotEmpty) {
            return phone.trim();
          }
          return null;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Reject the guide accounts right away: the session never reaches
    // the tourist app.
    await _ensureTouristRole(credential.user?.uid);
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _firebaseAuth.signInWithCredential(credential);
    await _ensureTouristRole(result.user?.uid);
    return result;
  }

  /// Blocks every non-tourist account out of the tourist app.
  ///
  /// Reads `users/{uid}.role` right after a successful Firebase sign-in;
  /// when the account is a guide (or an admin) the session is dropped at
  /// once and a [RoleMismatchException] carries the reason to the UI. A
  /// missing document (brand-new Google account, offline read) counts as
  /// a tourist — e-mail sign-up always writes `role: 'tourist'` itself.
  Future<void> _ensureTouristRole(String? uid) async {
    if (uid == null) return;
    final role = await _roleOf(uid);
    if (role != null && role != 'tourist') {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      throw RoleMismatchException(
        role == 'guide'
            ? 'This account is registered as a guide — please use the guide app to sign in.'
            : 'This account is not a tourist account — it cannot sign in here.',
      );
    }
  }

  /// The `role` stored on the user's Firestore document, or null.
  Future<String?> _roleOf(String? uid) async {
    if (uid == null) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return doc.data()?['role'] as String?;
    } catch (_) {
      // Offline or rules refused the read: cannot tell, treat as tourist.
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Converts sign-in failures into readable messages for the UI.
  String getErrorMessage(Object error) {
    if (error is RoleMismatchException) {
      return error.message;
    }
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'This email is already in use';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'Password is too weak (min 6 characters)';
        default:
          return error.message ?? 'An unexpected error occurred';
      }
    }
    return error.toString();
  }
}
