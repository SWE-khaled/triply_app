import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/review_doc.dart';

/// `reviews/{tripId_touristId}` — one review per tourist per trip (roadmap).
///
/// No review UI exists in the current Flutter code; this datasource is
/// provided so ratings can become persistent without a schema migration.
/// Functions maintain trip/guide rating aggregates on write.
class ReviewsDatasource {
  final FirebaseFirestore _db;
  ReviewsDatasource([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.reviews);

  Future<ReviewDoc?> getByTripAndTourist(
    String tripId,
    String touristId,
  ) async {
    final doc =
        await _col.doc(ReviewDoc.docIdFor(tripId, touristId)).get();
    if (!doc.exists) return null;
    return ReviewDoc.fromFirestore(doc);
  }

  Future<List<ReviewDoc>> listByTrip(String tripId, {int limit = 50}) async {
    final snap = await _col
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(ReviewDoc.fromFirestore).toList();
  }

  Future<void> upsert(ReviewDoc doc) async {
    await _col.doc(ReviewDoc.docIdFor(doc.tripId, doc.touristId)).set(
          doc.toCreateMap(),
          SetOptions(merge: true),
        );
  }
}
