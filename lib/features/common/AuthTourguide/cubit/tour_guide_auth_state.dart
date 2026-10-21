part of 'tour_guide_auth_cubit.dart';

@immutable
sealed class TourGuideAuthState {
  const TourGuideAuthState();
}

/// Nothing happened yet.
final class TourGuideAuthInitial extends TourGuideAuthState {
  const TourGuideAuthInitial();
}

/// A registration / login is running.
final class TourGuideAuthLoading extends TourGuideAuthState {
  const TourGuideAuthLoading();
}

/// The account is in.
final class TourGuideAuthSuccess extends TourGuideAuthState {
  /// The role of the account: `guide` or `tourist`. It decides where the
  /// user goes next.
  final String role;

  const TourGuideAuthSuccess({required this.role});
}

/// The last action failed.
final class TourGuideAuthError extends TourGuideAuthState {
  final String error;

  const TourGuideAuthError({required this.error});
}
