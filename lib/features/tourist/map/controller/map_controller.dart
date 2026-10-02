import '../../../../core/data/mock/tourist/mock_places.dart';
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

class MapController {
  String searchQuery = '';
  MapFilter selectedFilter = MapFilter.all;

  late final List<Place> allPlaces;
  List<Place> visiblePlaces = [];
  Place? selectedPlace;

  MapController() {
    // Current: local mock. Future: Google Places API response -> Place.fromJson.
    allPlaces = mockPlaces.map((e) => Place.fromJson(e)).toList();
    _applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void submitSearch(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void selectFilter(MapFilter filter) {
    selectedFilter = filter;
    _applyFilters();
  }

  void selectPlace(Place place) {
    selectedPlace = place;
  }

  void clearSearch() {
    searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    final q = searchQuery.trim().toLowerCase();
    visiblePlaces = allPlaces.where((p) {
      final matchesFilter = selectedFilter.matches(p);
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();

    if (visiblePlaces.isEmpty) {
      selectedPlace = null;
    } else if (selectedPlace == null ||
        !visiblePlaces.any((p) => p.id == selectedPlace!.id)) {
      selectedPlace = visiblePlaces.first;
    }
  }
}
