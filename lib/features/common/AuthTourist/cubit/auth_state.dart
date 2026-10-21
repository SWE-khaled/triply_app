part of 'auth_cubit.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

/// Nothing happened yet — the first Firebase auth event is still on its
/// way.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A sign-in / sign-up / password reset is running.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Signed in.
final class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess({required this.user});
}

/// Signed out.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// The last action failed.
final class AuthError extends AuthState {
  final String error;

  const AuthError({required this.error});
}
