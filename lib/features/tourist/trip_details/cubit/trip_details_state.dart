part of 'trip_details_cubit.dart';

@immutable
sealed class TripDetailsState {
  const TripDetailsState();
}

final class TripDetailsInitial extends TripDetailsState {
  const TripDetailsInitial();
}

final class TripDetailsLoading extends TripDetailsState {
  const TripDetailsLoading();
}

final class TripDetailsSuccess extends TripDetailsState {
  /// The details of the trip.
  final TripDetails details;

  /// The tab of the details that is open.
  final int selectedTab;

  /// Whether the tourist marked the trip as a favorite.
  final bool isFavorite;

  const TripDetailsSuccess({
    required this.details,
    required this.selectedTab,
    required this.isFavorite,
  });
}

final class TripDetailsError extends TripDetailsState {
  final String error;

  const TripDetailsError({required this.error});
}
