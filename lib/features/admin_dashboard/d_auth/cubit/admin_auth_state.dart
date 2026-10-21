part of 'admin_auth_cubit.dart';

@immutable
sealed class AdminAuthState {
  const AdminAuthState();
}

/// Nothing happened yet.
final class AdminAuthInitial extends AdminAuthState {
  const AdminAuthInitial();
}

/// A login / sign-up is running.
final class AdminAuthLoading extends AdminAuthState {
  const AdminAuthLoading();
}

/// The admin is in.
final class AdminAuthSuccess extends AdminAuthState {
  final AdminSession session;

  const AdminAuthSuccess({required this.session});
}

/// The last action failed.
final class AdminAuthError extends AdminAuthState {
  final String error;

  const AdminAuthError({required this.error});
}

/// The admin signed out.
final class AdminAuthLoggedOut extends AdminAuthState {
  const AdminAuthLoggedOut();
}
