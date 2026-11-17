import 'package:flutter/foundation.dart';

import '../model/guide.dart';

@immutable
sealed class HomeGuidesState {
  const HomeGuidesState();
}

final class HomeGuidesInitial extends HomeGuidesState {
  const HomeGuidesInitial();
}

final class HomeGuidesLoading extends HomeGuidesState {
  const HomeGuidesLoading();
}

final class HomeGuidesSuccess extends HomeGuidesState {
  final List<Guide> guides;

  const HomeGuidesSuccess({required this.guides});
}

final class HomeGuidesError extends HomeGuidesState {
  final String message;

  const HomeGuidesError({required this.message});
}
