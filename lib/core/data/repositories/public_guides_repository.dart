import '../models/public_guide.dart';
import '../remote/firestore_service.dart';

/// The public profiles of the tour guides.
///
/// The tourists browse the approved guides only — the security rules
/// enforce the same thing.
class PublicGuidesRepository {
  PublicGuidesRepository({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService();

  /// The Firestore collection holding the public guide profiles.
  static const String guidesCollection = 'guides';

  final FirestoreService _firestore;

  /// The approved guides.
  ///
  /// Returns null when the read failed — that is the caller's cue to
  /// fall back to the mock dataset.
  Future<List<PublicGuide>?> fetchApprovedGuides() async {
    try {
      final snapshot = await _firestore
          .collection(guidesCollection)
          .where('isApproved', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => PublicGuide.fromDocument(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// One guide, or null when the profile does not exist.
  Future<PublicGuide?> fetchGuide(String guideId) async {
    if (guideId.isEmpty) return null;
    try {
      final data = await _firestore.readDoc(guidesCollection, guideId);
      if (data == null) return null;
      return PublicGuide.fromDocument(data, guideId);
    } catch (_) {
      return null;
    }
  }
}
