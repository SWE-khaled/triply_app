import 'mock/mock_guide_trip_details.dart';
import '../features/tour_guide/trip_details/model/guide_trip_details.dart';

/// Shared mock-phase lookup: mock JSON -> Model.
/// Future API swap: build GuideTripDetails from API JSON here instead.
class GuideTripDetailsSource {
  const GuideTripDetailsSource();

  static final Map<String, GuideTripDetails> _overrides =
      <String, GuideTripDetails>{};

  /// Session-saved edits (mock phase). Cleared on restart.
  static void save(GuideTripDetails details) {
    _overrides[details.tripId] = details;
  }

  List<GuideTripDetails> get all => mockGuideTripDetailsJson
      .map((e) => GuideTripDetails.fromJson(e))
      .toList();

  /// Trips without mock data fall back to the first entry but keep
  /// the trip's own card fields so they never show another trip.
  GuideTripDetails getByTripId(
    String tripId, {
    String? title,
    String? imageUrl,
    double? priceEgp,
  }) {
    final saved = _overrides[tripId];
    if (saved != null) return saved;
    for (final d in all) {
      if (d.tripId == tripId) return d;
    }
    final base = all.first;
    return GuideTripDetails(
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
      included: base.included,
      meetingPoint: base.meetingPoint,
      priceEgp: priceEgp ?? base.priceEgp,
      guideName: base.guideName,
      guideAvatarUrl: base.guideAvatarUrl,
      guideRating: base.guideRating,
      guideReviews: base.guideReviews,
      imageUrl: imageUrl ?? base.imageUrl,
    );
  }
}
