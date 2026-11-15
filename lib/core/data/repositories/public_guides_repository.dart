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
  /// A successful empty list means no approved guides exist. Read errors
  /// propagate to the caller so they cannot be mistaken for an empty result.
  Future<List<PublicGuide>> fetchApprovedGuides() async {
    final snapshot = await _firestore
        .collection(guidesCollection)
        .where('isApproved', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => PublicGuide.fromDocument(doc.data(), doc.id))
        .toList();
  }

  /// One guide, or null when the profile does not exist.
  ///
  /// Read errors propagate; null is reserved for a missing profile.
  Future<PublicGuide?> fetchGuide(String guideId) async {
    if (guideId.isEmpty) return null;
    final data = await _firestore.readDoc(guidesCollection, guideId);
    if (data == null) return null;
    return PublicGuide.fromDocument(data, guideId);
  }
}
