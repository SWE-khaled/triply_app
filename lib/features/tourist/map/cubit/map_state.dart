import 'package:flutter/foundation.dart';

import '../model/place.dart';

enum MapFilter { all, activities, historical, nature, food }

extension MapFilterLabel on MapFilter {
  String get label {
    switch (this) {
      case MapFilter.all:
        return 'All';
      case MapFilter.activities:
        return 'Activities';
      case MapFilter.historical:
        return 'Historical';
      case MapFilter.nature:
        return 'Nature';
      case MapFilter.food:
        return 'Food';
    }
  }

  bool matches(Place place) {
    if (this == MapFilter.all) return true;
    return place.category.toLowerCase() == label.toLowerCase();
  }
}

/// Sealed state hierarchy for the map (cubit style: whole states are
/// emitted, no copyWith).
@immutable
sealed class MapState {
  const MapState();
}

/// Momentary state before the first load.
final class MapInitial extends MapState {
  const MapInitial();
}

/// Emitted while the catalogs (Firestore / fallback) are being fetched.
final class MapLoadingState extends MapState {
  const MapLoadingState();
}

/// Catalog failed completely (no remote and no local fallback available).
final class MapErrorState extends MapState {
  final String message;

  const MapErrorState([this.message = 'Could not load places.']);
}

/// Catalog ready. Carries everything the screen renders; the cubit
/// rebuilds it fresh on every search / filter / selection change.
final class MapSuccessState extends MapState {
  final String searchQuery;
  final MapFilter selectedFilter;
  final List<Place> visiblePlaces;
  final Place? selectedPlace;

  const MapSuccessState({
    this.searchQuery = '',
    this.selectedFilter = MapFilter.all,
    required this.visiblePlaces,
    this.selectedPlace,
  });
}
