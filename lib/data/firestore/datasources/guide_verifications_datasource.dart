import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/guide_verification_doc.dart';

/// `guideVerifications/{id}` — owner creates/reads own; admin decides via
/// Functions. Clients never write `status`/`reviewerId`/`reviewedAt`.
class GuideVerificationsDatasource {
  FirebaseFirestore? _dbInit;
  GuideVerificationsDatasource([FirebaseFirestore? db]) : _dbInit = db;

  // Lazy: constructing the datasource must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  FirebaseFirestore get _db => _dbInit ??= FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.guideVerifications);

  /// Submits (or re-submits) a verification. Uses a stable doc id
  /// `guideId` so re-submission overwrites instead of duplicating.
  Future<String> submit({
    required String guideId,
    required String idDocumentUrl,
    required String licenseDocumentUrl,
  }) async {
    final doc = GuideVerificationDoc(
      id: guideId,
      guideId: guideId,
      idDocumentUrl: idDocumentUrl,
      licenseDocumentUrl: licenseDocumentUrl,
    );
    await _col.doc(guideId).set(doc.toCreateMap(), SetOptions(merge: false));
    return guideId;
  }

  Future<GuideVerificationDoc?> getByGuide(String guideId) async {
    final doc = await _col.doc(guideId).get();
    if (!doc.exists) return null;
    return GuideVerificationDoc.fromFirestore(doc);
  }

  Stream<GuideVerificationDoc?> streamByGuide(String guideId) {
    return _col
        .doc(guideId)
        .snapshots()
        .map((d) => d.exists ? GuideVerificationDoc.fromFirestore(d) : null);
  }

  Future<List<GuideVerificationDoc>> listPending({int limit = 50}) async {
    final snap = await _col
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt')
        .limit(limit)
        .get();
    return snap.docs.map(GuideVerificationDoc.fromFirestore).toList();
  }

  /// Admin-only review history: newest verifications of any status.
  Future<List<GuideVerificationDoc>> listRecent({int limit = 50}) async {
    final snap = await _col
        .orderBy('submittedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(GuideVerificationDoc.fromFirestore).toList();
  }

  /// Admin-only pending total (server count aggregation).
  Future<int> countPending() async {
    final snap = await _col.where('status', isEqualTo: 'pending').count().get();
    return snap.count ?? 0;
  }
}
