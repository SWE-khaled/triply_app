import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/services/app_prefs.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import 'onboarding_preference_state.dart';

/// Owns the one local-storage write that ends tourist onboarding. The slides,
/// page controller and navigation remain in the View.
class OnboardingPreferenceCubit extends Cubit<OnboardingPreferenceState>
    with SafeEmitMixin<OnboardingPreferenceState> {
  OnboardingPreferenceCubit({AppPrefs? prefs})
    : _prefs = prefs ?? AppPrefs.instance,
      super(const OnboardingPreferenceInitial());

  final AppPrefs _prefs;

  Future<void> complete() async {
    safeEmit(const OnboardingPreferenceSaving());
    try {
      await _prefs.markOnboardingSeen('tourist');
      safeEmit(const OnboardingPreferenceSaved());
    } catch (error) {
      safeEmit(OnboardingPreferenceError(message: '$error'));
    }
  }
}
