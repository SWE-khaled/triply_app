part of 'place_detail_cubit.dart';

@immutable
sealed class PlaceDetailState {
  const PlaceDetailState();
}

final class PlaceDetailInitial extends PlaceDetailState {
  const PlaceDetailInitial();
}

final class PlaceDetailLoadingState extends PlaceDetailState {
  const PlaceDetailLoadingState();
}

final class PlaceDetailSuccessState extends PlaceDetailState {
  /// The place the screen shows.
  final Place place;

  /// The guides of the place.
  final List<Guide> guides;

  /// The trips of the place.
  final List<Trip> trips;

  /// The stories of the place.
  final List<Story> stories;

  /// The tab that is open.
  final int selectedTabIndex;

  const PlaceDetailSuccessState({
    required this.place,
    required this.guides,
    required this.trips,
    required this.stories,
    required this.selectedTabIndex,
  });
}

final class PlaceDetailErrorState extends PlaceDetailState {
  final String error;

  const PlaceDetailErrorState({required this.error});
}
