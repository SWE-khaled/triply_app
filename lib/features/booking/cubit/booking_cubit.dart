import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/booking.dart';
import 'booking_state.dart';

/// Owns seats/requests state + pricing (mock phase, local math only).
class BookingCubit extends Cubit<BookingState> {
  static const double serviceRate = 0.05;
  static const int minSeats = 1;

  BookingCubit()
    : super(const BookingState(seats: 1, specialRequests: '', maxSpots: 6));

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

  Booking confirm({required String tripId, required double unitPrice}) {
    return Booking(
      tripId: tripId,
      seats: state.seats,
      specialRequests: state.specialRequests,
      unitPrice: unitPrice,
      serviceFee: fee(unitPrice),
      total: total(unitPrice),
    );
  }
}
