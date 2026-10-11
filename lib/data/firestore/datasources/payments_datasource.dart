import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/payment_doc.dart';

/// `payments/{paymentId}` reads + pending-record creation.
///
/// The client creates a `pending` record before opening the Paymob iframe
/// (so the booking has something to reconcile against). ONLY the trusted
/// Paymob verification Function may move it to `succeeded`/`failed`
/// (rules enforce: clients can create `pending`, never escalate).
class PaymentsDatasource {
  FirebaseFirestore? _dbInit;
  PaymentsDatasource([FirebaseFirestore? db]) : _dbInit = db;

  // Lazy: constructing the datasource must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  FirebaseFirestore get _db => _dbInit ??= FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.payments);

  Future<PaymentDoc?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return PaymentDoc.fromFirestore(doc);
  }

  Future<PaymentDoc?> getByBooking(String bookingId) async {
    final snap = await _col
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return PaymentDoc.fromFirestore(snap.docs.first);
  }

  Stream<PaymentDoc?> streamByBooking(String bookingId) {
    return _col
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .snapshots()
        .map(
          (s) => s.docs.isEmpty ? null : PaymentDoc.fromFirestore(s.docs.first),
        );
  }

  /// Creates the `pending` reconciliation record. Never stores PAN/CVV —
  /// only provider refs + amount. Returns the payment doc id.
  Future<String> createPending(PaymentDoc doc) async {
    final ref = _col.doc();
    await ref.set({...doc.toCreateMap(), 'touristId': doc.touristId});
    return ref.id;
  }
}
