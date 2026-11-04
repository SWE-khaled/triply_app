part of 'bookings_cubit.dart';

/// The state of the Bookings tab.
@immutable
sealed class BookingsState {
  const BookingsState();
}

/// Nothing has been requested yet.
final class BookingsInitial extends BookingsState {
  const BookingsInitial();
}

/// The booking list is being loaded for the first time.
final class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

/// The booking stream failed.
final class BookingsError extends BookingsState {
  final String message;

  const BookingsError(this.message);
}

/// The live booking list, with the current search applied.
final class BookingsSuccess extends BookingsState {
  final List<AdminBooking> bookings;
  final String query;
  final bool busy;

  const BookingsSuccess({
    required this.bookings,
    this.query = '',
    this.busy = false,
  });

  List<AdminBooking> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return bookings;
    return bookings.where((booking) {
      return booking.user.toLowerCase().contains(q) ||
          booking.trip.toLowerCase().contains(q) ||
          booking.guide.toLowerCase().contains(q) ||
          booking.date.toLowerCase().contains(q) ||
          booking.status.toLowerCase().contains(q) ||
          booking.type.toLowerCase().contains(q);
    }).toList();
  }

  BookingsSuccess copyWith({
    List<AdminBooking>? bookings,
    String? query,
    bool? busy,
  }) {
    return BookingsSuccess(
      bookings: bookings ?? this.bookings,
      query: query ?? this.query,
      busy: busy ?? this.busy,
    );
  }
}
