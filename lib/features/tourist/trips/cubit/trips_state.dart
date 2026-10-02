import '../models/trip.dart';

class TripsState {
  final TripStatus selectedTab;
  final List<Trip> trips;

  const TripsState({required this.selectedTab, required this.trips});

  TripsState copyWith({TripStatus? selectedTab, List<Trip>? trips}) {
    return TripsState(
      selectedTab: selectedTab ?? this.selectedTab,
      trips: trips ?? this.trips,
    );
  }
}
