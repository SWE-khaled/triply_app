import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock/tourist/mock_places.dart';
import '../model/place.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final List<Place> allPlaces;

  MapCubit()
      // Current: local mock. Future: Google Places API response -> Place.fromJson.
      : allPlaces =
            mockPlaces.map((e) => Place.fromJson(e)).toList(),
        super(const MapState(visiblePlaces: [])) {
    _applyFilters();
  }

  String get searchQuery => state.searchQuery;
  MapFilter get selectedFilter => state.selectedFilter;
  List<Place> get visiblePlaces => state.visiblePlaces;
  Place? get selectedPlace => state.selectedPlace;

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void submitSearch(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void selectFilter(MapFilter filter) {
    emit(state.copyWith(selectedFilter: filter));
    _applyFilters();
  }

  void selectPlace(Place place) {
    emit(state.copyWith(selectedPlace: place));
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: ''));
    _applyFilters();
  }

  void _applyFilters() {
    final q = state.searchQuery.trim().toLowerCase();
    final visible = allPlaces.where((p) {
      final matchesFilter = state.selectedFilter.matches(p);
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();

    Place? selected;
    if (visible.isEmpty) {
      selected = null;
    } else if (state.selectedPlace == null ||
        !visible.any((p) => p.id == state.selectedPlace!.id)) {
      selected = visible.first;
    } else {
      selected = state.selectedPlace;
    }
    emit(
      MapState(
        searchQuery: state.searchQuery,
        selectedFilter: state.selectedFilter,
        visiblePlaces: visible,
        selectedPlace: selected,
      ),
    );
  }
}
