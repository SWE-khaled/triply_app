import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Talks to Firebase directly. No UI logic here.
class AuthRepository {
  /// The role every tourist account carries.
  ///
  /// The rules pin the role of a document, so an account is a tourist
  /// for its whole life — it can never become a tour guide.
  static const String touristRole = 'tourist';

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
    // The profile carries the role, and the rules pin it — so it has to
    // be written here. A missing profile means a missing role, and a
    // missing role means the account is not protected: the rules let the
    // owner claim either role when the document is created.
    await _saveTouristProfile(
      credential.user,
      fullName: fullName,
      email: email,
      phone: phone,
    );
    return credential;
  }

  /// Writes the tourist profile — with the `tourist` role — to Firestore.
  ///
  /// `name` and `fullName` are both written so the guide side and the
  /// tourist side read the same field.
  Future<void> _saveTouristProfile(
    User? user, {
    required String fullName,
    required String email,
    String? phone,
  }) async {
    final uid = user?.uid;
    if (uid == null) return;
    final photoUrl = user?.photoURL;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': fullName,
        'fullName': fullName,
        'email': email,
        'role': touristRole,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw AuthRepositoryException(
        'Your account was created but the profile could not be saved '
        '(${e.code}). Sign in again to retry.',
      );
    }
  }

  /// Makes sure the signed-in tourist has a profile document.
  ///
  /// A Google sign-in never writes one, and a sign-up whose profile write
  /// failed leaves the account without a role. The role is what the rules
  /// pin, so it has to exist.
  Future<void> ensureProfile(User user) async {
    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await doc.get();
      if (snapshot.exists) return;
      await doc.set({
        'name': user.displayName ?? '',
        'fullName': user.displayName ?? '',
        'email': user.email ?? '',
        'role': touristRole,
        if (user.photoURL != null && user.photoURL!.isNotEmpty)
          'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      // Offline or refused by the rules — the sign-in still works, the
      // profile is retried on the next sign-in.
    }
  }

  /// The role stored on the user's Firestore document.
  ///
  /// Returns an empty string when the document is missing or unreadable.
  Future<String> roleOf(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return (doc.data()?['role'] as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Throws when the account belongs to another portal.
  ///
  /// A guide account must not use the tourist app, and the other way
  /// around — the account keeps exactly one role for its whole life. The
  /// session is closed again, so the refused account does not stay
  /// signed in on the wrong side.
  Future<void> _rejectForeignRole(User user) async {
    final role = await roleOf(user.uid);
    if (role != 'guide' && role != 'admin') return;
    await _firebaseAuth.signOut();
    if (role == 'guide') {
      throw const AuthRepositoryException(
        'This is a tour guide account. Sign in from the guide portal.',
      );
    }
    throw const AuthRepositoryException(
      'This is an admin account. Sign in from the admin portal.',
    );
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
    final user = credential.user;
    if (user != null) {
      await _rejectForeignRole(user);
      await ensureProfile(user);
    }
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthRepositoryException('Google sign-in cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final signedIn = await _firebaseAuth.signInWithCredential(credential);
    final user = signedIn.user;
    if (user != null) {
      await _rejectForeignRole(user);
      await ensureProfile(user);
    }
    return signedIn;
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
    if (error is AuthRepositoryException) {
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
          return 'This email is already registered. Sign in with your '
              'existing account instead.';
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

/// A failure the user can read as-is.
///
/// The Firebase codes are too technical for the UI, so the repository
/// translates the ones it understands into a sentence.
class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
