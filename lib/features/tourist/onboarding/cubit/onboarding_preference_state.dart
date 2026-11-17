import 'package:flutter/foundation.dart';

/// Explicit states for persisting "tourist onboarding seen".
@immutable
sealed class OnboardingPreferenceState {
  const OnboardingPreferenceState();
}

final class OnboardingPreferenceInitial extends OnboardingPreferenceState {
  const OnboardingPreferenceInitial();
}

final class OnboardingPreferenceSaving extends OnboardingPreferenceState {
  const OnboardingPreferenceSaving();
}

final class OnboardingPreferenceSaved extends OnboardingPreferenceState {
  const OnboardingPreferenceSaved();
}

final class OnboardingPreferenceError extends OnboardingPreferenceState {
  const OnboardingPreferenceError({required this.message});

  final String message;
}
