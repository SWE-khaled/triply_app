import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock/tourist/mock_places.dart';
import '../model/place.dart';
import 'map_state.dart';

/// Place catalog: Firestore `places` collection (66 docs, publicly
/// readable) with the local mock as fallback so the map never goes
/// blank offline / on rules errors.
class MapCubit extends Cubit<MapState> {
  /// Replaced by the Firestore copy once loaded; mock until then.
  List<Place> allPlaces;
  bool _firestoreLoaded = false;

  MapCubit()
    // Source shape unchanged: snake_case docs -> Place.fromJson
    // (Firestore docs were uploaded from the same mock source).
    : allPlaces = mockPlaces.map((e) => Place.fromJson(e)).toList(),
      super(const MapState(visiblePlaces: [])) {
    // Instant first paint from the mock, then the Firestore swap
    // re-emits and BlocBuilder rebuilds with the remote catalog.
    _applyFilters();
    loadFromFirestore();
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

  /// One-time eager load. Best effort only: any failure keeps the mock
  /// catalog silently (the UI stays functional offline).
  Future<void> loadFromFirestore() async {
    if (_firestoreLoaded) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('places')
          .get();
      final remote = snapshot.docs
          .map((doc) => Place.fromJson(doc.data()))
          .toList();
      if (remote.isEmpty) return; // keep the mock fallback
      allPlaces = remote;
      _firestoreLoaded = true;
      _applyFilters();
    } catch (_) {
      // Offline / permission-denied / unexpected doc — keep the mock.
    }
  }

  void _applyFilters() {
    final q = state.searchQuery.trim().toLowerCase();
    final visible = allPlaces.where((p) {
      final matchesFilter = state.selectedFilter.matches(p);
      final matchesQuery =
          q.isEmpty ||
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
