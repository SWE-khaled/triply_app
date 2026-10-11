import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/booking_doc.dart';
import 'firestore_query_helper.dart';

/// `bookings/{bookingId}` queries + owner-safe updates.
///
/// Creation itself goes through the `createBooking` callable Function
/// (capacity transaction + trusted pricing). The datasource exposes reads,
/// streams, idempotency lookup, and owner cancellation. Direct client writes
/// of `status` / totals / `paymentStatus` are rejected by rules.
class BookingsDatasource {
  final FirebaseFirestore _db;
  BookingsDatasource([FirebaseFirestore? db])
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.bookings);

  Future<BookingDoc?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return BookingDoc.fromFirestore(doc);
  }

  Stream<BookingDoc?> streamById(String id) {
    return _col
        .doc(id)
        .snapshots()
        .map((d) => d.exists ? BookingDoc.fromFirestore(d) : null);
  }

  Future<BookingDoc?> getByIdempotencyKey(String key) async {
    if (key.isEmpty) return null;
    final snap = await _col
        .where('idempotencyKey', isEqualTo: key)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return BookingDoc.fromFirestore(snap.docs.first);
  }

  Future<({List<BookingDoc> items, Object? last, bool hasMore})> listByTourist(
    String touristId, {
    int limit = 20,
    Object? startAfter,
  }) async {
    final q = _col
        .where('touristId', isEqualTo: touristId)
        .orderBy('createdAt', descending: true);
    final page = await FirestoreQueryHelper.paginate(
      q,
      limit: limit,
      startAfter: startAfter,
    );
    return (
      items: page.docs.map(BookingDoc.fromFirestore).toList(),
      last: page.last,
      hasMore: page.hasMore,
    );
  }

  Future<({List<BookingDoc> items, Object? last, bool hasMore})> listByGuide(
    String guideId, {
    int limit = 20,
    Object? startAfter,
  }) async {
    final q = _col
        .where('guideId', isEqualTo: guideId)
        .orderBy('createdAt', descending: true);
    final page = await FirestoreQueryHelper.paginate(
      q,
      limit: limit,
      startAfter: startAfter,
    );
    return (
      items: page.docs.map(BookingDoc.fromFirestore).toList(),
      last: page.last,
      hasMore: page.hasMore,
    );
  }

  Future<List<BookingDoc>> listByTrip(String tripId, {int limit = 100}) async {
    final snap = await _col
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(BookingDoc.fromFirestore).toList();
  }

  /// Admin-only dashboard list: newest bookings of any user (rules: only
  /// admins satisfy the per-document list check cross-user).
  Future<List<BookingDoc>> listRecent({int limit = 50}) async {
    final snap = await _col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(BookingDoc.fromFirestore).toList();
  }

  /// Admin-only total (server count aggregation — no full read).
  Future<int> countAll() async {
    final snap = await _col.count().get();
    return snap.count ?? 0;
  }

  /// Admin-only commission earnings: server-side sum of `serviceFee` over
  /// active (non-cancelled) bookings. Definition: gross collected service
  /// fees excluding cancelled bookings; manual refunds (`owed`) are NOT
  /// subtracted (no money movement is recorded on-chain). No composite
  /// index needed (single `whereIn`, no ordering).
  Future<double> earningsTotal() async {
    final snap = await _col
        .where('status', whereIn: ['pending', 'confirmed', 'completed'])
        .aggregate(sum('serviceFee'))
        .get();
    return (snap.getSum('serviceFee') ?? 0).toDouble();
  }

  /// Tourist cancels own UNPAID booking. Only `status=cancelled` + reason are
  /// written; rules verify ownership, active status, an unpaid payment, and
  /// that no price/identity field changed. Paid bookings are rejected by
  /// rules — use the `cancelBooking` callable (via
  /// `BookingsRepository.cancelViaServer`) so refund bookkeeping applies.
  /// Capacity release + guide notification happen in Functions.
  Future<void> cancelByTourist(String bookingId, {String reason = ''}) async {
    await _col.doc(bookingId).set({
      'status': 'cancelled',
      'cancelReason': reason,
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<int> countActiveForTrip(String tripId) {
    return _col
        .where('tripId', isEqualTo: tripId)
        .where('status', whereIn: ['pending', 'confirmed'])
        .snapshots()
        .map((s) => s.size);
  }
}
