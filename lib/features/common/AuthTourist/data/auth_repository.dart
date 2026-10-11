import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    await _ensureUserDoc(
      uid: credential.user?.uid,
      fullName: fullName,
      email: email,
      phone: phone,
    );
    return credential;
  }

  /// Best-effort user profile save (never fails sign-up/sign-in when
  /// offline or when Firestore rules/connection are unavailable).
  /// `role: tourist` on create is allowed by rules; later changes to
  /// `admin` are rejected server-side. `isActive` defaults true.
  /// Merge-only: never overwrites an existing role or verification state.
  Future<void> _ensureUserDoc({
    required String? uid,
    required String fullName,
    required String email,
    String? phone,
  }) async {
    try {
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fullName': fullName,
          'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'role': 'tourist',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  /// Throws when the account is explicitly disabled. Missing documents
  /// (legacy accounts) stay allowed; only `isActive == false` blocks.
  /// Signs the session back out so a disabled user is never left logged in.
  Future<void> _requireActiveAccount(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.data()?['isActive'] == false) {
        await _firebaseAuth.signOut();
        throw Exception(
          'This account has been disabled. Please contact support.',
        );
      }
    } on Exception catch (e) {
      if (e.toString().contains('disabled')) rethrow;
    } catch (_) {}
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
  ///
  /// Reads the PUBLIC `guideProfiles` directory first: deployed rules
  /// restrict `users` list queries to admins, so the legacy path below only
  /// works pre-deploy (kept as fallback for that phase).
  Future<String?> getGuidePhoneByName(String guideName) async {
    final name = guideName.trim();
    if (name.isEmpty) return null;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('guideProfiles')
          .where('displayName', isEqualTo: name)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final phone = snapshot.docs.first.data()['contactPhone'];
        if (phone is String && phone.trim().isNotEmpty) {
          return phone.trim();
        }
      }
    } catch (_) {}
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
    final uid = credential.user?.uid;
    if (uid != null) await _requireActiveAccount(uid);
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
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    // First-time Google users have no `users/` doc (no role/phone); create
    // the same shape as email sign-up (merge-only, never overwrites).
    final user = userCredential.user;
    await _ensureUserDoc(
      uid: user?.uid,
      fullName: user?.displayName ?? '',
      email: user?.email ?? '',
    );
    if (user != null) await _requireActiveAccount(user.uid);
    return userCredential;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Signs out everywhere. The Google step is best-effort (it can throw on
  /// platforms where the Google plugin is unavailable); the Firebase
  /// sign-out below always runs so logout can never leave a live session
  /// behind a Google-plugin failure.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
  }

  /// Converts FirebaseAuthException codes into readable messages for the UI.
  String getErrorMessage(Object error) {
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
