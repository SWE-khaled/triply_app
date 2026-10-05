import 'package:flutter/foundation.dart';
import '../data/tour_guide_auth_service.dart';

enum TourGuideAuthStatus { initial, loading, success, error }

class TourGuideAuthProvider extends ChangeNotifier {
  final TourGuideAuthService _service = TourGuideAuthService();

  TourGuideAuthStatus _status = TourGuideAuthStatus.initial;
  String? _errorMessage;

  TourGuideAuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TourGuideAuthStatus.loading;

  // ──────────────── Registration ────────────────

  /// Returns `true` on success. On failure sets errorMessage and returns false.
  Future<bool> registerGuide({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String licenseNumber,
    List<String> languages = const [],
  }) async {
    _setLoading();
    try {
      await _service.registerGuide(
        name: name,
        email: email,
        password: password,
        phone: phone,
        licenseNumber: licenseNumber,
        languages: languages,
      );
      _status = TourGuideAuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_service.getErrorMessage(e));
      return false;
    }
  }

  // ──────────────── Login ────────────────

  /// Returns the role string (`'guide'` or `'tourist'`) on success, or null on failure.
  Future<String?> signInGuide({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final result = await _service.signInGuide(
        email: email,
        password: password,
      );
      _status = TourGuideAuthStatus.success;
      notifyListeners();
      return result.role;
    } catch (e) {
      _setError(_service.getErrorMessage(e));
      return null;
    }
  }

  // ──────────────── Helpers ────────────────

  void clearError() {
    _errorMessage = null;
    _status = TourGuideAuthStatus.initial;
    notifyListeners();
  }

  void _setLoading() {
    _status = TourGuideAuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = TourGuideAuthStatus.error;
    notifyListeners();
  }
}
