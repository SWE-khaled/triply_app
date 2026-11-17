import 'package:flutter/foundation.dart';

/// Explicit states for the Settings logout action.
@immutable
sealed class LogoutState {
  const LogoutState({this.message});

  final String? message;
}

final class LogoutInitial extends LogoutState {
  const LogoutInitial();
}

final class LoggingOut extends LogoutState {
  const LoggingOut();
}

final class LoggedOut extends LogoutState {
  const LoggedOut();
}

final class LogoutError extends LogoutState {
  const LogoutError({required String message}) : super(message: message);
}
