import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/admin_access_service.dart';
import '../model/admin_session.dart';
import 'admin_auth_state.dart';

/// Admin authentication against Firebase + server-backed authorization.
///
/// Login signs in with Firebase Auth and then verifies admin privileges
/// through [AdminAccessService] (`admins/{uid}` doc OR `admin:true` claim,
/// both enforced again by rules/Functions on every operation). A signed-in
/// non-admin is signed straight back out — UI hiding is never the gate.
/// First admin bootstrap stays a console procedure
/// (`docs/ADMIN_PROVISIONING.md`); there are no default credentials and
/// nothing here grants privileges client-side.
class AdminAuthCubit extends Cubit<AdminAuthState> {
  final FirebaseAuth _auth;
  final AdminAccessService _access;

  AdminAuthCubit({FirebaseAuth? auth, AdminAccessService? access})
    : _auth = auth ?? FirebaseAuth.instance,
      _access = access ?? AdminAccessService(),
      super(const AdminAuthState()) {
    _restoreSession();
  }

  /// Restores an existing session (used when entering the dashboard
  /// with an already-authenticated admin).
  AdminAuthCubit.authenticated(AdminSession session)
    : _auth = FirebaseAuth.instance,
      _access = AdminAccessService(),
      super(AdminAuthState(status: AdminAuthStatus.success, session: session));

  static const String accessDeniedMessage =
      'You are not allowed to access the Admin Dashboard.';

  /// Silent restore: a persisted Firebase session that is still authorized
  /// becomes an admin session without another login. Anything else stays
  /// logged out (never a misleading session).
  Future<void> _restoreSession() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      if (await _access.isAuthorized(user.uid)) {
        if (isClosed) return;
        emit(
          AdminAuthState(
            status: AdminAuthStatus.success,
            session: AdminSession(
              name: _displayNameFor(user.displayName ?? '', user.email ?? ''),
              email: user.email ?? '',
            ),
          ),
        );
      }
    } catch (_) {}
  }

  static String _displayNameFor(String name, String email) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) return trimmed;
    final local = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (local.isEmpty) return 'Admin';
    return local[0].toUpperCase() + local.substring(1);
  }

  static String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No admin account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Sign-in failed. Please try again.';
    }
  }

  static String _functionsErrorMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Only a signed-in admin can create admin accounts.';
      case 'invalid-argument':
        return e.message ?? 'Invalid admin request.';
      case 'not-found':
        return e.message ?? 'No user found with that email.';
      case 'unauthenticated':
        return 'Please sign in as an admin first.';
      default:
        return e.message ?? 'Could not create the admin account.';
    }
  }

  Future<bool> login({required String email, required String password}) async {
    emit(state.copyWith(status: AdminAuthStatus.loading));
    final cleanEmail = email.trim();
    if (password.length < 6) {
      emit(
        state.copyWith(
          status: AdminAuthStatus.error,
          errorMessage: 'Password must be at least 6 characters.',
        ),
      );
      return false;
    }
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final user = credential.user;
      final uid = user?.uid ?? '';
      if (uid.isEmpty || !await _access.isAuthorized(uid)) {
        try {
          await _auth.signOut();
        } catch (_) {}
        emit(
          state.copyWith(
            status: AdminAuthStatus.error,
            errorMessage: accessDeniedMessage,
          ),
        );
        return false;
      }
      emit(
        AdminAuthState(
          status: AdminAuthStatus.success,
          session: AdminSession(
            name: _displayNameFor(
              user?.displayName ?? '',
              user?.email ?? cleanEmail,
            ),
            email: user?.email ?? cleanEmail,
          ),
        ),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AdminAuthStatus.error,
          errorMessage: _authErrorMessage(e),
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: AdminAuthStatus.error,
          errorMessage: 'Sign-in failed. Please try again.',
        ),
      );
      return false;
    }
  }

  /// Provisions a NEW admin through the `provisionAdmin` callable, then
  /// signs in as that account so the session is real (never a local-only
  /// success). Requires the CALLER to already be an admin — otherwise the
  /// server denies with permission-denied (first admin comes from the
  /// console procedure, never from here).
  Future<bool> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AdminAuthStatus.loading));
    final cleanEmail = email.trim();
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      emit(
        state.copyWith(
          status: AdminAuthStatus.error,
          errorMessage: 'Please enter your full name.',
        ),
      );
      return false;
    }
    if (password.length < 6) {
      emit(
        state.copyWith(
          status: AdminAuthStatus.error,
          errorMessage: 'Password must be at least 6 characters.',
        ),
      );
      return false;
    }
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'provisionAdmin',
      );
      await callable.call({'email': cleanEmail});
      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final user = credential.user;
      if (user != null && cleanName.isNotEmpty) {
        try {
          await user.updateDisplayName(cleanName);
        } catch (_) {}
      }
      final uid = user?.uid ?? '';
      if (uid.isEmpty || !await _access.isAuthorized(uid)) {
        try {
          await _auth.signOut();
        } catch (_) {}
        emit(
          state.copyWith(
            status: AdminAuthStatus.error,
            errorMessage: accessDeniedMessage,
          ),
        );
        return false;
      }
      emit(
        AdminAuthState(
          status: AdminAuthStatus.success,
          session: AdminSession(
            name: _displayNameFor(
              user?.displayName ?? cleanName,
              user?.email ?? cleanEmail,
            ),
            email: user?.email ?? cleanEmail,
          ),
        ),
      );
      return true;
    } on FirebaseFunctionsException catch (e) {
      emit(
        state.copyWith(
          status: AdminAuthStatus.error,
          errorMessage: _functionsErrorMessage(e),
        ),
      );
      return false;
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AdminAuthStatus.error,
          errorMessage: _authErrorMessage(e),
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: AdminAuthStatus.error,
          errorMessage: 'Could not create the admin account.',
        ),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    emit(const AdminAuthState(status: AdminAuthStatus.loggedOut));
  }

  void clearError() {
    emit(state.copyWith(status: AdminAuthStatus.initial, errorMessage: null));
  }
}
