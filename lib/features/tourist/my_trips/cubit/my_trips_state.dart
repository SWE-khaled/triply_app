import '../../trips/models/trip.dart';

class MyTripsState {
  final TripStatus selectedTab;
  final List<Trip> trips;

  const MyTripsState({required this.selectedTab, required this.trips});

  MyTripsState copyWith({TripStatus? selectedTab, List<Trip>? trips}) {
    return MyTripsState(
      selectedTab: selectedTab ?? this.selectedTab,
      trips: trips ?? this.trips,
    );
  }
}
