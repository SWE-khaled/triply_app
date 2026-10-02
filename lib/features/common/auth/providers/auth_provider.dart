import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  User? _user;

  AuthProvider() {
    _authRepository.authStateChanges.listen((user) {
      _user = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      return true;
    } catch (e) {
      _setError(_authRepository.getErrorMessage(e));
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading();
    try {
      await _authRepository.signInWithEmail(email: email, password: password);
      return true;
    } catch (e) {
      _setError(_authRepository.getErrorMessage(e));
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading();
    try {
      await _authRepository.signInWithGoogle();
      return true;
    } catch (e) {
      _setError(_authRepository.getErrorMessage(e));
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading();
    try {
      await _authRepository.sendPasswordResetEmail(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_authRepository.getErrorMessage(e));
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<void> refreshUser() async {
    final current = FirebaseAuth.instance.currentUser;
    await current?.reload();
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }
}