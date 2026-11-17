import 'package:flutter/foundation.dart';

/// Compatibility state for the session-level profile preferences.
///
/// The profile data, posts, update and logout flows now have their own states.
/// `notificationsEnabled` deliberately keeps its original field name and
/// remains the value read by the Settings switch.
@immutable
sealed class ProfileState {
  const ProfileState({
    this.notificationsEnabled = true,
    this.selectedLanguage = 'English',
  });

  final bool notificationsEnabled;
  final String selectedLanguage;
}

final class ProfileReady extends ProfileState {
  const ProfileReady({
    required super.notificationsEnabled,
    required super.selectedLanguage,
  });
}
