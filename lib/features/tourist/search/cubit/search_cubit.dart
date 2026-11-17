import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_places.dart';
import '../../map/model/place.dart';
import '../model/search_filter.dart';
import '../../../../core/data/mock/tourist/mock_search.dart';
import 'search_state.dart';

/// Searches the existing Map places list (single source of truth).
/// Popular searches / destinations reference Map places by id.
class SearchCubit extends Cubit<SearchState> {
  final List<Place> allPlaces = mockPlaces.map(Place.fromJson).toList();

  SearchCubit()
    : _recentSearches = List.of(mockRecentSearches),
      super(SearchState(recentSearches: List.of(mockRecentSearches)));

  static const _popularSearchIds = [
    'giza_pyramids',
    'luxor_temple',
    'khan_el_khalili',
    'karnak_temple',
    'abu_simbel',
    'citadel_saladin',
  ];

  static const _popularDestinationIds = [
    'giza_pyramids',
    'khan_el_khalili',
    'luxor_temple',
    'abu_simbel',
  ];

  /// Authoritative fields for the local search session.
  String _query = '';
  SearchFilter _activeFilter = SearchFilter.all;
  List<String> _recentSearches;
  bool _submitted = false;

  String get query => _query;
  SearchFilter get activeFilter => _activeFilter;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  bool get submitted => _submitted;

  Place _byId(String id) =>
      allPlaces.firstWhere((p) => p.id == id, orElse: () => allPlaces.first);

  List<Place> get popularSearches => [
    for (final id in _popularSearchIds) _byId(id),
  ];

  List<Place> get popularDestinations => [
    for (final id in _popularDestinationIds) _byId(id),
  ];

  List<Place> get results {
    if (!_submitted || _query.trim().isEmpty) return [];
    final q = _query.trim().toLowerCase();
    return allPlaces
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.city.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q),
        )
        .toList();
  }

  bool get showEmptyState =>
      _submitted && _query.trim().isNotEmpty && results.isEmpty;
  bool get showDefaultContent => !_submitted || _query.trim().isEmpty;

  void setQuery(String value) {
    _query = value;
    _submitted = value.trim().isNotEmpty;
    _emitState();
  }

  void clearQuery() {
    _query = '';
    _submitted = false;
    _emitState();
  }

  void submit(String value) {
    final v = value.trim();
    if (v.isNotEmpty && !_recentSearches.contains(v)) {
      _recentSearches = [v, ..._recentSearches];
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    }
    _query = value;
    _submitted = true;
    _emitState();
  }

  void setFilter(SearchFilter filter) {
    _activeFilter = filter;
    _emitState();
  }

  void removeRecent(String value) {
    _recentSearches =
        _recentSearches.where((r) => r != value).toList(growable: false);
    _emitState();
  }

  void clearRecents() {
    _recentSearches = const [];
    _emitState();
  }

  /// Emits a fresh snapshot from the authoritative fields only.
  void _emitState() {
    emit(
      SearchState(
        query: _query,
        activeFilter: _activeFilter,
        recentSearches: List.of(_recentSearches),
        submitted: _submitted,
      ),
    );
  }
}
