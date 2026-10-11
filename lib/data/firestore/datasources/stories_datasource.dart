import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/story_doc.dart';

/// `stories/{storyId}` reads/writes.
///
/// Clients query only unexpired stories (`expiresAt > now`); a scheduled
/// Function (`cleanupExpiredStories`) hard-deletes expired docs. Owner or
/// admin may delete early.
class StoriesDatasource {
  FirebaseFirestore? _dbInit;
  StoriesDatasource([FirebaseFirestore? db]) : _dbInit = db;

  // Lazy: constructing the datasource must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  FirebaseFirestore get _db => _dbInit ??= FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.stories);

  Future<StoryDoc?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return StoryDoc.fromFirestore(doc);
  }

  Future<List<StoryDoc>> listActive({int limit = 50}) async {
    final now = Timestamp.now();
    final snap = await _col
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(StoryDoc.fromFirestore).toList();
  }

  Future<List<StoryDoc>> listByUser(String userId) async {
    final now = Timestamp.now();
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map(StoryDoc.fromFirestore).toList();
  }

  Future<String> create(StoryDoc doc) async {
    final ref = _col.doc();
    await ref.set(doc.toCreateMap());
    return ref.id;
  }

  Future<void> delete(String storyId) => _col.doc(storyId).delete();
}
