import 'package:flutter/foundation.dart';

import '../../map/model/place.dart';

/// Explicit states for the place document itself.
@immutable
sealed class PlaceInfoState {
  const PlaceInfoState();
}

final class PlaceInfoInitial extends PlaceInfoState {
  const PlaceInfoInitial();
}

final class PlaceInfoLoading extends PlaceInfoState {
  const PlaceInfoLoading();
}

final class PlaceInfoSuccess extends PlaceInfoState {
  const PlaceInfoSuccess({required this.place});

  final Place place;
}

final class PlaceInfoError extends PlaceInfoState {
  const PlaceInfoError({required this.error});

  final String error;
}
