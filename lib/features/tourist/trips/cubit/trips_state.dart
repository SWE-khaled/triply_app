import '../models/trip.dart';

class TripsState {
  final TripStatus selectedTab;
  final List<Trip> trips;
  final bool isLoading;
  final String? error;

  const TripsState({
    required this.selectedTab,
    required this.trips,
    this.isLoading = false,
    this.error,
  });

  TripsState copyWith({
    TripStatus? selectedTab,
    List<Trip>? trips,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TripsState(
      selectedTab: selectedTab ?? this.selectedTab,
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}
