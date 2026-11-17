import 'package:flutter/foundation.dart';

import '../model/trip.dart';

/// Explicit states for the approved trips of one place.
@immutable
sealed class PlaceTripsState {
  const PlaceTripsState();
}

final class PlaceTripsInitial extends PlaceTripsState {
  const PlaceTripsInitial();
}

final class PlaceTripsLoading extends PlaceTripsState {
  const PlaceTripsLoading();
}

final class PlaceTripsSuccess extends PlaceTripsState {
  const PlaceTripsSuccess({required this.trips});

  final List<Trip> trips;
}

final class PlaceTripsError extends PlaceTripsState {
  const PlaceTripsError({required this.error});

  final String error;
}
