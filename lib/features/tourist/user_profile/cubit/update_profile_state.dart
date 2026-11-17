import 'package:flutter/foundation.dart';

/// Explicit states for saving the Edit profile sheet.
@immutable
sealed class UpdateProfileState {
  const UpdateProfileState({this.message});

  final String? message;
}

final class UpdateProfileInitial extends UpdateProfileState {
  const UpdateProfileInitial();
}

final class UpdateProfileLoading extends UpdateProfileState {
  const UpdateProfileLoading();
}

final class ProfileUpdateSucceeded extends UpdateProfileState {
  const ProfileUpdateSucceeded() : super(message: 'Profile updated.');
}

final class ProfileUpdateFailed extends UpdateProfileState {
  const ProfileUpdateFailed({required String message}) : super(message: message);
}
