import 'package:flutter/foundation.dart';

import '../model/trip.dart';

@immutable
sealed class HomeTripsState {
  const HomeTripsState();
}

final class HomeTripsInitial extends HomeTripsState {
  const HomeTripsInitial();
}

final class HomeTripsLoading extends HomeTripsState {
  const HomeTripsLoading();
}

final class HomeTripsSuccess extends HomeTripsState {
  final List<Trip> trips;

  const HomeTripsSuccess({required this.trips});
}

final class HomeTripsError extends HomeTripsState {
  final String message;

  const HomeTripsError({required this.message});
}
