import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/mock/mock_trips.dart';
import '../../trips/models/trip.dart';
import 'popular_state.dart';

/// Category filter over the shared mock trips (mock -> Model).
/// Reuses the Trip model owned by the trips feature — no duplicate model.
class PopularCubit extends Cubit<PopularState> {
  static const List<String> categories = [
    'All',
    'Activities',
    'Historical',
    'Nature',
    'Food',
  ];

  PopularCubit()
      : super(PopularState(
          selectedCategory: 'All',
          trips: _all(),
        ));

  static List<Trip> _all() =>
      mockTripsJson.map((e) => Trip.fromJson(e)).toList();

  void selectCategory(String category) {
    final all = _all();
    emit(state.copyWith(
      selectedCategory: category,
      trips: category == 'All'
          ? all
          : all
              .where((t) =>
                  t.category.toLowerCase() == category.toLowerCase())
              .toList(),
    ));
  }
}
