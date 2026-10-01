import '../../../data/mock/mock_guides1.dart';
import '../../../data/mock/mock_places.dart';
import '../../../data/mock/mock_stories.dart';
import '../../../data/mock/mock_place_trips.dart';
import '../model/guide.dart';
import '../../map/model/place.dart';
import '../model/story.dart';
import '../model/trip.dart';

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

  void toggleFavorite() {
    place.isFavorite = !place.isFavorite;
  }
}
