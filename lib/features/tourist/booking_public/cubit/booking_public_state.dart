import 'package:flutter/foundation.dart';

/// Explicit states of the async public-booking/payment write.
@immutable
sealed class BookingPublicRequestState {
  const BookingPublicRequestState();
}

final class BookingPublicRequestInitial extends BookingPublicRequestState {
  const BookingPublicRequestInitial();
}

final class BookingPublicRequestLoading extends BookingPublicRequestState {
  const BookingPublicRequestLoading();
}

final class BookingPublicRequestCreated extends BookingPublicRequestState {
  const BookingPublicRequestCreated({required this.bookingId});

  final String bookingId;
}

final class BookingPublicRequestConfirmed extends BookingPublicRequestState {
  const BookingPublicRequestConfirmed({required this.bookingId});

  final String bookingId;
}

final class BookingPublicRequestFailed extends BookingPublicRequestState {
  const BookingPublicRequestFailed({required this.message});

  final String message;
}

/// Immutable snapshot of the seats/requests/payment-method form. Emitted
/// fresh by [BookingPublicCubit] from private authoritative fields.
@immutable
class BookingPublicState {
  const BookingPublicState({
    required this.seats,
    required this.specialRequests,
    required this.maxSpots,
    this.paymentMethod = 'card',
    this.request = const BookingPublicRequestInitial(),
  });

  final int seats;
  final String specialRequests;

  /// Seats left for this trip (= capacity - peopleCount), min 1.
  final int maxSpots;

  /// `'card'` or `'wallet'`, chosen by the tourist before paying.
  final String paymentMethod;
  final BookingPublicRequestState request;
}
