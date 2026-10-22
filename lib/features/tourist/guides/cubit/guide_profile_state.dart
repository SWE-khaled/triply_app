part of 'guide_profile_cubit.dart';

@immutable
sealed class GuideProfileState {
  const GuideProfileState();
}

final class GuideProfileInitial extends GuideProfileState {
  const GuideProfileInitial();
}

final class GuideProfileLoading extends GuideProfileState {
  const GuideProfileLoading();
}

final class GuideProfileSuccess extends GuideProfileState {
  /// The guide the screen shows.
  final Guide guide;

  /// The approved trips of that guide.
  final List<Trip> trips;

  /// Whether the tourist bookmarked the guide.
  final bool isBookmarked;

  const GuideProfileSuccess({
    required this.guide,
    required this.trips,
    required this.isBookmarked,
  });
}

final class GuideProfileError extends GuideProfileState {
  final String error;

  const GuideProfileError({required this.error});
}
