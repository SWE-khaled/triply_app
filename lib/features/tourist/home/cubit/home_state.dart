part of 'home_cubit.dart';

@immutable
sealed class HomeState {
  const HomeState();
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeSuccess extends HomeState {
  /// The places of the "Popular Places" row.
  final List<Place> places;

  /// The local guides of the "Local Guides" row.
  final List<Guide> guides;

  /// The trips of the "Trending Trips" row.
  final List<Trip> trips;

  /// The tab of the bottom navigation.
  final int bottomNavIndex;

  /// How many notifications the tourist did not read yet.
  final int unreadNotifications;

  const HomeSuccess({
    required this.places,
    required this.guides,
    required this.trips,
    required this.bottomNavIndex,
    this.unreadNotifications = 0,
  });
}

final class HomeError extends HomeState {
  final String error;

  const HomeError({required this.error});
}
