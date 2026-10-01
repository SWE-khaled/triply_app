import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/mock/mock_trips_public.dart';
import '../../../data/my_bookings_public.dart';
import '../../trips/models/trip.dart';
import 'my_trips_state.dart';

/// Booked-only list (My Trips). Reads the session booking_public store;
/// unbooked trips never appear here, no matter their status.
class MyTripsCubit extends Cubit<MyTripsState> {
  MyTripsCubit()
    : super(
        MyTripsState(
          selectedTab: TripStatus.upcoming,
          trips: _booked(TripStatus.upcoming),
        ),
      );

  static List<Trip> _booked(TripStatus status) => mockTripsJson
      .map((e) => Trip.fromJson(e))
      .where((t) => t.status == status && MyBookingsPublic.isBooked(t.id))
      .toList();

  void selectTab(TripStatus status) {
    emit(state.copyWith(selectedTab: status, trips: _booked(status)));
  }

  void refresh() {
    emit(state.copyWith(trips: _booked(state.selectedTab)));
  }
}
