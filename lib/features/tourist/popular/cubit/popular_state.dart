part of 'popular_cubit.dart';

@immutable
sealed class PopularState {
  const PopularState();
}

final class PopularInitial extends PopularState {
  const PopularInitial();
}

final class PopularLoading extends PopularState {
  const PopularLoading();
}

final class PopularSuccess extends PopularState {
  /// The category the list is filtered by.
  final String selectedCategory;

  /// The trips of that category.
  final List<Trip> trips;

  const PopularSuccess({required this.selectedCategory, required this.trips});
}

final class PopularError extends PopularState {
  final String error;

  const PopularError({required this.error});
}
