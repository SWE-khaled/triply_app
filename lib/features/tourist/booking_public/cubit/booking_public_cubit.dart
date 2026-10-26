import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../../../../core/data/repositories/booking_repository.dart';
import '../model/booking_public.dart';
import 'booking_public_state.dart';

/// The public-trip booking: seats, price, payment method and the Firestore write.
class BookingPublicCubit extends Cubit<BookingPublicState> {
  static const double serviceRate = 0.05;
  static const int minSeats = 1;

  final BookingRepository _repository;

  BookingPublicCubit({BookingRepository? repository})
    : _repository = repository ?? BookingRepository(),
      super(
        const BookingPublicState(
          seats: 1,
          specialRequests: '',
          maxSpots: 6,
          paymentMethod: 'card',
        ),
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

  /// Switches between `'card'` and `'wallet'`. Stored on the booking so
  /// the guide and the expiry/cancel logic know how it was paid.
  void changePaymentMethod(String method) {
    if (method != 'card' && method != 'wallet') return;
    emit(state.copyWith(paymentMethod: method));
  }

  double subtotal(double unitPrice) => unitPrice * state.seats;

  double fee(double unitPrice) => subtotal(unitPrice) * serviceRate;

  double total(double unitPrice) => subtotal(unitPrice) + fee(unitPrice);

  /// Creates the booking as `status: 'pending'`, `paymentStatus: 'pending'`
  /// and reserves the seats inside one Firestore transaction.
  ///
  /// The booking is created *before* payment so that, if the tourist
  /// abandons the Paymob WebView, its seats are released by the lazy
  /// expiry instead of being held forever.
  ///
  /// Returns the booking id, or null when the trip filled up in the
  /// meantime (the local My Trips record is released in that case).
  Future<String?> createBooking({
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
    MyBookingsPublic.record(tripId, booking.seats, totalPaid: booking.total);
    try {
      final receipt = await _repository.createPublicBooking(
        tripId: tripId,
        seats: booking.seats,
        unitPrice: unitPrice,
        paymentMethod: state.paymentMethod,
        specialRequests: state.specialRequests,
      );
      return receipt.bookingId;
    } on BookingException {
      // The trip filled up while the tourist was preparing to pay —
      // release the local record so "My Trips" stays truthful.
      MyBookingsPublic.cancelBooking(tripId);
      return null;
    }
  }

  /// Confirms the booking after the Paymob WebView reports success.
  ///
  /// Sets `status: 'confirmed'`, `paymentStatus: 'paid'` and records the
  /// `paymentId`. On failure or close the booking stays `pending` and
  /// expires after 30 minutes.
  Future<void> confirmPayment({
    required String bookingId,
    required String paymentId,
  }) async {
    await _repository.confirmPayment(bookingId: bookingId, paymentId: paymentId);
  }
}
