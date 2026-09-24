import '../data/mock/mock_trip_details.dart';
import '../models/trip_details.dart';

/// Simple feature-focused controller. View holds tab/favorite state.
class TripDetailsController {
  final List<TripDetails> _all =
      mockTripDetailsJson.map((e) => TripDetails.fromJson(e)).toList();

  /// Returns details for [tripId]. Any trip without mock data falls back
  /// to the first entry but keeps the trip's own card fields
  /// (title/image/price/guide) so it never shows another trip's content.
  TripDetails getByTripId(
    String tripId, {
    String? title,
    String? imageUrl,
    double? priceEgp,
    String? guideName,
  }) {
    for (final d in _all) {
      if (d.tripId == tripId) return d;
    }
    final base = _all.first;
    return TripDetails(
      id: 'fallback',
      tripId: tripId,
      tag: base.tag,
      title: title ?? base.title,
      rating: base.rating,
      reviewsCount: base.reviewsCount,
      location: base.location,
      duration: base.duration,
      groupType: base.groupType,
      languages: base.languages,
      about: base.about,
      highlights: base.highlights,
      itinerary: base.itinerary,
      notes: base.notes,
      meetingPoint: base.meetingPoint,
      priceEgp: priceEgp ?? base.priceEgp,
      guideName: guideName ?? base.guideName,
      guideAvatarUrl: base.guideAvatarUrl,
      guideRating: base.guideRating,
      guideReviews: base.guideReviews,
      topRatedGuide: base.topRatedGuide,
      imageUrl: imageUrl ?? base.imageUrl,
    );
  }
}
