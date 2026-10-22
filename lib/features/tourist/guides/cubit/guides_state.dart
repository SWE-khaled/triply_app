part of 'guides_cubit.dart';

@immutable
sealed class GuidesState {
  const GuidesState();
}

final class GuidesInitial extends GuidesState {
  const GuidesInitial();
}

final class GuidesLoading extends GuidesState {
  const GuidesLoading();
}

final class GuidesSuccess extends GuidesState {
  /// What the tourist typed into the search field.
  final String searchQuery;

  /// The language filter that is active.
  final String selectedLanguage;

  /// The guides that pass the filters.
  final List<Guide> guides;

  /// How many guides there are in total.
  final int totalCount;

  const GuidesSuccess({
    required this.searchQuery,
    required this.selectedLanguage,
    required this.guides,
    required this.totalCount,
  });
}

final class GuidesError extends GuidesState {
  final String error;

  const GuidesError({required this.error});
}
