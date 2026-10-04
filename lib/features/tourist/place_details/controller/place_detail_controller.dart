import '../../../../core/data/mock/tourist/mock_guides.dart' as guides_src;
import '../../../../core/data/mock/tourist/mock_guides1.dart';
import '../../../../core/data/mock/tourist/mock_places.dart';
import '../../../../core/data/mock/tourist/mock_stories.dart';
import '../../../../core/data/mock/tourist/mock_place_trips.dart';
import '../../../../core/data/mock/tourist/mock_trips_public.dart';
import '../model/guide.dart';
import '../../map/model/place.dart';
import '../model/story.dart';
import '../model/trip.dart';
import '../../trips/models/trip.dart' as trips_model;

class PlaceDetailController {
  final String placeId;

  late final Place place;
  late final List<Guide> guides;
  late final List<Trip> trips;
  late final List<Story> stories;

  int selectedTabIndex = 0;

  PlaceDetailController({required this.placeId}) {
    final placeJson = mockPlaces.firstWhere(
      (e) => e['id'] == placeId,
      orElse: () => mockPlaces.first,
    );
    place = Place.fromJson(placeJson);
    guides = mockGuides1.map((e) => Guide.fromJson(e)).toList();
    trips = mockPlaceTrips
        .where((e) => e['place_id'] == place.id)
        .map((e) => Trip.fromJson(e))
        .toList();
    stories = mockStories
        .where((e) => e['place_id'] == place.id)
        .map((e) => Story.fromJson(e))
        .toList();
  }

  void selectTab(int index) {
    selectedTabIndex = index;
  }

  /// Resolves a place guide to the Guide Profile id by matching the existing
  /// guide name against the Local Guides list (same source as See All).
  String guideProfileIdFor(Guide guide) {
    for (final g in guides_src.mockGuides) {
      if (g.name == guide.name) return g.id;
    }
    return guides_src.mockGuides.first.id;
  }

  /// Resolves a place trip to the existing public-trip model so it can open
  /// Trip Details / Public Booking. Prefers the matching mock public trip
  /// (same id or title); otherwise maps fields with the model's defaults.
  trips_model.Trip publicTripFor(Trip trip) {
    for (final e in mockTripsJson) {
      if (e['id'] == trip.id || e['title'] == trip.title) {
        return trips_model.Trip.fromJson(e);
      }
    }
    return trips_model.Trip(
      id: trip.id,
      title: trip.title,
      dateLabel: trip.dateTime,
      guideName: trip.guideName,
      peopleCount: trip.peopleCount,
      priceEgp: trip.price,
      imageUrl: trip.imageUrl,
      status: trips_model.TripStatus.upcoming,
      category: 'historical',
      capacity: 12,
    );
  }

  void toggleFavorite() {
    place.isFavorite = !place.isFavorite;
  }
}
