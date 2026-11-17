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

/// The Home shell state. Only the notification badge lives here now;
/// the content sections have their own Cubits.
final class HomeSuccess extends HomeState {
  /// How many notifications the tourist did not read yet.
  final int unreadNotifications;

  const HomeSuccess({required this.unreadNotifications});
}

final class HomeError extends HomeState {
  final String error;

  const HomeError({required this.error});
}
