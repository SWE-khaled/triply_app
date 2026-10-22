part of 'my_trips_cubit.dart';

@immutable
sealed class MyTripsState {
  const MyTripsState();
}

final class MyTripsInitial extends MyTripsState {
  const MyTripsInitial();
}

final class MyTripsLoading extends MyTripsState {
  const MyTripsLoading();
}

final class MyTripsSuccess extends MyTripsState {
  /// The tab the list is filtered by.
  final TripStatus selectedTab;

  /// The booked trips of that tab.
  final List<Trip> trips;

  const MyTripsSuccess({required this.selectedTab, required this.trips});
}

final class MyTripsError extends MyTripsState {
  final String error;

  const MyTripsError({required this.error});
}
