import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/mock/mock_trips_public.dart';
import '../models/trip.dart';
import 'trips_state.dart';

/// Owns the tab filter + trip list (mock -> Model). View only renders.
class TripsCubit extends Cubit<TripsState> {
  TripsCubit()
    : super(
        TripsState(
          selectedTab: TripStatus.upcoming,
          trips: _filter(TripStatus.upcoming),
        ),
      );

  static List<Trip> _all() =>
      mockTripsJson.map((e) => Trip.fromJson(e)).toList();

  static List<Trip> _filter(TripStatus status) =>
      _all().where((t) => t.status == status).toList();

  void selectTab(TripStatus status) {
    emit(state.copyWith(selectedTab: status, trips: _filter(status)));
  }
}
