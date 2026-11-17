import '../models/trip.dart';

/// Explicit states for the public trips list.
///
/// The fields live on the base class so existing callers that read
/// `isLoading`, `trips`, `error` and `selectedTab` keep working. No state is
/// rebuilt from a previous state.
sealed class TripsState {
  const TripsState({
    required this.selectedTab,
    required this.trips,
    this.isLoading = false,
    this.error,
  });

  final TripStatus selectedTab;
  final List<Trip> trips;
  final bool isLoading;
  final String? error;
}

final class TripsInitial extends TripsState {
  const TripsInitial({required super.selectedTab})
    : super(trips: const [], isLoading: true);
}

final class TripsLoading extends TripsState {
  const TripsLoading({required super.selectedTab})
    : super(trips: const [], isLoading: true);
}

final class TripsSuccess extends TripsState {
  const TripsSuccess({required super.selectedTab, required super.trips});
}

final class TripsError extends TripsState {
  const TripsError({required super.selectedTab, required String message})
    : super(trips: const [], error: message);
}
