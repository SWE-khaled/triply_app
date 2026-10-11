import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/post_doc.dart';
import 'firestore_query_helper.dart';

/// `posts/{postId}` + `posts/{postId}/likes/{uid}`.
///
/// Feed is reverse-chron; likes are ownership-safe subcollection docs
/// (`likes/{uid}`); `likesCount` is a Function-maintained aggregate that
/// clients never write directly.
class PostsDatasource {
  FirebaseFirestore? _dbInit;
  PostsDatasource([FirebaseFirestore? db]) : _dbInit = db;

  // Lazy: constructing the datasource must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  FirebaseFirestore get _db => _dbInit ??= FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.posts);

  CollectionReference<Map<String, dynamic>> _likes(String postId) =>
      _col.doc(postId).collection(FirestorePaths.postLikes);

  Future<PostDoc?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return PostDoc.fromFirestore(doc);
  }

  Future<({List<PostDoc> items, Object? last, bool hasMore})> feed({
    int limit = 20,
    Object? startAfter,
  }) async {
    final q = _col.orderBy('createdAt', descending: true);
    final page = await FirestoreQueryHelper.paginate(
      q,
      limit: limit,
      startAfter: startAfter,
    );
    return (
      items: page.docs.map(PostDoc.fromFirestore).toList(),
      last: page.last,
      hasMore: page.hasMore,
    );
  }

  Future<List<PostDoc>> listByAuthor(String authorId, {int limit = 20}) async {
    final snap = await _col
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(PostDoc.fromFirestore).toList();
  }

  Future<String> create(PostDoc doc) async {
    final ref = _col.doc();
    await ref.set(doc.toCreateMap());
    return ref.id;
  }

  Future<void> delete(String postId) => _col.doc(postId).delete();

  Future<bool> isLiked(String postId, String uid) async {
    final doc = await _likes(postId).doc(uid).get();
    return doc.exists;
  }

  /// Persistent like/unlike. Count aggregation happens in Functions
  /// (`onPostLikeWrite`); the UI applies an optimistic +/-1 on top.
  Future<void> like(String postId, String uid) async {
    await _likes(
      postId,
    ).doc(uid).set({'uid': uid, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> unlike(String postId, String uid) async {
    await _likes(postId).doc(uid).delete();
  }
}
