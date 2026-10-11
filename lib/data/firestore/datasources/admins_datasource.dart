import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';

/// `admins/{uid}` — presence doc marking an authorized administrator.
///
/// Written ONLY via Firebase Console / Functions (`provisionAdmin`) by an
/// existing admin. Rules check `exists(/databases/.../admins/{uid})` for
/// all admin-only operations; the legacy `triplykl` email-substring gate
/// must not be relied upon.
class AdminsDatasource {
  final FirebaseFirestore _db;
  AdminsDatasource([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  Future<bool> isAdmin(String uid) async {
    if (uid.isEmpty) return false;
    final doc =
        await _db.collection(FirestorePaths.admins).doc(uid).get();
    return doc.exists;
  }

  Stream<bool> streamIsAdmin(String uid) {
    if (uid.isEmpty) return Stream.value(false);
    return _db
        .collection(FirestorePaths.admins)
        .doc(uid)
        .snapshots()
        .map((d) => d.exists);
  }
}
