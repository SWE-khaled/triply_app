import '../../trips/models/trip.dart';

class PopularState {
  final String selectedCategory;
  final List<Trip> trips;

  const PopularState({
    required this.selectedCategory,
    required this.trips,
  });

  PopularState copyWith({
    String? selectedCategory,
    List<Trip>? trips,
  }) {
    return PopularState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      trips: trips ?? this.trips,
    );
  }
}
