import 'package:flutter/foundation.dart';

@immutable
sealed class BookingCancellationState {
  const BookingCancellationState();
}

final class BookingCancellationInitial extends BookingCancellationState {
  const BookingCancellationInitial();
}

final class BookingCancelling extends BookingCancellationState {
  const BookingCancelling();
}

final class BookingCancelled extends BookingCancellationState {
  const BookingCancelled();
}

final class BookingCancelError extends BookingCancellationState {
  final String message;

  const BookingCancelError({required this.message});
}
