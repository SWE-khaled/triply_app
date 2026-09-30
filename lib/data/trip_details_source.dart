import 'mock/mock_trip_details.dart';
import '../features/trip_details/model/trip_details.dart';

/// Shared mock-phase lookup: mock JSON -> Model.
/// Cubits call this; Views never touch it.
/// Future API swap: build TripDetails from API JSON here instead.
class TripDetailsSource {
  const TripDetailsSource();

  List<TripDetails> get all =>
      mockTripDetailsJson.map((e) => TripDetails.fromJson(e)).toList();

  /// Returns details for [tripId]. Trips without mock data fall back
  /// to the first entry but keep the trip's own card fields
  /// (title/image/price/guide) so they never show another trip's content.
  TripDetails getByTripId(
    String tripId, {
    String? title,
    String? imageUrl,
    double? priceEgp,
    String? guideName,
  }) {
    for (final d in all) {
      if (d.tripId == tripId) return d;
    }
    final base = all.first;
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
