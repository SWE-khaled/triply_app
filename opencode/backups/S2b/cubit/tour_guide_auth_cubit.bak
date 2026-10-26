import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/tour_guide_auth_service.dart';

part 'tour_guide_auth_state.dart';

/// The tour-guide session.
///
/// The guide's account and profile live in Firebase (Auth + the `users`
/// collection), so this cubit only decides what the UI shows: loading,
/// the role the account goes with, or the reason it failed.
class TourGuideAuthCubit extends Cubit<TourGuideAuthState> {
  final TourGuideAuthService _service;

  TourGuideAuthCubit({TourGuideAuthService? service})
    : _service = service ?? TourGuideAuthService(),
      super(const TourGuideAuthInitial());

  /// Whether a registration / login is running.
  bool get isLoading => state is TourGuideAuthLoading;

  /// The message of the last failure, or null.
  String? get errorMessage => switch (state) {
    TourGuideAuthError(:final error) => error,
    _ => null,
  };

  /// Creates the guide account. Returns false on failure.
  Future<bool> registerGuide({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String licenseNumber,
    List<String> languages = const [],
  }) async {
    emit(const TourGuideAuthLoading());
    try {
      await _service.registerGuide(
        name: name,
        email: email,
        password: password,
        phone: phone,
        licenseNumber: licenseNumber,
        languages: languages,
      );
      emit(const TourGuideAuthSuccess(role: 'guide'));
      return true;
    } catch (e) {
      emit(TourGuideAuthError(error: _service.getErrorMessage(e)));
      return false;
    }
  }

  /// Signs in and returns the role (`'guide'` or `'tourist'`), or null on
  /// failure. The role decides where the user goes next.
  Future<String?> signInGuide({
    required String email,
    required String password,
  }) async {
    emit(const TourGuideAuthLoading());
    try {
      final result = await _service.signInGuide(
        email: email,
        password: password,
      );
      emit(TourGuideAuthSuccess(role: result.role));
      return result.role;
    } catch (e) {
      emit(TourGuideAuthError(error: _service.getErrorMessage(e)));
      return null;
    }
  }

  /// Signs out. The verification and profile documents in Firestore are
  /// permanent and survive the relogin.
  Future<void> signOut() async {
    await _service.signOut();
    emit(const TourGuideAuthInitial());
  }

  /// Drops the last error message.
  void clearError() => emit(const TourGuideAuthInitial());
}
