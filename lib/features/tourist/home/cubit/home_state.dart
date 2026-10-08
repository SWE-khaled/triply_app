import '../model/guide.dart';
import '../model/place.dart';
import '../model/trip.dart';

class HomeState {
  final List<Place> places;
  final List<Guide> guides;
  final List<Trip> trips;
  final int bottomNavIndex;

  const HomeState({
    required this.places,
    required this.guides,
    required this.trips,
    this.bottomNavIndex = 0,
  });

  HomeState copyWith({
    List<Place>? places,
    List<Guide>? guides,
    List<Trip>? trips,
    int? bottomNavIndex,
  }) {
    return HomeState(
      places: places ?? this.places,
      guides: guides ?? this.guides,
      trips: trips ?? this.trips,
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
    );
  }
}
