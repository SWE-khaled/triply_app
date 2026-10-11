import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `reviews/{reviewId}` document.
///
/// No review UI exists in the current Flutter code (verified 2026-10-09:
/// `rating`/`reviewCount` are display-only fields on Trip/Guide models).
/// This collection is provided for the roadmap so ratings can become
/// persistent later WITHOUT a schema migration.
///
/// Enforcement: one review per (tripId, touristId) — id `tripId_touristId`;
/// Functions maintain `trips` rating aggregates + `guideProfiles` averages.
class ReviewDoc {
  final String id;
  final String tripId;
  final String touristId;
  final String guideId;
  final int rating; // 1..5
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewDoc({
    required this.id,
    required this.tripId,
    required this.touristId,
    required this.guideId,
    required this.rating,
    this.comment = '',
    this.createdAt,
    this.updatedAt,
  });

  static String docIdFor(String tripId, String touristId) =>
      '${tripId}_$touristId';

  factory ReviewDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return ReviewDoc.fromMap(d, doc.id);
  }

  factory ReviewDoc.fromMap(Map<String, dynamic> d, String id) {
    final r = FirestoreConverters.toInt(d['rating'], 5).clamp(1, 5);
    return ReviewDoc(
      id: FirestoreConverters.toStr(d['id'], id),
      tripId: FirestoreConverters.toStr(d['tripId']),
      touristId: FirestoreConverters.toStr(d['touristId']),
      guideId: FirestoreConverters.toStr(d['guideId']),
      rating: r,
      comment: FirestoreConverters.toStr(d['comment']),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
      updatedAt: FirestoreConverters.toDateTime(d['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'tripId': tripId,
      'touristId': touristId,
      'guideId': guideId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'touristId': touristId,
      'guideId': guideId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
