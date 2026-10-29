import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model for a Tour Guide user profile stored in Firestore.
class TourGuideProfile {
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
    this.role = 'guide',
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
    if (map['isApproved'] == true) return true;
    final verification = map['verification'];
    if (verification is Map) {
      if (verification['reviewStatus'] == 'approved' || verification['status'] == 'approved') {
        return true;
      }
    }
    return (map['status'] as String?) == 'approved';
  }
}

/// Handles all Firebase Auth + Firestore operations for Tour Guides.
/// Kept separate from the tourist AuthRepository to avoid coupling.
class TourGuideAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────── Registration ────────────────

  /// Creates a Firebase Auth user and writes the guide profile to Firestore.
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

    await _db.collection('users').doc(uid).set(profile.toMap());

    // The public profile: this is what the tourists browse. The id is the
    // uid, so the trips of this guide are found by the very same key.
    await _db.collection(guidesCollection).doc(uid).set({
      'guideId': uid,
      'name': name,
      'specialty': '',
      'avatarUrl': '',
      'coverUrl': '',
      'location': '',
      'about': '',
      'languages': languages,
      'rating': 0,
      'reviewCount': 0,
      'pricePerHour': pricePerHour,
      'currency': 'EGP',
      'isApproved': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

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
        }, SetOptions(merge: true));
        return;
      }
      await doc.set({
        'guideId': uid,
        'name': profile.name,
        'specialty': '',
        'avatarUrl': '',
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

  // ──────────────── Login ────────────────

  /// Signs in with email/password and returns the role from Firestore.
  ///
  /// Cross-role guard: a tourist (or admin) account is signed out
  /// immediately and a readable exception is thrown — the guide app
  /// never opens on a non-guide session.
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
      throw Exception('User profile not found. Please contact support.');
    }

    final role = (doc.data()?['role'] as String?) ?? 'tourist';
    if (role != 'guide') {
      // Drop the session at once — the account belongs to another app.
      await _auth.signOut();
      throw Exception(
        'This account is not a guide account — please use the tourist app to sign in.',
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
    await for (final snapshot
        in _db.collection('users').doc(uid).snapshots()) {
      yield (((snapshot.data()?['name'] as String?) ?? '')).trim();
    }
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
      if (data != null && data['status'] == 'approved') return true;

      // Check users/{uid} as well so approval is permanently honored
      final userDoc = await _db.collection('users').doc(uid).get();
      final userData = userDoc.data();
      if (userData != null && (userData['isApproved'] == true || userData['status'] == 'approved')) {
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
    await for (final snapshot
        in _db.collection('guideVerifications').doc(uid).snapshots()) {
      final data = snapshot.data();
      if (data != null && data['status'] == 'approved') {
        yield true;
      } else {
        final userDoc = await _db.collection('users').doc(uid).get();
        final userData = userDoc.data();
        yield userData != null &&
            (userData['isApproved'] == true || userData['status'] == 'approved');
      }
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
    await for (final snapshot
        in _db.collection('guideVerifications').doc(uid).snapshots()) {
      final data = snapshot.data();
      if (data != null && data['status'] == 'approved') {
        yield data;
      } else {
        final userDoc = await _db.collection('users').doc(uid).get();
        final userData = userDoc.data();
        if (userData != null &&
            (userData['isApproved'] == true || userData['status'] == 'approved')) {
          final merged = Map<String, dynamic>.of(data ?? {});
          merged['status'] = 'approved';
          yield merged;
        } else {
          yield data;
        }
      }
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
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please sign in instead.';
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
    // Plain `Exception('...')` prints with an "Exception: " prefix —
    // strip it so the snackbar shows the message only.
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}
