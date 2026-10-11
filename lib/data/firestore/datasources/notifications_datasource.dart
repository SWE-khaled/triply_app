import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/notification_doc.dart';
import 'firestore_query_helper.dart';

/// `notifications/{notificationId}` — recipient reads + mark-read only.
/// Creation happens exclusively in Functions (booking/trip/verification
/// events); clients cannot create notifications directly.
class NotificationsDatasource {
  FirebaseFirestore? _dbInit;
  NotificationsDatasource([FirebaseFirestore? db]) : _dbInit = db;

  // Lazy: constructing the datasource must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  FirebaseFirestore get _db => _dbInit ??= FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.notifications);

  Future<({List<NotificationDoc> items, Object? last, bool hasMore})>
  listByUser(String userId, {int limit = 20, Object? startAfter}) async {
    final q = _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);
    final page = await FirestoreQueryHelper.paginate(
      q,
      limit: limit,
      startAfter: startAfter,
    );
    return (
      items: page.docs.map(NotificationDoc.fromFirestore).toList(),
      last: page.last,
      hasMore: page.hasMore,
    );
  }

  Stream<List<NotificationDoc>> streamByUser(String userId, {int limit = 20}) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(NotificationDoc.fromFirestore).toList());
  }

  Stream<int> unreadCount(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.size);
  }

  Future<void> markOneRead(String notificationId) async {
    await _col.doc(notificationId).set({
      'isRead': true,
    }, SetOptions(merge: true));
  }

  Future<void> markAllRead(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .limit(100)
        .get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.set(d.reference, {'isRead': true}, SetOptions(merge: true));
    }
    await batch.commit();
  }
}
