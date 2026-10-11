import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/place_doc.dart';
import 'firestore_query_helper.dart';

/// `places/{placeId}` reads (public) + prefix search on `nameLower`.
class PlacesDatasource {
  final FirebaseFirestore _db;
  PlacesDatasource([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.places);

  Future<PlaceDoc?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return PlaceDoc.fromFirestore(doc);
  }

  Future<({List<PlaceDoc> items, Object? last, bool hasMore})> list({
    String? category,
    int limit = 20,
    Object? startAfter,
  }) async {
    Query<Map<String, dynamic>> q = _col.orderBy('rating', descending: true);
    if (category != null && category.isNotEmpty && category != 'All') {
      q = _col.where('category', isEqualTo: category).orderBy('rating',
          descending: true);
    }
    final page = await FirestoreQueryHelper.paginate(
      q,
      limit: limit,
      startAfter: startAfter,
    );
    return (
      items: page.docs.map(PlaceDoc.fromFirestore).toList(),
      last: page.last,
      hasMore: page.hasMore,
    );
  }

  /// Prefix search over the denormalized `nameLower` field.
  Future<List<PlaceDoc>> searchByName(String query, {int limit = 20}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final snap = await _col
        .where('nameLower', isGreaterThanOrEqualTo: q)
        .where('nameLower', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(limit)
        .get();
    return snap.docs.map(PlaceDoc.fromFirestore).toList();
  }

  Future<List<PlaceDoc>> listByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    // `whereIn` caps at 10 — chunk.
    final out = <PlaceDoc>[];
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(
        i,
        i + 10 > ids.length ? ids.length : i + 10,
      );
      final snap =
          await _col.where(FieldPath.documentId, whereIn: chunk).get();
      out.addAll(snap.docs.map(PlaceDoc.fromFirestore));
    }
    return out;
  }
}
