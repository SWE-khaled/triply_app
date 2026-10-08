import '../model/search_filter.dart';

class SearchState {
  final String query;
  final SearchFilter activeFilter;
  final List<String> recentSearches;
  final bool submitted;

  const SearchState({
    this.query = '',
    this.activeFilter = SearchFilter.all,
    required this.recentSearches,
    this.submitted = false,
  });

  SearchState copyWith({
    String? query,
    SearchFilter? activeFilter,
    List<String>? recentSearches,
    bool? submitted,
  }) {
    return SearchState(
      query: query ?? this.query,
      activeFilter: activeFilter ?? this.activeFilter,
      recentSearches: recentSearches ?? this.recentSearches,
      submitted: submitted ?? this.submitted,
    );
  }
}
