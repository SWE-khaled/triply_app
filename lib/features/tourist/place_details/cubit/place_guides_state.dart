import 'package:flutter/foundation.dart';

import '../model/guide.dart';

/// Explicit states for the approved guides of one place.
@immutable
sealed class PlaceGuidesState {
  const PlaceGuidesState();
}

final class PlaceGuidesInitial extends PlaceGuidesState {
  const PlaceGuidesInitial();
}

final class PlaceGuidesLoading extends PlaceGuidesState {
  const PlaceGuidesLoading();
}

final class PlaceGuidesSuccess extends PlaceGuidesState {
  const PlaceGuidesSuccess({required this.guides});

  final List<Guide> guides;
}

final class PlaceGuidesError extends PlaceGuidesState {
  const PlaceGuidesError({required this.error});

  final String error;
}
