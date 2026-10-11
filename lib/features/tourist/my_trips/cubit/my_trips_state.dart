import '../../trips/models/trip.dart';

class MyTripsState {
  final TripStatus selectedTab;
  final List<Trip> trips;

  /// True during the initial server load (skeleton/spinner while empty).
  final bool isLoading;

  /// Last load/cancel failure message, if the visible list may be stale.
  /// Null when the list reflects the server (or is honestly empty).
  final String? error;

  /// Trip ids with a cancellation request in flight. Their delete
  /// affordance is disabled until the server answers (duplicate guard).
  final Set<String> cancellingIds;

  const MyTripsState({
    required this.selectedTab,
    required this.trips,
    this.isLoading = false,
    this.error,
    this.cancellingIds = const {},
  });

  MyTripsState copyWith({
    TripStatus? selectedTab,
    List<Trip>? trips,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Set<String>? cancellingIds,
  }) {
    return MyTripsState(
      selectedTab: selectedTab ?? this.selectedTab,
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      cancellingIds: cancellingIds ?? this.cancellingIds,
    );
  }
}
