import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock/tourist/mock_trips_public.dart';
import '../../../../core/data/my_bookings_public.dart';
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

  static List<Trip> _booked(TripStatus status) {
    final public = mockTripsJson
        .map((e) => Trip.fromJson(e))
        .where((t) => t.status == status && MyBookingsPublic.isBooked(t.id))
        .map((t) {
          // Show the actually booked seat count, not the mock headcount.
          final seats = MyBookingsPublic.seatsFor(t.id);
          if (seats <= 0) return t;
          return Trip(
            id: t.id,
            title: t.title,
            dateLabel: t.dateLabel,
            guideName: t.guideName,
            peopleCount: seats,
            priceEgp: t.priceEgp,
            imageUrl: t.imageUrl,
            status: t.status,
            category: t.category,
            capacity: t.capacity,
          );
        })
        .toList();
    // Private guide bookings appear under Upcoming as synthetic trips
    // (built from the stored booking, never duplicated mock data).
    if (status == TripStatus.upcoming) {
      for (final record in MyBookingsPublic.privateRecords) {
        final entry = record.value;
        public.add(
          Trip(
            id: record.key,
            title: entry.title ?? 'Private tour',
            dateLabel: entry.dateLabel ?? '',
            guideName: entry.guideName ?? '',
            peopleCount: entry.seats,
            priceEgp: entry.totalPaid,
            imageUrl: entry.imageUrl ?? '',
            status: TripStatus.upcoming,
            category: 'private',
            capacity: entry.seats,
          ),
        );
      }
    }
    return public;
  }

  void selectTab(TripStatus status) {
    emit(state.copyWith(selectedTab: status, trips: _booked(status)));
  }

  void refresh() {
    emit(state.copyWith(trips: _booked(state.selectedTab)));
  }
}
