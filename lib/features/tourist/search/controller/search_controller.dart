import 'package:flutter/foundation.dart';
import 'package:admin_dashboard/core/data/mock/tourist/mock_places.dart';
import '../../map/model/place.dart';
import '../model/search_filter.dart';
import '../../../../core/data/mock/tourist/mock_search.dart';

/// Searches the existing Map places list (single source of truth).
/// Popular searches / destinations reference Map places by id.
class SearchController extends ChangeNotifier {
  String query = '';
  SearchFilter activeFilter = SearchFilter.all;
  List<String> recentSearches = List.of(mockRecentSearches);
  final List<Place> allPlaces =
      mockPlaces.map(Place.fromJson).toList();
  bool submitted = false;

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

  Place _byId(String id) => allPlaces.firstWhere(
        (p) => p.id == id,
        orElse: () => allPlaces.first,
      );

  List<Place> get popularSearches =>
      [for (final id in _popularSearchIds) _byId(id)];

  List<Place> get popularDestinations =>
      [for (final id in _popularDestinationIds) _byId(id)];

  List<Place> get results {
    if (!submitted || query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    return allPlaces
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.city.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.address.toLowerCase().contains(q))
        .toList();
  }

  bool get showEmptyState => submitted && query.trim().isNotEmpty && results.isEmpty;
  bool get showDefaultContent => !submitted || query.trim().isEmpty;

  void setQuery(String value) {
    query = value;
    submitted = value.trim().isNotEmpty;
    notifyListeners();
  }

  void clearQuery() {
    query = '';
    submitted = false;
    notifyListeners();
  }

  void submit(String value) {
    query = value;
    submitted = true;
    final v = value.trim();
    if (v.isNotEmpty && !recentSearches.contains(v)) {
      recentSearches.insert(0, v);
      if (recentSearches.length > 10) {
        recentSearches.removeLast();
      }
    }
    notifyListeners();
  }

  void setFilter(SearchFilter filter) {
    activeFilter = filter;
    notifyListeners();
  }

  void removeRecent(String value) {
    recentSearches.remove(value);
    notifyListeners();
  }

  void clearRecents() {
    recentSearches.clear();
    notifyListeners();
  }
}

