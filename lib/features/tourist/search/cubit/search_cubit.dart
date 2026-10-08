import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_places.dart';
import '../../map/model/place.dart';
import '../model/search_filter.dart';
import '../../../../core/data/mock/tourist/mock_search.dart';
import 'search_state.dart';

/// Searches the existing Map places list (single source of truth).
/// Popular searches / destinations reference Map places by id.
class SearchCubit extends Cubit<SearchState> {
  final List<Place> allPlaces =
      mockPlaces.map(Place.fromJson).toList();

  SearchCubit()
      : super(SearchState(recentSearches: List.of(mockRecentSearches)));

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

  String get query => state.query;
  SearchFilter get activeFilter => state.activeFilter;
  List<String> get recentSearches => state.recentSearches;
  bool get submitted => state.submitted;

  Place _byId(String id) => allPlaces.firstWhere(
        (p) => p.id == id,
        orElse: () => allPlaces.first,
      );

  List<Place> get popularSearches =>
      [for (final id in _popularSearchIds) _byId(id)];

  List<Place> get popularDestinations =>
      [for (final id in _popularDestinationIds) _byId(id)];

  List<Place> get results {
    if (!state.submitted || state.query.trim().isEmpty) return [];
    final q = state.query.trim().toLowerCase();
    return allPlaces
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.city.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.address.toLowerCase().contains(q))
        .toList();
  }

  bool get showEmptyState =>
      state.submitted && state.query.trim().isNotEmpty && results.isEmpty;
  bool get showDefaultContent =>
      !state.submitted || state.query.trim().isEmpty;

  void setQuery(String value) {
    emit(
      state.copyWith(query: value, submitted: value.trim().isNotEmpty),
    );
  }

  void clearQuery() {
    emit(state.copyWith(query: '', submitted: false));
  }

  void submit(String value) {
    final v = value.trim();
    final recents = [...state.recentSearches];
    if (v.isNotEmpty && !recents.contains(v)) {
      recents.insert(0, v);
      if (recents.length > 10) {
        recents.removeLast();
      }
    }
    emit(state.copyWith(query: value, submitted: true, recentSearches: recents));
  }

  void setFilter(SearchFilter filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  void removeRecent(String value) {
    emit(
      state.copyWith(
        recentSearches:
            state.recentSearches.where((r) => r != value).toList(),
      ),
    );
  }

  void clearRecents() {
    emit(state.copyWith(recentSearches: []));
  }
}
