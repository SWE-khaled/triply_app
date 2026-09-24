enum SearchFilter { all, places, guides, trips, experiences }

extension SearchFilterLabel on SearchFilter {
  String get label {
    switch (this) {
      case SearchFilter.all:
        return 'All';
      case SearchFilter.places:
        return 'Places';
      case SearchFilter.guides:
        return 'Guides';
      case SearchFilter.trips:
        return 'Trips';
      case SearchFilter.experiences:
        return 'Experiences';
    }
  }
}
