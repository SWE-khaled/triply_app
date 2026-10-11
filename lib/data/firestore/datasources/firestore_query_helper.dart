import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared query helpers: pagination + emulator-safe error mapping.
class FirestoreQueryHelper {
  FirestoreQueryHelper._();

  static const int defaultPageSize = 20;

  /// Runs [query] with optional cursor pagination.
  static Future<({List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, Object? last, bool hasMore})>
      paginate(
    Query<Map<String, dynamic>> query, {
    int limit = defaultPageSize,
    Object? startAfter,
  }) async {
    var q = query.limit(limit + 1);
    if (startAfter is QueryDocumentSnapshot<Map<String, dynamic>>) {
      q = q.startAfterDocument(startAfter);
    }
    final snap = await q.get();
    final hasMore = snap.docs.length > limit;
    final docs = hasMore ? snap.docs.sublist(0, limit) : snap.docs;
    final last = docs.isNotEmpty ? docs.last : startAfter;
    return (docs: docs, last: last, hasMore: hasMore);
  }

  static String friendlyError(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this action.';
        case 'unavailable':
          return 'Network unavailable. Showing cached data where possible.';
        case 'not-found':
          return 'The requested item was not found.';
        case 'already-exists':
          return 'This item already exists.';
        case 'resource-exhausted':
          return 'Too many requests. Please try again shortly.';
        default:
          return 'Firestore error (${e.code}). Please try again.';
      }
    }
    return e.toString();
  }
}
