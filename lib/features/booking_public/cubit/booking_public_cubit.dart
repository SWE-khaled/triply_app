import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/my_bookings_public.dart';
import '../model/booking_public.dart';
import 'booking_public_state.dart';

class BookingPublicCubit extends Cubit<BookingPublicState> {
  static const double serviceRate = 0.05;
  static const int minSeats = 1;

  BookingPublicCubit()
      : super(const BookingPublicState(seats: 1, specialRequests: '', maxSpots: 6));

  /// Links the card's group size to availability:
  /// spots left = trip capacity - people already on the trip.
  void setMaxSpots(int maxSpots) {
    final clamped = maxSpots < minSeats ? minSeats : maxSpots;
    emit(
      state.copyWith(
        maxSpots: clamped,
        seats: state.seats > clamped ? clamped : state.seats,
      ),
    );
  }

  int _clamp(int seats) {
    if (seats < minSeats) return minSeats;
    if (seats > state.maxSpots) return state.maxSpots;
    return seats;
  }

  void changeSeats(int seats) => emit(state.copyWith(seats: _clamp(seats)));

  void changeRequests(String value) =>
      emit(state.copyWith(specialRequests: value));

  double subtotal(double unitPrice) => unitPrice * state.seats;

  double fee(double unitPrice) => subtotal(unitPrice) * serviceRate;

  double total(double unitPrice) => subtotal(unitPrice) + fee(unitPrice);

  BookingPublic confirm({required String tripId, required double unitPrice}) {
    final booking = BookingPublic(
      tripId: tripId,
      seats: state.seats,
      specialRequests: state.specialRequests,
      unitPrice: unitPrice,
      serviceFee: fee(unitPrice),
      total: total(unitPrice),
    );
    // Makes the trip appear in My Trips (Upcoming).
    MyBookingsPublic.record(tripId, booking.seats);
    return booking;
  }
}
