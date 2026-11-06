import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/profile_self_heal_service.dart';
import '../../../tourist/checkout/paymob_settings.dart';
import '../data/auth_repository.dart';
import '../model/auth_role.dart';

part 'auth_state.dart';

/// The one session cubit for both apps.
///
/// The tourist and guide auth flows are the same; only the [AuthRole]
/// differs. The signed-in user comes from Firebase Auth: the cubit listens
/// to [AuthRepository.authStateChanges] and publishes it as [AuthSuccess]
/// or [AuthUnauthenticated]. Every action that talks to Firebase moves
/// through [AuthLoading] first, and a failure becomes [AuthError].
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ProfileSelfHealService _profileHeal;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit({
    AuthRepository? authRepository,
    ProfileSelfHealService? profileHeal,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _profileHeal = profileHeal ?? ProfileSelfHealService(),
       super(const AuthInitial()) {
    _authSubscription = _authRepository.authStateChanges.listen(
      _onAuthState,
      onError: (Object error) => emit(AuthError(error: error.toString())),
    );
  }

  void _onAuthState(User? user) {
    // An action (sign in / sign up / Google / reset) owns the state while
    // it runs: it publishes the final state itself when it is done. This
    // keeps the button loading until the whole flow (including the role
    // check) has finished, instead of stopping early.
    if (state is AuthLoading) return;

    if (user == null) {
      // A failed action may sign the account out on purpose (role
      // mismatch). The stream event can arrive after AuthError is
      // published — keep the message instead of clearing it.
      if (state is AuthError) return;
      emit(const AuthUnauthenticated());
      _profileHeal.resetSession();
      return;
    }

    // Keep the role confirmed by the last action for the same account;
    // a restored session has no confirmed role yet.
    final previousRole = switch (state) {
      AuthSuccess(:final role) => role,
      _ => null,
    };
    emit(AuthSuccess(user: user, role: previousRole));
    _profileHeal.healAfterSignIn();
  }

  /// Publishes the state that matches the current Firebase user.
  void _emitCurrentUser(AuthRole role) {
    final current = _authRepository.currentUser;
    if (current == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    emit(AuthSuccess(user: current, role: role));
    _profileHeal.healAfterSignIn();
  }

  /// The signed-in user, or null when signed out.
  User? get user => switch (state) {
    AuthSuccess(:final user) => user,
    _ => null,
  };

  /// The role confirmed by the last successful action, or null.
  AuthRole? get role => switch (state) {
    AuthSuccess(:final role) => role,
    _ => null,
  };

  /// Whether a sign-in / sign-up is running.
  bool get isLoading => state is AuthLoading;

  /// The message of the last failure, or null.
  String? get errorMessage => switch (state) {
    AuthError(:final error) => error,
    _ => null,
  };

  /// Creates the account and signs in. Returns false on failure.
  Future<bool> signUp({
    required AuthRole role,
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? licenseNumber,
    List<String> languages = const [],
  }) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signUpWithEmail(
        role: role,
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        licenseNumber: licenseNumber,
        languages: languages,
      );
      if (role == AuthRole.tourist) {
        _shareBillingData(name: fullName, email: email, phone: phone);
      }
      _emitCurrentUser(role);
      return true;
    } catch (e) {
      emit(AuthError(error: _authRepository.getErrorMessage(e)));
      return false;
    }
  }

  /// Signs in with email + password. Returns false on failure.
  ///
  /// [role] is the app the view belongs to: the repository rejects an
  /// account of the other role and signs it out.
  Future<bool> signIn({
    required String email,
    required String password,
    required AuthRole role,
  }) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithEmail(
        email: email,
        password: password,
        role: role,
      );
      final user = _authRepository.currentUser;
      if (role == AuthRole.tourist) {
        _shareBillingData(name: user?.displayName, email: email);
        // The phone only feeds the payment form: load it in the background.
        unawaited(
          _authRepository
              .getUserPhone(user?.uid ?? '')
              .then(
                (phone) => _shareBillingData(
                  name: user?.displayName,
                  email: email,
                  phone: phone,
                ),
              ),
        );
      }
      _emitCurrentUser(role);
      return true;
    } catch (e) {
      emit(AuthError(error: _authRepository.getErrorMessage(e)));
      return false;
    }
  }

  /// Hands the tourist's details to the payment, so the billing data of
  /// the Paymob form carries them instead of "NA".
  void _shareBillingData({String? name, String? email, String? phone}) {
    PaymobSettings.initialize(name: name, email: email, phone: phone);
  }

  /// Signs in with Google. Returns false on failure.
  Future<bool> signInWithGoogle({required AuthRole role}) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithGoogle(role: role);
      _emitCurrentUser(role);
      return true;
    } catch (e) {
      emit(AuthError(error: _authRepository.getErrorMessage(e)));
      return false;
    }
  }

  /// Sends the reset link. Returns false on failure.
  Future<bool> sendPasswordResetEmail(String email) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email);
      // The reset does not touch the session: restore what it was.
      final current = _authRepository.currentUser;
      emit(
        current == null
            ? const AuthUnauthenticated()
            : AuthSuccess(user: current, role: role),
      );
      return true;
    } catch (e) {
      emit(AuthError(error: _authRepository.getErrorMessage(e)));
      return false;
    }
  }

  /// Signs out. The stream publishes [AuthUnauthenticated]; this also
  /// publishes it directly so a logout is never left looking signed in.
  Future<void> signOut() async {
    await _authRepository.signOut();
    _profileHeal.resetSession();
    if (isClosed) return;
    emit(const AuthUnauthenticated());
  }

  /// Re-reads the Firebase user, so a new display name or photo shows up.
  Future<void> refreshUser() async {
    final current = _authRepository.currentUser;
    await current?.reload();
    final refreshed = _authRepository.currentUser;
    if (refreshed == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    final confirmedRole = switch (state) {
      AuthSuccess(:final role) => role,
      _ => null,
    };
    emit(AuthSuccess(user: refreshed, role: confirmedRole));
  }

  /// Drops the last error message.
  void clearError() {
    if (state is! AuthError) return;
    final current = _authRepository.currentUser;
    emit(
      current == null
          ? const AuthUnauthenticated()
          : AuthSuccess(user: current),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
