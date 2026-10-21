import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_trips_public.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import '../../trips/models/trip.dart';
import 'popular_state.dart';

/// Category filter over the trips the tourists may book.
///
/// The trips come from Firestore — the approved ones — and the mock
/// dataset is the fallback for when the read fails (offline). An empty
/// list is a real answer: no trip is approved yet.
class PopularCubit extends Cubit<PopularState> {
  static const List<String> categories = [
    'All',
    'Activities',
    'Historical',
    'Nature',
    'Food',
  ];

  PopularCubit({PublicTripsRepository? repository})
    : _repository = repository ?? PublicTripsRepository(),
      super(const PopularState(selectedCategory: 'All', trips: [])) {
    load();
  }

  final PublicTripsRepository _repository;

  /// Every trip on offer, before the category filter.
  List<Trip> _all = const [];

  /// Reads the approved trips and applies the current filter.
  Future<void> load() async {
    final remote = await _repository.fetchApprovedTrips();
    _all = remote ?? _mockTrips();
    _applyCategory(state.selectedCategory);
  }

  void selectCategory(String category) => _applyCategory(category);

  void _applyCategory(String category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        trips: category == 'All'
            ? _all
            : _all
                  .where(
                    (t) => t.category.toLowerCase() == category.toLowerCase(),
                  )
                  .toList(),
      ),
    );
  }

  /// The bundled trips, used when Firestore cannot be reached.
  static List<Trip> _mockTrips() =>
      mockTripsJson.map((e) => Trip.fromJson(e)).toList();
}
