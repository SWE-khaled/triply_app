part of 'guide_trips_cubit.dart';

@immutable
sealed class GuideTripsState {
  const GuideTripsState();
}

final class GuideTripsInitial extends GuideTripsState {
  const GuideTripsInitial();
}

final class GuideTripsLoading extends GuideTripsState {
  const GuideTripsLoading();
}

final class GuideTripsSuccess extends GuideTripsState {
  /// The tab the list is filtered by.
  final GuideTripStatus selectedStatus;

  /// The trips of that tab.
  final List<GuideTrip> trips;

  const GuideTripsSuccess({required this.selectedStatus, required this.trips});
}

final class GuideTripsError extends GuideTripsState {
  final String error;

  const GuideTripsError({required this.error});
}
