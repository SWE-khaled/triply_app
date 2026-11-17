import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:triply/core/data/repositories/booking_repository.dart';
import 'package:triply/core/data/trip_details_source.dart';
import 'package:triply/features/tourist/checkout/services/payment_service.dart';
import 'package:triply/features/tourist/trip_details/model/trip_details.dart';
import 'package:triply/features/tourist/trips/models/trip.dart';

import 'booking_public_state.dart';

/// The public-trip booking: seats, price, payment method and the async
/// booking/payment writes. All Firestore and session work goes through
/// [PaymentService]; the View only dispatches and renders state.
class BookingPublicCubit extends Cubit<BookingPublicState> {
  static const double serviceRate = 0.05;
  static const int minSeats = 1;

  BookingPublicCubit({PaymentService? paymentService})
    : _paymentService = paymentService ?? PaymentService(),
      super(
        const BookingPublicState(
          seats: 1,
          specialRequests: '',
          maxSpots: 6,
          paymentMethod: 'card',
        ),
      );

  final PaymentService _paymentService;

  int _seats = 1;
  String _specialRequests = '';
  int _maxSpots = 6;
  String _paymentMethod = 'card';
  BookingPublicRequestState _request = const BookingPublicRequestInitial();

  late final TripDetails _details;

  /// The trip details resolved once when the screen prepares this cubit.
  /// Mapping the public Trip into TripDetails belongs here, not in the View.
  TripDetails get details => _details;
  BookingPublicRequestState get request => _request;

  void _emit() {
    if (isClosed) return;
    emit(
      BookingPublicState(
        seats: _seats,
        specialRequests: _specialRequests,
        maxSpots: _maxSpots,
        paymentMethod: _paymentMethod,
        request: _request,
      ),
    );
  }

  /// Resolves the trip details and links the group size to availability:
  /// spots left = trip capacity - people already on the trip.
  void prepareTrip(Trip trip) {
    _details = const TripDetailsSource().getByTripId(
      trip.id,
      title: trip.title,
      imageUrl: trip.imageUrl,
      priceEgp: trip.priceEgp,
      guideName: trip.guideName,
    );
    setMaxSpots(trip.capacity - trip.peopleCount);
  }

  void setMaxSpots(int maxSpots) {
    final clamped = maxSpots < minSeats ? minSeats : maxSpots;
    _maxSpots = clamped;
    if (_seats > clamped) _seats = clamped;
    _emit();
  }

  int _clamp(int seats) {
    if (seats < minSeats) return minSeats;
    if (seats > _maxSpots) return _maxSpots;
    return seats;
  }

  void changeSeats(int seats) {
    _seats = _clamp(seats);
    _emit();
  }

  void changeRequests(String value) {
    _specialRequests = value;
    _emit();
  }

  /// Switches between `'card'` and `'wallet'`. Stored on the booking so
  /// the guide and the expiry/cancel logic know how it was paid.
  void changePaymentMethod(String method) {
    if (method != 'card' && method != 'wallet') return;
    _paymentMethod = method;
    _emit();
  }

  double subtotal(double unitPrice) => unitPrice * _seats;

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
  /// meantime (the local My Trips record is released in that case). The
  /// explicit [BookingPublicRequestState] carries the same result to the UI.
  Future<String?> createBooking({
    required String tripId,
    required double unitPrice,
  }) async {
    _request = const BookingPublicRequestLoading();
    _emit();
    try {
      final bookingId = await _paymentService.createPublicPendingBooking(
        tripId: tripId,
        seats: _seats,
        unitPrice: unitPrice,
        paymentMethod: _paymentMethod,
        specialRequests: _specialRequests,
      );
      if (bookingId == null) {
        _request = const BookingPublicRequestFailed(
          message: 'This trip just filled up. Please pick another one.',
        );
        _emit();
        return null;
      }
      _request = BookingPublicRequestCreated(bookingId: bookingId);
      _emit();
      return bookingId;
    } on BookingException catch (error) {
      _request = BookingPublicRequestFailed(message: error.message);
      _emit();
      return null;
    } catch (_) {
      _request = const BookingPublicRequestFailed(
        message: 'The payment failed. Please try again.',
      );
      _emit();
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
    _request = const BookingPublicRequestLoading();
    _emit();
    try {
      await _paymentService.confirmBooking(bookingId, paymentId: paymentId);
      _request = BookingPublicRequestConfirmed(bookingId: bookingId);
      _emit();
    } catch (_) {
      _request = const BookingPublicRequestFailed(
        message: 'Could not confirm your booking. Please try again.',
      );
      _emit();
    }
  }
}
