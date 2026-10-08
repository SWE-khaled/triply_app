class GuidesState {
  final String searchQuery;
  final String selectedLanguage;

  const GuidesState({
    this.searchQuery = '',
    this.selectedLanguage = 'All',
  });

  GuidesState copyWith({String? searchQuery, String? selectedLanguage}) {
    return GuidesState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
