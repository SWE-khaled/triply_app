import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `users/{uid}` document.
///
/// Firebase Auth owns credentials; this doc owns profile + role display.
/// `role` is NEVER client-writable to `admin` (rules strip/reject it).
/// `uid` == Firebase Auth UID (stable identifier across roles).
class AppUserDoc {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role; // tourist | guide | admin
  final String avatarUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUserDoc({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl = '',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUserDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return AppUserDoc(
      uid: doc.id,
      fullName: FirestoreConverters.toStr(d['fullName'] ?? d['name']),
      email: FirestoreConverters.toStr(d['email']),
      phone: FirestoreConverters.toStr(d['phone']),
      role: FirestoreConverters.toStr(d['role'], 'tourist'),
      avatarUrl: FirestoreConverters.toStr(
        d['avatarUrl'] ?? d['photoUrl'] ?? d['avatar_url'],
      ),
      isActive: FirestoreConverters.toBool(d['isActive'], true),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
      updatedAt: FirestoreConverters.toDateTime(d['updatedAt']),
    );
  }

  factory AppUserDoc.fromMap(Map<String, dynamic> d, String uid) {
    return AppUserDoc(
      uid: uid,
      fullName: FirestoreConverters.toStr(d['fullName'] ?? d['name']),
      email: FirestoreConverters.toStr(d['email']),
      phone: FirestoreConverters.toStr(d['phone']),
      role: FirestoreConverters.toStr(d['role'], 'tourist'),
      avatarUrl: FirestoreConverters.toStr(
        d['avatarUrl'] ?? d['photoUrl'] ?? d['avatar_url'],
      ),
      isActive: FirestoreConverters.toBool(d['isActive'], true),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
      updatedAt: FirestoreConverters.toDateTime(d['updatedAt']),
    );
  }

  /// Client-safe write payload. `role`, `isActive`, `createdAt` are
  /// intentionally excluded — rules/functions own them.
  Map<String, dynamic> toClientMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
