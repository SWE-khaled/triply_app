import 'package:flutter/foundation.dart';

@immutable
sealed class GuidePhoneState {
  const GuidePhoneState();
}

final class GuidePhoneInitial extends GuidePhoneState {
  const GuidePhoneInitial();
}

final class GuidePhoneLoading extends GuidePhoneState {
  const GuidePhoneLoading();
}

final class GuidePhoneSuccess extends GuidePhoneState {
  final String? phone;

  const GuidePhoneSuccess({required this.phone});
}

final class GuidePhoneError extends GuidePhoneState {
  final String message;

  const GuidePhoneError({required this.message});
}
