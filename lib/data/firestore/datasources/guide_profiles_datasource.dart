import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/guide_profile_doc.dart';
import 'firestore_query_helper.dart';

/// `guideProfiles/{uid}` reads/writes + public search.
class GuideProfilesDatasource {
  FirebaseFirestore? _dbInit;
  GuideProfilesDatasource([FirebaseFirestore? db]) : _dbInit = db;

  // Lazy: constructing the datasource must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  FirebaseFirestore get _db => _dbInit ??= FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.guideProfiles);

  Future<GuideProfileDoc?> getByUserId(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return GuideProfileDoc.fromFirestore(doc);
  }

  /// Public contact lookup by display name (powers the trip-details
  /// guide-contact row). Equality-only: no composite index needed.
  /// Prefer this over `users` queries, which deployed rules restrict.
  Future<GuideProfileDoc?> getByDisplayName(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return null;
    final snap = await _col
        .where('displayName', isEqualTo: clean)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return GuideProfileDoc.fromFirestore(snap.docs.first);
  }

  Stream<GuideProfileDoc?> streamByUserId(String uid) {
    return _col
        .doc(uid)
        .snapshots()
        .map((d) => d.exists ? GuideProfileDoc.fromFirestore(d) : null);
  }

  /// Verified guides for the tourist Guides list (paginated).
  Future<({List<GuideProfileDoc> items, Object? last, bool hasMore})>
  listVerified({int limit = 20, Object? startAfter}) async {
    final q = _col
        .where('isVerified', isEqualTo: true)
        .orderBy('ratingAvg', descending: true);
    final page = await FirestoreQueryHelper.paginate(
      q,
      limit: limit,
      startAfter: startAfter,
    );
    return (
      items: page.docs.map(GuideProfileDoc.fromFirestore).toList(),
      last: page.last,
      hasMore: page.hasMore,
    );
  }

  Future<void> upsertClientFields(GuideProfileDoc doc) async {
    await _col.doc(doc.userId).set(doc.toClientMap(), SetOptions(merge: true));
  }

  /// Merges owner-editable public fields only. Server-owned flags
  /// (`isVerified`, `canPublishTrips`, ratings) are never written here —
  /// attempting them would fail the whole write under deployed rules, so
  /// they are not even accepted as parameters.
  Future<void> updatePublicFields(
    String uid, {
    String? displayName,
    String? contactPhone,
    String? about,
    String? location,
    String? coverUrl,
  }) async {
    final data = <String, dynamic>{
      // ignore: use_null_aware_elements
      if (displayName != null) 'displayName': displayName,
      // ignore: use_null_aware_elements
      if (contactPhone != null) 'contactPhone': contactPhone,
      // ignore: use_null_aware_elements
      if (about != null) 'about': about,
      // ignore: use_null_aware_elements
      if (location != null) 'location': location,
      // ignore: use_null_aware_elements
      if (coverUrl != null) 'coverUrl': coverUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _col.doc(uid).set(data, SetOptions(merge: true));
  }
}
