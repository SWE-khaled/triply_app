import 'package:flutter/foundation.dart';

/// Explicit states for the signed-in tourist's profile document.
@immutable
sealed class ProfileDetailsState {
  const ProfileDetailsState({
    this.name = '',
    this.photoUrl = '',
    this.photoWasCleared = false,
    this.city = '',
    this.country = '',
    this.bio = '',
    required this.isLoading,
    required this.hasLoaded,
    this.errorMessage,
  });

  final String name;
  final String photoUrl;
  final bool photoWasCleared;
  final String city;
  final String country;
  final String bio;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  String? photoUrlWithAuthFallback(String? authPhotoUrl) {
    if (photoUrl.trim().isNotEmpty) return photoUrl;
    return photoWasCleared ? null : authPhotoUrl;
  }
}

final class ProfileDetailsInitial extends ProfileDetailsState {
  const ProfileDetailsInitial({
    super.isLoading = false,
    super.hasLoaded = false,
  });
}

final class ProfileDetailsLoading extends ProfileDetailsState {
  const ProfileDetailsLoading() : super(isLoading: true, hasLoaded: false);
}

final class ProfileDetailsReady extends ProfileDetailsState {
  const ProfileDetailsReady({
    required super.name,
    required super.photoUrl,
    required super.photoWasCleared,
    required super.city,
    required super.country,
    required super.bio,
  }) : super(isLoading: false, hasLoaded: true);
}

/// Keeps the last known fields so a failed retry never blanks the profile.
final class ProfileDetailsError extends ProfileDetailsState {
  const ProfileDetailsError({
    required String message,
    required super.name,
    required super.photoUrl,
    required super.photoWasCleared,
    required super.city,
    required super.country,
    required super.bio,
    required super.hasLoaded,
  }) : super(errorMessage: message, isLoading: false);
}
