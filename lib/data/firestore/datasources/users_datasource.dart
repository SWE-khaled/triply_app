import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/app_user_doc.dart';

/// `users/{uid}` reads/writes.
///
/// Safety: create/update NEVER write `role`/`isActive` from the client.
/// Role assignment happens via Functions (`setUserRole`) or the manual
/// admin-provisioning procedure in `docs/ADMIN_PROVISIONING.md`.
class UsersDatasource {
  FirebaseFirestore? _dbInit;
  UsersDatasource([FirebaseFirestore? db]) : _dbInit = db;

  // Lazy: constructing the datasource must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  FirebaseFirestore get _db => _dbInit ??= FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.users);

  Future<AppUserDoc?> getById(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return AppUserDoc.fromFirestore(doc);
  }

  Stream<AppUserDoc?> streamById(String uid) {
    return _col
        .doc(uid)
        .snapshots()
        .map((d) => d.exists ? AppUserDoc.fromFirestore(d) : null);
  }

  /// Upserts the safe profile subset (merge). Used at sign-up + profile edit.
  Future<void> upsertProfile({
    required String uid,
    required String fullName,
    required String email,
    String phone = '',
    String avatarUrl = '',
  }) async {
    await _col.doc(uid).set({
      'fullName': fullName,
      'email': email,
      if (phone.isNotEmpty) 'phone': phone,
      if (avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateFields(String uid, Map<String, dynamic> fields) async {
    final safe = Map<String, dynamic>.from(fields)
      ..remove('role')
      ..remove('isActive')
      ..remove('createdAt')
      ..remove('uid')
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(uid).set(safe, SetOptions(merge: true));
  }

  Future<List<AppUserDoc>> listByRole(String role, {int limit = 50}) async {
    final snap = await _col.where('role', isEqualTo: role).limit(limit).get();
    return snap.docs.map(AppUserDoc.fromFirestore).toList();
  }

  /// Admin-only total (rules: `users` list is admin-only). Uses a server
  /// count aggregation — no full-collection read.
  Future<int> countAll() async {
    final snap = await _col.count().get();
    return snap.count ?? 0;
  }

  /// Admin-only role total (server count aggregation).
  Future<int> countByRole(String role) async {
    final snap = await _col.where('role', isEqualTo: role).count().get();
    return snap.count ?? 0;
  }

  /// Admin-only active/suspended toggle. Writes `isActive` ONLY (plus
  /// timestamp) — rules allow admins; [updateFields] intentionally strips
  /// this field for non-admin callers, so it must not be reused here.
  Future<void> setActive(String uid, bool active) async {
    await _col.doc(uid).set({
      'isActive': active,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
