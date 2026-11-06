import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../model/auth_role.dart';

/// A cross-role sign-in attempt: the account belongs to the other app.
///
/// The session is signed out immediately so nothing of it survives.
/// `AuthCubit` shows [message] through `getErrorMessage`.
class RoleMismatchException implements Exception {
  final String message;

  RoleMismatchException(this.message);

  @override
  String toString() => message;
}

/// The one Firebase Auth entry point for both the tourist and guide apps.
///
/// The flows are identical; only the expected [AuthRole] differs. The role
/// decides which Firestore documents a new account gets and which accounts
/// are allowed to sign in.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// How long a profile read may take before it is given up.
  static const Duration _readTimeout = Duration(seconds: 4);

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ──────────────── Sign up ────────────────

  /// Creates the account and writes the role-specific profile.
  ///
  /// * [AuthRole.tourist] writes `users/{uid}` in the background: sign-up
  ///   never waits for Firestore and never fails when it is offline.
  /// * [AuthRole.guide] writes `users/{uid}` and the public `guides/{uid}`
  ///   document, awaited, because the verification and listing screens
  ///   depend on them.
  Future<UserCredential> signUpWithEmail({
    required AuthRole role,
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? licenseNumber,
    List<String> languages = const [],
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    await user?.updateDisplayName(fullName);

    final uid = user?.uid;
    if (uid == null) return credential;

    if (role == AuthRole.guide) {
      await _writeGuideProfile(
        uid: uid,
        name: fullName,
        email: email,
        phone: phone ?? '',
        licenseNumber: licenseNumber ?? '',
        languages: languages,
        photoUrl: user?.photoURL ?? '',
      );
    } else {
      unawaited(
        _writeTouristProfile(
          uid: uid,
          fullName: fullName,
          email: email,
          phone: phone,
        ),
      );
    }
    return credential;
  }

  /// Best-effort tourist profile. The rules read the role with a
  /// dot-access, so the field has to be there — without it the whole
  /// document is refused and the profile never exists.
  Future<void> _writeTouristProfile({
    required String uid,
    required String fullName,
    required String email,
    String? phone,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'fullName': fullName,
        'displayName': fullName,
        'email': email,
        'role': AuthRole.tourist.value,
        'avatarUrl': '',
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Sign-up must not fail because Firestore is unreachable.
    }
  }

  /// The guide's private profile plus the public listing tourists browse.
  /// Both use the uid as the document id, so trips are found by the very
  /// same key.
  Future<void> _writeGuideProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String licenseNumber,
    required List<String> languages,
    required String photoUrl,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'displayName': name,
      'email': email,
      'phone': phone,
      'role': AuthRole.guide.value,
      'licenseNumber': licenseNumber,
      'languages': languages,
      'isApproved': false,
      'pricePerHour': 0,
      'avatarUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('guides').doc(uid).set({
      'guideId': uid,
      'name': name,
      'specialty': '',
      'avatarUrl': photoUrl,
      'coverUrl': '',
      'location': '',
      'about': '',
      'languages': languages,
      'rating': 0,
      'reviewCount': 0,
      'pricePerHour': 0,
      'currency': 'EGP',
      'isApproved': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────── Sign in ────────────────

  /// Signs in with email + password and enforces [role].
  ///
  /// A non-matching account is signed out at once and a
  /// [RoleMismatchException] carries the reason to the UI.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
    required AuthRole role,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _ensureRole(uid: credential.user?.uid, expectedRole: role);
    return credential;
  }

  Future<UserCredential> signInWithGoogle({required AuthRole role}) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    await _ensureRole(uid: result.user?.uid, expectedRole: role);
    // In the background: the sign-in never waits for the profile save.
    unawaited(_saveGoogleProfile(result.user, role));
    return result;
  }

  /// Best-effort: keeps the Google name and photo on `users/{uid}` so the
  /// booking and chat screens can show them. Never fails the sign-in.
  Future<void> _saveGoogleProfile(User? user, AuthRole role) async {
    final uid = user?.uid;
    if (uid == null) return;
    try {
      final ref = _db.collection('users').doc(uid);
      final exists = (await ref.get().timeout(_readTimeout)).exists;
      final name = user?.displayName ?? '';
      await ref.set({
        'fullName': name,
        'displayName': name,
        'email': user?.email ?? '',
        'photoUrl': user?.photoURL ?? '',
        'avatarUrl': user?.photoURL ?? '',
        // Only for a brand-new document; an existing role is never
        // touched.
        if (!exists) 'role': role.value,
        if (!exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Blocks the accounts that belong to the other app.
  Future<void> _ensureRole({
    required String? uid,
    required AuthRole expectedRole,
  }) async {
    if (uid == null) return;

    final result = await _readRole(uid);

    if (expectedRole == AuthRole.guide) {
      if (!result.ok) {
        await _signOutSession();
        throw RoleMismatchException(
          'Could not verify this account. Please check your connection and '
          'try again.',
        );
      }
      final role = result.role?.trim();
      if (role == null || role.isEmpty) {
        await _signOutSession();
        throw RoleMismatchException(
          'User profile not found. Please contact support.',
        );
      }
      if (role != AuthRole.guide.value) {
        await _signOutSession();
        throw RoleMismatchException(
          'This account is not a guide account — please use the tourist '
          'app to sign in.',
        );
      }
      return;
    }

    // Tourist app: a missing document (brand-new Google account) or a
    // failed read counts as a tourist — e-mail sign-up always writes
    // `role: 'tourist'` itself. Only an explicit non-tourist role is
    // rejected.
    final role = result.role?.trim();
    if (result.ok &&
        role != null &&
        role.isNotEmpty &&
        role != AuthRole.tourist.value) {
      await _signOutSession();
      throw RoleMismatchException(
        role == AuthRole.guide.value
            ? 'This account is registered as a guide — please use the guide '
                  'app to sign in.'
            : 'This account is not a tourist account — it cannot sign in '
                  'here.',
      );
    }
  }

  /// Reads `users/{uid}.role`.
  ///
  /// [ok] is false when the read itself failed (offline, rules, timeout),
  /// which is different from a document that exists without a role.
  Future<({bool ok, String? role})> _readRole(String uid) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(_readTimeout);
      return (ok: true, role: doc.data()?['role'] as String?);
    } catch (_) {
      return (ok: false, role: null);
    }
  }

  // ──────────────── Profile helpers ────────────────

  /// Saved phone number (e.g. +2010...) or null when absent/unreachable.
  Future<String?> getUserPhone(String uid) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(_readTimeout);
      final phone = doc.data()?['phone'];
      if (phone is String && phone.trim().isNotEmpty) return phone.trim();
    } catch (_) {}
    return null;
  }

  /// Saved tourist profile fields for the signed-in user's document.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Phone of a registered guide matched by display name (same name
  /// matching the trip screens already use), or null when no registered
  /// guide with a saved phone exists. Never invents a number.
  Future<String?> getGuidePhoneByName(String guideName) async {
    final name = guideName.trim();
    if (name.isEmpty) return null;
    try {
      final snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: AuthRole.guide.value)
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

  // ──────────────── Session ────────────────

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _signOutSession();

  Future<void> _signOutSession() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Google sign-out is best-effort; Firebase sign-out must always run.
    }
    await _auth.signOut();
  }

  /// Converts auth failures into readable messages for the UI.
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
          return 'Incorrect email or password';
        case 'email-already-in-use':
          return 'This email is already registered. Please sign in instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return error.message ?? 'An unexpected error occurred.';
      }
    }
    // Plain `Exception('...')` prints with an "Exception: " prefix — strip
    // it so the snackbar shows the message only.
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}
