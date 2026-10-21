import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../../../../core/data/repositories/booking_repository.dart';
import '../model/booking_public.dart';
import 'booking_public_state.dart';

/// The public-trip booking: seats, price and the Firestore write.
class BookingPublicCubit extends Cubit<BookingPublicState> {
  static const double serviceRate = 0.05;
  static const int minSeats = 1;

  final BookingRepository _repository;

  BookingPublicCubit({BookingRepository? repository})
    : _repository = repository ?? BookingRepository(),
      super(
        const BookingPublicState(seats: 1, specialRequests: '', maxSpots: 6),
      );

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

  /// Records the booking and reserves the seats on the trip.
  ///
  /// The booking is written to Firestore inside a transaction, so the
  /// guide sees it on their dashboard and the seats are taken off the
  /// trip for everybody else.
  ///
  /// Returns null when the trip filled up in the meantime — the local
  /// record is released again in that case.
  Future<BookingPublic?> confirm({
    required String tripId,
    required double unitPrice,
  }) async {
    final booking = BookingPublic(
      tripId: tripId,
      seats: state.seats,
      specialRequests: state.specialRequests,
      unitPrice: unitPrice,
      serviceFee: fee(unitPrice),
      total: total(unitPrice),
    );
    // Makes the trip appear in My Trips (Upcoming, pending approval).
    // Only called after a successful payment (see BookingPublicScreen).
    MyBookingsPublic.record(tripId, booking.seats, totalPaid: booking.total);
    try {
      await _repository.createPublicBooking(
        tripId: tripId,
        seats: booking.seats,
        unitPrice: unitPrice,
        specialRequests: state.specialRequests,
      );
    } on BookingException {
      // The trip filled up while the tourist was paying — release the
      // local record so "My Trips" stays truthful.
      MyBookingsPublic.cancelBooking(tripId);
      return null;
    }
    return booking;
  }
}
