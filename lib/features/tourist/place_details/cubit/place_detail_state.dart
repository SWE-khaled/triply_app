import '../../map/model/place.dart';
import '../model/guide.dart';
import '../model/story.dart';
import '../model/trip.dart';

class PlaceDetailState {
  final Place place;
  final List<Guide> guides;
  final List<Trip> trips;
  final List<Story> stories;
  final int selectedTabIndex;

  const PlaceDetailState({
    required this.place,
    required this.guides,
    required this.trips,
    required this.stories,
    this.selectedTabIndex = 0,
  });

  PlaceDetailState copyWith({
    Place? place,
    List<Guide>? guides,
    List<Trip>? trips,
    List<Story>? stories,
    int? selectedTabIndex,
  }) {
    return PlaceDetailState(
      place: place ?? this.place,
      guides: guides ?? this.guides,
      trips: trips ?? this.trips,
      stories: stories ?? this.stories,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}
