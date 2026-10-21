part of 'profile_tg_cubit.dart';

@immutable
sealed class ProfileTgState {
  const ProfileTgState();
}

final class ProfileTgInitial extends ProfileTgState {
  const ProfileTgInitial();
}

final class ProfileTgLoading extends ProfileTgState {
  const ProfileTgLoading();
}

final class ProfileTgSuccess extends ProfileTgState {
  /// Name typed by the guide before Firebase Auth knows it.
  final String? nameOverride;

  /// Photo picked by the guide before Firebase Auth knows it.
  final String? photoOverride;

  /// Local path of the picked cover image.
  final String? coverPath;

  /// Whether the guide bookmarked this profile.
  final bool bookmarked;

  /// Phone read from Firestore.
  final String? remotePhone;

  /// About read from Firestore.
  final String? remoteAbout;

  /// Location read from Firestore.
  final String? remoteLocation;

  const ProfileTgSuccess({
    required this.nameOverride,
    required this.photoOverride,
    required this.coverPath,
    required this.bookmarked,
    required this.remotePhone,
    required this.remoteAbout,
    required this.remoteLocation,
  });
}

final class ProfileTgError extends ProfileTgState {
  final String error;

  const ProfileTgError({required this.error});
}
