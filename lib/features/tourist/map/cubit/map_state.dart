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

class MapState {
  final String searchQuery;
  final MapFilter selectedFilter;
  final List<Place> visiblePlaces;
  final Place? selectedPlace;

  const MapState({
    this.searchQuery = '',
    this.selectedFilter = MapFilter.all,
    required this.visiblePlaces,
    this.selectedPlace,
  });

  MapState copyWith({
    String? searchQuery,
    MapFilter? selectedFilter,
    List<Place>? visiblePlaces,
    Place? selectedPlace,
  }) {
    return MapState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      visiblePlaces: visiblePlaces ?? this.visiblePlaces,
      selectedPlace: selectedPlace ?? this.selectedPlace,
    );
  }
}
