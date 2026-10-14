import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/post_doc.dart';
import 'firestore_query_helper.dart';

/// `posts/{postId}` + `posts/{postId}/likes/{uid}`.
///
/// Feed is reverse-chron; likes are ownership-safe subcollection docs
/// (`likes/{uid}`); `likesCount` is a Function-maintained aggregate that
/// clients never write directly. Feeds display live subcollection counts
/// (see [countLikes]) so totals stay correct even when that Function
/// isn't deployed.
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

  /// Batch version of [isLiked] for a feed page: returns the subset of
  /// [postIds] the user liked. Parallel gets; a failure yields an empty
  /// set (feed renders unliked) rather than failing the whole feed.
  /// Skipped by callers for signed-out previews.
  Future<Set<String>> likedIds(List<String> postIds, String uid) async {
    if (postIds.isEmpty || uid.isEmpty) return <String>{};
    try {
      final results = await Future.wait(
        postIds.map((id) async => (id: id, liked: await isLiked(id, uid))),
      );
      return {for (final r in results) if (r.liked) r.id};
    } catch (_) {
      return <String>{};
    }
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

  /// Live like total for one post (size of the `likes` subcollection).
  /// Used because the `likesCount` aggregate field is only refreshed by
  /// the `onPostLikeWritten` Function when deployed — reading the true
  /// count keeps every client correct with no Functions deploy required
  /// (likes reads are public per rules).
  Future<int> countLikes(String postId) async {
    final snap = await _likes(postId).count().get();
    return snap.count ?? 0;
  }
}
