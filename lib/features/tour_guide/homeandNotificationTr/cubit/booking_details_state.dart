import '../model/booking_details.dart';

class BookingDetailsState {
  final BookingDetails? details;
  final bool isLoading;
  final String? error;

  const BookingDetailsState({
    required this.details,
    this.isLoading = false,
    this.error,
  });

  BookingDetailsState copyWith({
    BookingDetails? details,
    bool? isLoading,
    String? error,
  }) {
    return BookingDetailsState(
      details: details ?? this.details,
      isLoading: isLoading ?? this.isLoading,
      // Null clears a previous error; pass the current error to preserve.
      error: error,
    );
  }
}
