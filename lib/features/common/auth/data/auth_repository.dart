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
    // Best-effort user profile save (never fails sign-up when offline
    // or when Firestore rules/connection are unavailable).
    try {
      final uid = credential.user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'fullName': fullName,
            'email': email,
            if (phone != null && phone.isNotEmpty) 'phone': phone,
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
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

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
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
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
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