import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock/tourist/mock_places.dart';
import '../model/place.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(const MapInitial()) {
    _loadFromFirestore();
  }

  /// Firestore copy once loaded; the const mock stays as the base and
  /// the offline fallback.
  List<Place> _allPlaces = mockPlaces.map((e) => Place.fromJson(e)).toList();
  String _searchQuery = '';
  MapFilter _selectedFilter = MapFilter.all;
  Place? _selectedPlace;

  /// Camera focus in the view reads this.
  Place? get selectedPlace => _selectedPlace;

  /// Manual re-entry after [MapErrorState].
  void retry() => _loadFromFirestore();

  Future<void> _loadFromFirestore() async {
    emit(const MapLoadingState());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('places')
          .get();
      final remote = snapshot.docs
          .map((doc) => Place.fromJson(doc.data()))
          .toList();
      if (isClosed) return;
      // A fresh/empty Firestore project keeps the local mock as base.
      if (remote.isNotEmpty) _allPlaces = remote;
      _emitFiltered();
    } catch (e) {
      debugPrint('MapCubit: Firestore load failed → mock fallback: $e');
      if (isClosed) return;
      // Offline / rules error: the const mock rescues the map, so the
      // error state is reserved for "nothing to show at all" — that one
      // offers [retry] from the view.
      if (_allPlaces.isEmpty) {
        emit(
          const MapErrorState(
            'Could not load places. Check your connection and try again.',
          ),
        );
      } else {
        _emitFiltered();
      }
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
