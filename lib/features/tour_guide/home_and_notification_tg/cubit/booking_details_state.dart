part of 'booking_details_cubit.dart';

@immutable
sealed class BookingDetailsState {
  const BookingDetailsState();
}

final class BookingDetailsInitial extends BookingDetailsState {
  const BookingDetailsInitial();
}

final class BookingDetailsLoading extends BookingDetailsState {
  const BookingDetailsLoading();
}

final class BookingDetailsSuccess extends BookingDetailsState {
  final BookingDetails details;

  const BookingDetailsSuccess({required this.details});
}

final class BookingDetailsError extends BookingDetailsState {
  final String error;

  const BookingDetailsError({required this.error});
}
