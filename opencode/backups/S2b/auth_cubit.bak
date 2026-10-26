import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import '../../../tourist/checkout/paymob_settings.dart';

part 'auth_state.dart';

/// The tourist session.
///
/// The signed-in user comes from Firebase Auth: the cubit listens to
/// [AuthRepository.authStateChanges] and publishes it as [AuthSuccess] or
/// [AuthUnauthenticated]. Every action that talks to Firebase moves
/// through [AuthLoading] first, and a failure becomes [AuthError].
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(const AuthInitial()) {
    _authSubscription = _authRepository.authStateChanges.listen(
      _onAuthState,
      onError: (Object error) => emit(AuthError(error: error.toString())),
    );
  }

  void _onAuthState(User? user) {
    emit(user == null ? const AuthUnauthenticated() : AuthSuccess(user: user));
  }

  /// The signed-in user, or null when signed out.
  User? get user => switch (state) {
    AuthSuccess(:final user) => user,
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
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      _shareBillingData(name: fullName, email: email, phone: phone);
      return true;
    } catch (e) {
      emit(AuthError(error: _authRepository.getErrorMessage(e)));
      return false;
    }
  }

  /// Signs in with email + password. Returns false on failure.
  Future<bool> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithEmail(email: email, password: password);
      final user = _authRepository.currentUser;
      _shareBillingData(
        name: user?.displayName,
        email: email,
        phone: await _authRepository.getUserPhone(user?.uid ?? ''),
      );
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
  Future<bool> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
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
      emit(const AuthUnauthenticated());
      return true;
    } catch (e) {
      emit(AuthError(error: _authRepository.getErrorMessage(e)));
      return false;
    }
  }

  /// Signs out. The stream publishes [AuthUnauthenticated].
  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  /// Re-reads the Firebase user, so a new display name or photo shows up.
  Future<void> refreshUser() async {
    final current = FirebaseAuth.instance.currentUser;
    await current?.reload();
    final refreshed = FirebaseAuth.instance.currentUser;
    if (refreshed == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    emit(AuthSuccess(user: refreshed));
  }

  /// Drops the last error message.
  void clearError() {
    if (state is! AuthError) return;
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
