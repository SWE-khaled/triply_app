class GuideProfileState {
  final bool bookmarked;

  const GuideProfileState({this.bookmarked = false});

  GuideProfileState copyWith({bool? bookmarked}) {
    return GuideProfileState(bookmarked: bookmarked ?? this.bookmarked);
  }
}
