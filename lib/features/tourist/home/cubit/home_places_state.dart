import 'package:flutter/foundation.dart';

import '../model/place.dart';

@immutable
sealed class HomePlacesState {
  const HomePlacesState();
}

final class HomePlacesInitial extends HomePlacesState {
  const HomePlacesInitial();
}

final class HomePlacesLoading extends HomePlacesState {
  const HomePlacesLoading();
}

final class HomePlacesSuccess extends HomePlacesState {
  final List<Place> places;

  const HomePlacesSuccess({required this.places});
}

final class HomePlacesError extends HomePlacesState {
  final String message;

  const HomePlacesError({required this.message});
}
