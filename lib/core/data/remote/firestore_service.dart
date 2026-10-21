import 'package:cloud_firestore/cloud_firestore.dart';

/// Thin wrapper around [FirebaseFirestore].
///
/// The repositories share one instance and one place for Firestore
/// specifics (document ids, merge semantics, null handling), so the
/// feature code never talks to the SDK directly.
class FirestoreService {
  FirestoreService({this.db});

  /// The Firestore instance to use. Null means the default one.
  final FirebaseFirestore? db;

  /// The instance actually used.
  ///
  /// Resolved lazily so building the service never requires a running
  /// Firebase app (which keeps it usable in plain unit tests).
  FirebaseFirestore get _instance => db ?? FirebaseFirestore.instance;

  /// The shared Firestore instance.
  ///
  /// Resolved lazily so building the service never requires a running
  /// Firebase app (which keeps it usable in plain unit tests).
  FirebaseFirestore get instance => _instance;

  /// A top-level collection reference.
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _instance.collection(path);

  /// Reads one document as a plain map. Returns null when the document
  /// does not exist.
  Future<Map<String, dynamic>?> readDoc(String path, String id) async {
    final snapshot = await _instance.collection(path).doc(id).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    return Map<String, dynamic>.of(data);
  }

  /// Writes a document.
  ///
  /// [merge] adds the given fields to an existing document instead of
  /// replacing it. `createdAt` is never overwritten once it exists.
  Future<void> writeDoc(
    String path,
    String id,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    final payload = Map<String, dynamic>.of(data);
    if (merge && payload.containsKey('createdAt')) {
      payload.remove('createdAt');
    }
    await _instance
        .collection(path)
        .doc(id)
        .set(payload, SetOptions(merge: merge));
  }

  /// Deletes a document. Missing documents are ignored.
  Future<void> deleteDoc(String path, String id) async {
    await _instance.collection(path).doc(id).delete();
  }
}
