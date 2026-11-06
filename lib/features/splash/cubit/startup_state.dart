import 'package:flutter/foundation.dart';

/// The screen the app opens on after the splash animation.
enum StartupDestination {
  touristHome,
  touristLogin,
  guideHome,
  guideVerification,
  guideLogin,
  roleSelection,
  adminDashboard,
  adminLogin,
}

@immutable
sealed class StartupState {
  const StartupState();
}

/// The launch decision is still being made.
final class StartupLoading extends StartupState {
  const StartupLoading();
}

/// The session was resolved; [StartupGate] can show the destination.
final class StartupReady extends StartupState {
  final StartupDestination destination;

  /// Filled only for [StartupDestination.adminDashboard].
  final String? adminName;
  final String? adminEmail;

  const StartupReady({
    required this.destination,
    this.adminName,
    this.adminEmail,
  });
}

/// Reading the session failed in an unexpected way.
final class StartupError extends StartupState {
  final String message;

  const StartupError(this.message);
}
