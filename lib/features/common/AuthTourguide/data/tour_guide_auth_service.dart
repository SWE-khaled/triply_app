import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model for a Tour Guide user profile stored in Firestore.
class TourGuideProfile {
  /// The role every guide account carries.
  ///
  /// The rules pin the role of a document, so an account is a guide for
  /// its whole life — it can never become a tourist.
  static const String guideRole = 'guide';

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String licenseNumber;
  final List<String> languages;
  final bool isApproved;

  /// Optional extras, written later via [TourGuideAuthService.updateProfileFields].
  final String about;
  final String location;

  /// The guide's hourly rate in EGP — what a private booking costs.
  final double pricePerHour;

  const TourGuideProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.languages,
    this.role = guideRole,
    this.isApproved = false,
    this.about = '',
    this.location = '',
    this.pricePerHour = 0,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'licenseNumber': licenseNumber,
    'languages': languages,
    'isApproved': isApproved,
    'isActive': true,
    'pricePerHour': pricePerHour,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory TourGuideProfile.fromMap(Map<String, dynamic> map, String uid) {
    return TourGuideProfile(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      role: (map['role'] as String?) ?? 'guide',
      licenseNumber: (map['licenseNumber'] as String?) ?? '',
      languages:
          (map['languages'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      isApproved: _isApproved(map),
      about: (map['about'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Whether the guide passed the verification.
  ///
  /// The `verification` map is the single source of truth — the admin
  /// writes the decision there. The `isApproved` flag is only a fallback
  /// for accounts that were approved before the map existed.
  static bool _isApproved(Map<String, dynamic> map) {
    final verification = map['verification'];
    if (verification is Map) {
      return verification['reviewStatus'] == 'approved';
    }
    return map['isApproved'] as bool? ?? false;
  }
}

/// Handles all Firebase Auth + Firestore operations for Tour Guides.
/// Kept separate from the tourist AuthRepository to avoid coupling.
class TourGuideAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────── Registration ────────────────

  /// Creates a Firebase Auth user and writes the guide profile to Firestore.
  ///
  /// The profile carries the `guide` role, and the rules pin it — so the
  /// account can never switch to the tourist role afterwards.
  Future<UserCredential> registerGuide({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String licenseNumber,
    List<String> languages = const [],
    double pricePerHour = 0,
  }) async {
    // 1. Create Auth user
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    // 2. Update display name
    await credential.user!.updateDisplayName(name);

    // 3. Write Firestore document
    final profile = TourGuideProfile(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      licenseNumber: licenseNumber,
      languages: languages,
      pricePerHour: pricePerHour,
    );

    // Merged, so a re-registration never wipes the verification the admin
    // already wrote.
    await _db
        .collection('users')
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));

    return credential;
  }

  // ──────────────── Login ────────────────

  /// Signs in with email/password and returns the role from Firestore.
  ///
  /// Throws when the account is not a guide account: the roles are
  /// exclusive, so a tourist account must use the tourist app.
  Future<({UserCredential credential, String role})> signInGuide({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw const TourGuideAuthException(
        'User profile not found. Please contact support.',
      );
    }

    final role = (doc.data()?['role'] as String?) ?? 'tourist';
    if (role != TourGuideProfile.guideRole) {
      // The session is closed again: the refused account does not stay
      // signed in on the guide side.
      await _auth.signOut();
      throw const TourGuideAuthException(
        'This is a tourist account. Sign in from the tourist app.',
      );
    }
    return (credential: credential, role: role);
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

  /// Merges profile fields into the guide's Firestore document.
  /// Only non-null values are written; everything else is preserved.
  Future<void> updateProfileFields({
    String? name,
    String? about,
    String? location,
    String? phone,
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
      if (data == null) return false;
      return data['status'] == 'approved';
    } catch (_) {
      // Offline or no access — treat it as not approved.
      return false;
    }
  }

  /// Signs out the current Firebase session. Permanent account data
  /// (profile, verification) stays in Firestore — relogin restores it.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Fetches the role of the currently signed-in user.
  Future<String?> getCurrentUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  /// Converts FirebaseAuthException codes into readable messages.
  String getErrorMessage(Object error) {
    if (error is TourGuideAuthException) {
      return error.message;
    }
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Sign in with your '
              'existing account instead.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-not-found':
          return 'No guide account found with this email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return error.message ?? 'An unexpected error occurred.';
      }
    }
    return error.toString();
  }
}

/// A failure the user can read as-is.
class TourGuideAuthException implements Exception {
  const TourGuideAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
