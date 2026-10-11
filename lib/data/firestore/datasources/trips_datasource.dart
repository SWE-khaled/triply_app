import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/trip_doc.dart';
import 'firestore_query_helper.dart';

/// `trips/{tripId}` reads/writes.
///
/// Publication rules (also enforced by `firestore.rules` + Functions):
/// - Tourists query `approvalStatus == approved` only.
/// - Guides query their own `guideId == me` (any status).
/// - Admin lists `approvalStatus == pending` for review.
/// Clients never write `bookedSeats` / `approvalStatus` / `rejectionReason`.
class TripsDatasource {
  FirebaseFirestore? _dbInit;
  TripsDatasource([FirebaseFirestore? db]) : _dbInit = db;

  // Lazy: constructing the datasource must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  FirebaseFirestore get _db => _dbInit ??= FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.trips);

  Future<TripDoc?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return TripDoc.fromFirestore(doc);
  }

  Stream<TripDoc?> streamById(String id) {
    return _col
        .doc(id)
        .snapshots()
        .map((d) => d.exists ? TripDoc.fromFirestore(d) : null);
  }

  /// Tourist feed: approved trips only, paginated.
  Future<({List<TripDoc> items, Object? last, bool hasMore})> listApproved({
    String? category,
    int limit = 20,
    Object? startAfter,
  }) async {
    Query<Map<String, dynamic>> q = _col
        .where('approvalStatus', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true);
    if (category != null && category.isNotEmpty && category != 'All') {
      q = _col
          .where('approvalStatus', isEqualTo: 'approved')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true);
    }
    final page = await FirestoreQueryHelper.paginate(
      q,
      limit: limit,
      startAfter: startAfter,
    );
    return (
      items: page.docs.map(TripDoc.fromFirestore).toList(),
      last: page.last,
      hasMore: page.hasMore,
    );
  }

  /// Guide "my trips": everything owned by [guideId], newest first.
  Future<({List<TripDoc> items, Object? last, bool hasMore})> listByGuide(
    String guideId, {
    String? approvalStatus,
    int limit = 20,
    Object? startAfter,
  }) async {
    Query<Map<String, dynamic>> q = _col
        .where('guideId', isEqualTo: guideId)
        .orderBy('createdAt', descending: true);
    if (approvalStatus != null && approvalStatus.isNotEmpty) {
      q = _col
          .where('guideId', isEqualTo: guideId)
          .where('approvalStatus', isEqualTo: approvalStatus)
          .orderBy('createdAt', descending: true);
    }
    final page = await FirestoreQueryHelper.paginate(
      q,
      limit: limit,
      startAfter: startAfter,
    );
    return (
      items: page.docs.map(TripDoc.fromFirestore).toList(),
      last: page.last,
      hasMore: page.hasMore,
    );
  }

  /// Admin review queue: pending trips oldest-first.
  Future<List<TripDoc>> listPending({int limit = 50}) async {
    final snap = await _col
        .where('approvalStatus', isEqualTo: 'pending')
        .orderBy('createdAt')
        .limit(limit)
        .get();
    return snap.docs.map(TripDoc.fromFirestore).toList();
  }

  /// Admin-only dashboard list: newest trips of any status (rules: only
  /// admins satisfy the per-document list check for non-approved docs).
  Future<List<TripDoc>> listRecent({int limit = 50}) async {
    final snap = await _col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(TripDoc.fromFirestore).toList();
  }

  /// Admin-only total (server count aggregation — no full read).
  Future<int> countAll() async {
    final snap = await _col.count().get();
    return snap.count ?? 0;
  }

  /// Admin-only pending total (server count aggregation).
  Future<int> countPending() async {
    final snap = await _col
        .where('approvalStatus', isEqualTo: 'pending')
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<List<TripDoc>> listByPlace(String placeId, {int limit = 20}) async {
    final snap = await _col
        .where('placeId', isEqualTo: placeId)
        .where('approvalStatus', isEqualTo: 'approved')
        .limit(limit)
        .get();
    return snap.docs.map(TripDoc.fromFirestore).toList();
  }

  /// Guide creates a trip. Writes the client-safe payload only; the
  /// `onTripCreate` Function stamps `approvalStatus=pending` + denormalized
  /// search fields. Returns the new doc id.
  Future<String> create(TripDoc doc) async {
    final ref = _col.doc();
    await ref.set(doc.toCreateMap());
    return ref.id;
  }

  /// Guide edits own trip (title/details only). Status-affecting fields are
  /// stripped here AND rejected by rules; edits re-pend via Function.
  Future<void> updateClientFields(
    String id,
    Map<String, dynamic> fields,
  ) async {
    final safe = Map<String, dynamic>.from(fields)
      ..remove('guideId')
      ..remove('bookedSeats')
      ..remove('peopleCount')
      ..remove('approvalStatus')
      ..remove('rejectionReason')
      ..remove('createdAt')
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(id).set(safe, SetOptions(merge: true));
  }
}
