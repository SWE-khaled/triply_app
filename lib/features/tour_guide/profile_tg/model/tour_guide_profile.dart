import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Optional extras, written later via
  /// [TourGuideProfileService.updateProfileFields].
  final String about;
  final String location;

  /// The guide's profile photo — shown on the public guide card seen by tourists.
  final String photoUrl;

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
    this.photoUrl = '',
    this.pricePerHour = 0,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'displayName': name,
    'email': email,
    'phone': phone,
    'role': role,
    'licenseNumber': licenseNumber,
    'languages': languages,
    'isApproved': isApproved,
    'pricePerHour': pricePerHour,
    'avatarUrl': '',
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
      photoUrl: (map['photoUrl'] as String?) ?? '',
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
      if (verification['reviewStatus'] == 'approved' ||
          verification['status'] == 'approved') {
        return true;
      }
    }
    return (map['status'] as String?) == 'approved';
  }
}
