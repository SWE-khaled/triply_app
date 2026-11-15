import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock/tourist/mock_places.dart';
import '../../../../core/utils/page_load_error.dart';
import '../model/place.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(const MapInitial()) {
    _loadFromFirestore();
  }

  /// The Firestore catalog once loaded; mock places are available only
  /// until the initial request completes.
  List<Place> _allPlaces = mockPlaces.map((e) => Place.fromJson(e)).toList();
  String _searchQuery = '';
  MapFilter _selectedFilter = MapFilter.all;
  Place? _selectedPlace;
  bool _isLoading = false;

  /// Camera focus in the view reads this.
  Place? get selectedPlace => _selectedPlace;
  String get searchQuery => _searchQuery;

  /// Manual re-entry after [MapErrorState].
  void retry() => _loadFromFirestore();

  Future<void> _loadFromFirestore() async {
    if (_isLoading || state is MapSuccessState) return;
    _isLoading = true;
    emit(const MapLoadingState());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('places')
          .get();
      final remote = snapshot.docs
          .map((doc) => Place.fromJson(doc.data()))
          .toList();
      if (isClosed) return;
      _allPlaces = remote;
      _emitFiltered();
    } catch (error) {
      if (isClosed) return;
      if (error is FirebaseException && error.code == 'permission-denied') {
        // The current Firestore rules do not grant tourists access to
        // `places`; keep the existing bundled map catalog usable in that
        // case. Network failures still surface the connection error below.
        _emitFiltered();
        return;
      }
      emit(MapErrorState(pageLoadErrorMessage(error)));
    } finally {
      _isLoading = false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _emitFiltered();
  }

  void submitSearch(String query) {
    _searchQuery = query;
    _emitFiltered();
  }

  void selectFilter(MapFilter filter) {
    _selectedFilter = filter;
    _emitFiltered();
  }

  void selectPlace(Place place) {
    _selectedPlace = place;
    _emitFiltered();
  }

  void clearSearch() {
    _searchQuery = '';
    _emitFiltered();
  }

  /// Recomputes the visible list from the plain fields and emits a fresh
  /// [MapSuccessState] (no copyWith — whole-state style).
  void _emitFiltered() {
    final q = _searchQuery.trim().toLowerCase();
    final visible = _allPlaces.where((p) {
      final matchesFilter = _selectedFilter.matches(p);
      final matchesQuery =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();

    if (visible.isEmpty) {
      _selectedPlace = null;
    } else if (_selectedPlace == null ||
        !visible.any((p) => p.id == _selectedPlace!.id)) {
      _selectedPlace = visible.first;
    }

    emit(
      MapSuccessState(
        searchQuery: _searchQuery,
        selectedFilter: _selectedFilter,
        visiblePlaces: visible,
        selectedPlace: _selectedPlace,
      ),
    );
  }
}
