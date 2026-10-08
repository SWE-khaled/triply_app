import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/admin_session.dart';
import 'admin_auth_state.dart';

/// Frontend-only admin authentication (demo/local implementation).
/// An identifier is accepted only when it contains 'triplykl'.
/// This is NOT real security: production must enforce an admin
/// role/permission on the server. No backend calls are made here.
class AdminAuthCubit extends Cubit<AdminAuthState> {
  /// In-memory demo accounts created via Create Account this session.
  final Map<String, AdminAccount> _accounts = {};

  AdminAuthCubit() : super(const AdminAuthState());

  /// Restores an existing session (used when entering the dashboard
  /// with an already-authenticated admin).
  AdminAuthCubit.authenticated(AdminSession session)
      : super(AdminAuthState(
            status: AdminAuthStatus.success, session: session));

  static const String accessDeniedMessage =
      'You are not allowed to access the Admin Dashboard.';

  static bool _hasAccess(String identifier) =>
      identifier.toLowerCase().contains('triplykl');

  static String _displayNameFor(String name, String email) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) return trimmed;
    final local = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (local.isEmpty) return 'Admin';
    return local[0].toUpperCase() + local.substring(1);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AdminAuthStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final cleanEmail = email.trim();
    if (!_hasAccess(cleanEmail)) {
      emit(state.copyWith(
        status: AdminAuthStatus.error,
        errorMessage: accessDeniedMessage,
      ));
      return false;
    }
    if (password.length < 6) {
      emit(state.copyWith(
        status: AdminAuthStatus.error,
        errorMessage: 'Password must be at least 6 characters.',
      ));
      return false;
    }
    final stored = _accounts[cleanEmail.toLowerCase()];
    final session = AdminSession(
      name: stored != null
          ? stored.name
          : _displayNameFor('', cleanEmail),
      email: cleanEmail,
    );
    emit(AdminAuthState(status: AdminAuthStatus.success, session: session));
    return true;
  }

  Future<bool> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AdminAuthStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final cleanEmail = email.trim();
    if (!_hasAccess(cleanEmail)) {
      emit(state.copyWith(
        status: AdminAuthStatus.error,
        errorMessage: accessDeniedMessage,
      ));
      return false;
    }
    if (name.trim().isEmpty) {
      emit(state.copyWith(
        status: AdminAuthStatus.error,
        errorMessage: 'Please enter your full name.',
      ));
      return false;
    }
    if (password.length < 6) {
      emit(state.copyWith(
        status: AdminAuthStatus.error,
        errorMessage: 'Password must be at least 6 characters.',
      ));
      return false;
    }
    final account = AdminAccount(
      name: name.trim(),
      email: cleanEmail,
      password: password,
    );
    _accounts[cleanEmail.toLowerCase()] = account;
    emit(AdminAuthState(
      status: AdminAuthStatus.success,
      session: AdminSession(name: account.name, email: account.email),
    ));
    return true;
  }

  void logout() {
    emit(const AdminAuthState(status: AdminAuthStatus.loggedOut));
  }

  void clearError() {
    emit(state.copyWith(
      status: AdminAuthStatus.initial,
      errorMessage: null,
    ));
  }
}
