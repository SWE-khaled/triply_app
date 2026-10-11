import 'mock/tourist/mock_trip_details.dart';
import '../../features/tourist/trip_details/model/trip_details.dart';

/// Shared mock-phase lookup: mock JSON -> Model.
/// Cubits call this; Views never touch it.
/// Future API swap: build TripDetails from API JSON here instead.
class TripDetailsSource {
  const TripDetailsSource();

  List<TripDetails> get all =>
      mockTripDetailsJson.map((e) => TripDetails.fromJson(e)).toList();

  /// Returns details for [tripId], or an honest empty shell built ONLY from
  /// the trip's own card fields when no mock entry matches.
  ///
  /// Never copies another trip's about/highlights/itinerary/notes: showing
  /// the first mock trip's content for an unknown id presents wrong data as
  /// real. Empty sections render as empty (never as another trip), and the
  /// remote refresh replaces the shell with Firestore details on success.
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
    return TripDetails(
      id: 'fallback-$tripId',
      tripId: tripId,
      tag: '',
      title: title ?? 'Trip',
      rating: 0,
      reviewsCount: 0,
      location: '',
      duration: '',
      groupType: '',
      languages: '',
      about: '',
      highlights: const [],
      itinerary: const [],
      notes: const [],
      meetingPoint: '',
      priceEgp: priceEgp ?? 0,
      guideName: guideName ?? '',
      guideAvatarUrl: '',
      guideRating: 0,
      guideReviews: 0,
      topRatedGuide: false,
      imageUrl: imageUrl ?? '',
    );
  }
}
