import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../models/search_filter.dart';
import '../data/mock/mock_places.dart';
import '../data/mock/mock_search.dart';

class SearchController extends ChangeNotifier {
  String query = '';
  SearchFilter activeFilter = SearchFilter.all;
  List<String> recentSearches = List.of(mockRecentSearches);
  final List<Place> allPlaces =
      mockPlacesRaw.map(Place.fromJson).toList();
  bool submitted = false;

  List<Map<String, String>> get popularDestinations => mockPopularDestinations;
  List<String> get popularSearches => mockPopularSearches;

  List<Map<String, String>> get results {
    if (!submitted || query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    return mockPopularDestinations
        .where((d) => (d['name'] ?? '').toLowerCase().contains(q))
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
