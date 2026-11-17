import '../model/search_filter.dart';

/// Immutable snapshot of the local search UI state.
///
/// Every instance is built from the SearchCubit's authoritative fields; there
/// is deliberately no copyWith.
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
}
