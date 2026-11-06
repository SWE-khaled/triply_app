import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/app_prefs.dart';
import '../../../core/services/session_role_service.dart';
import 'startup_state.dart';

/// Decides where the app opens after the splash animation.
///
/// * A restored Firebase session wins: the role on `users/{uid}` chooses
///   the home screen (guide approval is checked too).
/// * Without a session, the last successfully signed-in role opens its
///   login screen.
/// * With no remembered role the device never finished a login, so the
///   role selection is shown and the onboarding can run once per role.
class StartupCubit extends Cubit<StartupState> {
  StartupCubit({AppPrefs? prefs, SessionRoleService? service})
    : _prefs = prefs ?? AppPrefs.instance,
      _service = service ?? SessionRoleService(),
      super(const StartupLoading());

  final AppPrefs _prefs;
  final SessionRoleService _service;

  Future<void> resolve() async {
    emit(const StartupLoading());
    try {
      final user = await _service.waitForAuth();
      final lastRole = await _prefs.lastRole();

      if (user == null) {
        emit(StartupReady(destination: _signedOutDestination(lastRole)));
        return;
      }

      // A Firestore outage must not sign the user out: fall back to the
      // role remembered from the last successful login.
      final role = await _service.roleOf(user.uid) ?? lastRole ?? 'tourist';
      await _prefs.setLastRole(role);

      switch (role) {
        case 'admin':
          emit(
            StartupReady(
              destination: StartupDestination.adminDashboard,
              adminName: user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!.trim()
                  : (user.email?.split('@').first ?? 'Admin'),
              adminEmail: user.email ?? '',
            ),
          );
        case 'guide':
          final approved = await _service.checkGuideApproved(user.uid);
          if (approved != null) {
            await _prefs.setGuideVerified(approved);
          }
          final verified = approved ?? await _prefs.guideVerifiedCache();
          emit(
            StartupReady(
              destination: verified
                  ? StartupDestination.guideHome
                  : StartupDestination.guideVerification,
            ),
          );
        default:
          emit(const StartupReady(destination: StartupDestination.touristHome));
      }
    } catch (error) {
      // Keep the raw error in the console; the gate shows it on screen.
      debugPrint('StartupCubit.resolve failed — $error');
      emit(StartupError(error.toString()));
    }
  }

  StartupDestination _signedOutDestination(String? lastRole) {
    return switch (lastRole) {
      'tourist' => StartupDestination.touristLogin,
      'guide' => StartupDestination.guideLogin,
      'admin' => StartupDestination.adminLogin,
      _ => StartupDestination.roleSelection,
    };
  }
}
