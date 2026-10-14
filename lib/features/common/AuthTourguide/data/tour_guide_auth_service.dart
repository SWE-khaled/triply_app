import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
      isApproved: (map['isApproved'] as bool?) ?? false,
      about: (map['about'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
    );
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
  }) async {
    // 1. Create Auth user
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    // 2. Update display name
    await credential.user!.updateDisplayName(name);

    // 3. Write Firestore document (legacy `users/{uid}` shape preserved
    // for backward compat with the existing dashboard/login flow).
    final profile = TourGuideProfile(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      licenseNumber: licenseNumber,
      languages: languages,
    );

    await _db.collection('users').doc(uid).set(profile.toMap());

    // 4. Best-effort dual-write to the canonical `guideProfiles/{uid}` doc
    // (public guide fields only; server owns verification flags). Never
    // fails registration when offline or rules are unavailable.
    // `displayName` + `contactPhone` mirror the signup identity so the
    // public trip-details contact lookup works without `users` list access
    // (deployed rules restrict user docs to owner/admin).
    try {
      await _db.collection('guideProfiles').doc(uid).set({
        'userId': uid,
        'displayName': name,
        'contactPhone': phone,
        'languages': languages,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Triply: guideProfiles dual-write failed (offline?): $e');
    }

    return credential;
  }

  // ──────────────── Login ────────────────

  /// Signs in with email/password and returns the role from Firestore.
  /// Disabled accounts (`isActive == false`) are signed straight back out
  /// so a banned user is never left in a logged-in state.
  /// Role separation is strict and fail-closed: only `role == 'guide'` may
  /// use the guide flow. Tourist/admin accounts, missing docs, missing
  /// role fields, and unreadable docs are all signed straight back out
  /// and rejected, so one account can never cross into the other side.
  Future<({UserCredential credential, String role})> signInGuide({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    Map<String, dynamic>? data;
    bool readable = true;
    try {
      data = (await _db.collection('users').doc(uid).get()).data();
    } catch (_) {
      readable = false;
    }

    if (!readable) {
      await _auth.signOut();
      throw Exception(
        'Could not verify guide account. Check your connection and try again.',
      );
    }
    if (data == null) {
      await _auth.signOut();
      throw Exception('User profile not found. Please contact support.');
    }

    if (data['isActive'] == false) {
      await _auth.signOut();
      throw Exception(
        'This account has been disabled. Please contact support.',
      );
    }

    final role = data['role'] as String?;
    if (role == null || role.isEmpty) {
      await _auth.signOut();
      throw Exception('User profile is incomplete. Please contact support.');
    }
    if (role != 'guide') {
      await _auth.signOut();
      throw Exception(
        role == 'tourist'
            ? 'This email is registered as a tourist account. Please sign in on the tourist side.'
            : 'This account is not registered as a tour guide. Please contact support.',
      );
    }
    return (credential: credential, role: role);
  }

  // ──────────────── Verification ────────────────

  /// Updates the user's Firestore document with their verification documents.
  /// Legacy `users/{uid}.verification` map is preserved for the existing
  /// dashboard banner flow; a canonical `guideVerifications/{uid}` doc is
  /// also written best-effort for admin review + rules.
  Future<void> submitVerificationDocuments({
    required String idDocumentUrl,
    required String licenseDocumentUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not authenticated');
    }

    await _db.collection('users').doc(uid).set({
      'verification': {
        'idDocumentUrl': idDocumentUrl,
        'licenseDocumentUrl': licenseDocumentUrl,
        'reviewStatus': 'pending', // 3-6 working days review period
        'canPublishTrips': false, // restricted until approved
        'submittedAt': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));

    try {
      // Full overwrite (no merge): resubmission after a rejection replaces
      // the doc, dropping stale reviewer metadata. Matches the
      // guideVerifications resubmit rule (rejected -> pending, exact keys).
      await _db.collection('guideVerifications').doc(uid).set({
        'guideId': uid,
        'idDocumentUrl': idDocumentUrl,
        'licenseDocumentUrl': licenseDocumentUrl,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'rejectionReason': '',
      }, SetOptions(merge: false));
    } catch (e) {
      // Canonical write is best-effort; the legacy map above keeps the
      // submission visible until admin review. UI gating reads the
      // canonical doc ([isVerificationApproved]), never the legacy map.
      debugPrint('Triply: guideVerifications dual-write failed: $e');
    }
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
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not authenticated');
    }
    final data = <String, dynamic>{
      if (name != null) 'name': name,
      if (about != null) 'about': about,
      if (location != null) 'location': location,
      if (phone != null) 'phone': phone,
    };
    if (data.isEmpty) return;
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  /// Whether the signed-in guide's verification is approved.
  /// Reads the canonical `guideVerifications/{uid}.status` — the only
  /// verdict the client cannot forge (rules reject client-written
  /// `approved`; only the admin Function decides). Anything other than
  /// 'approved' (including a missing document) counts as unverified, so
  /// the verification banner keeps showing until approval.
  /// The legacy `users/{uid}.verification` map is deliberately NOT read:
  /// it is owner-writable and must never gate access.
  Future<bool> isVerificationApproved() async {
    final status = await getVerificationStatus();
    return status?.status == 'approved';
  }

  /// Current verification state from the trusted source, if any submission
  /// exists. Returns null when the guide never submitted (or is signed
  /// out). Powers the verification screen's pending/rejected display.
  Future<({String status, String rejectionReason})?>
  getVerificationStatus() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('guideVerifications').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    return (
      status: (data['status'] as String?) ?? 'pending',
      rejectionReason: (data['rejectionReason'] as String?) ?? '',
    );
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
    // Service-level rejections (role mismatch, disabled, missing profile)
    // arrive as `Exception: <message>` — strip the prefix for the UI.
    final text = error.toString();
    const prefix = 'Exception: ';
    return text.startsWith(prefix) ? text.substring(prefix.length) : text;
  }
}
