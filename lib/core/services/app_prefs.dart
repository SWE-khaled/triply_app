import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small persistent memory for the launch / onboarding flow.
///
/// * [lastRole] is written only after a successful sign-in or sign-up, so
///   it means "the last account that really signed in on this device".
///   While it is null the device never completed a login, which is how the
///   startup screen tells a brand-new visitor from a returning one.
/// * The onboarding flags are per role: the tourist slides and the guide
///   slides each appear once.
///
/// Local storage must never block the app. If the platform plugin is
/// missing (or the store is locked), every read falls back to its default
/// and every write is dropped — Firebase Auth still restores the session.
class AppPrefs {
  AppPrefs._();

  static final AppPrefs instance = AppPrefs._();

  static const String _touristOnboardingKey = 'onboarding_seen_tourist';
  static const String _guideOnboardingKey = 'onboarding_seen_guide';
  static const String _lastRoleKey = 'last_role';
  static const String _guideVerifiedKey = 'guide_verified';

  SharedPreferences? _cached;
  bool _unavailableLogged = false;

  Future<SharedPreferences?> get _prefs async {
    if (_cached != null) return _cached;
    try {
      return _cached = await SharedPreferences.getInstance();
    } catch (error) {
      if (!_unavailableLogged) {
        _unavailableLogged = true;
        debugPrint('AppPrefs: local storage unavailable — $error');
      }
      return null;
    }
  }

  /// The last role that signed in successfully, or null when this device
  /// never signed in.
  Future<String?> lastRole() async {
    final prefs = await _prefs;
    try {
      return prefs?.getString(_lastRoleKey);
    } catch (error) {
      debugPrint('AppPrefs.lastRole failed — $error');
      return null;
    }
  }

  Future<void> setLastRole(String role) async {
    final prefs = await _prefs;
    try {
      await prefs?.setString(_lastRoleKey, role);
    } catch (error) {
      debugPrint('AppPrefs.setLastRole failed — $error');
    }
  }

  /// Whether the slides of [role] (`tourist` / `guide`) were already shown.
  Future<bool> hasSeenOnboarding(String role) async {
    final prefs = await _prefs;
    try {
      return prefs?.getBool(_onboardingKey(role)) ?? false;
    } catch (error) {
      debugPrint('AppPrefs.hasSeenOnboarding failed — $error');
      return false;
    }
  }

  Future<void> markOnboardingSeen(String role) async {
    final prefs = await _prefs;
    try {
      await prefs?.setBool(_onboardingKey(role), true);
    } catch (error) {
      debugPrint('AppPrefs.markOnboardingSeen failed — $error');
    }
  }

  /// Last known verification result of the signed-in guide. Used only when
  /// Firestore cannot be reached at startup, so an approved guide is not
  /// sent back to the verification screen while offline.
  Future<bool> guideVerifiedCache() async {
    final prefs = await _prefs;
    try {
      return prefs?.getBool(_guideVerifiedKey) ?? false;
    } catch (error) {
      debugPrint('AppPrefs.guideVerifiedCache failed — $error');
      return false;
    }
  }

  Future<void> setGuideVerified(bool value) async {
    final prefs = await _prefs;
    try {
      await prefs?.setBool(_guideVerifiedKey, value);
    } catch (error) {
      debugPrint('AppPrefs.setGuideVerified failed — $error');
    }
  }

  String _onboardingKey(String role) =>
      role == 'guide' ? _guideOnboardingKey : _touristOnboardingKey;
}
