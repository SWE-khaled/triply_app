import '../model/admin_session.dart';

enum AdminAuthStatus { initial, loading, success, error, loggedOut }

class AdminAuthState {
  final AdminAuthStatus status;
  final String? errorMessage;
  final AdminSession? session;

  const AdminAuthState({
    this.status = AdminAuthStatus.initial,
    this.errorMessage,
    this.session,
  });

  AdminAuthState copyWith({
    AdminAuthStatus? status,
    String? errorMessage,
    AdminSession? session,
  }) {
    return AdminAuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      session: session ?? this.session,
    );
  }
}
