import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/my_bookings_public.dart';
import 'package:triply/core/data/repositories/booking_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../../trips/models/trip.dart';
import 'booking_cancellation_state.dart';

/// Owns the "cancel one booking" operation.
///
/// Its states are independent from [MyTripsCubit] so a cancellation cannot
/// replace the trips list loading state.
class BookingCancellationCubit extends Cubit<BookingCancellationState>
    with SafeEmitMixin<BookingCancellationState> {
  BookingCancellationCubit({
    BookingRepository? bookingRepository,
    required this.onCancelled,
  }) : _bookingRepository = bookingRepository ?? BookingRepository(),
       super(const BookingCancellationInitial());

  final BookingRepository _bookingRepository;

  /// Refreshes the authoritative bookings list after a successful cancel.
  final Future<void> Function() onCancelled;

  bool _isBusy = false;

  Future<void> cancel(Trip trip) async {
    if (_isBusy) return;
    _isBusy = true;
    safeEmit(const BookingCancelling());
    try {
      final bookingId = trip.bookingId;
      if (bookingId == null) {
        if (!MyBookingsPublic.isBooked(trip.id)) {
          throw const BookingException('This booking is no longer available.');
        }
        MyBookingsPublic.cancelBooking(trip.id);
      } else {
        await _bookingRepository.cancelBooking(bookingId: bookingId);
        MyBookingsPublic.cancelBooking(trip.id);
      }
      await onCancelled();
      safeEmit(const BookingCancelled());
    } catch (_) {
      safeEmit(
        const BookingCancelError(
          message: 'Could not cancel this booking. Please try again.',
        ),
      );
    } finally {
      _isBusy = false;
    }
  }
}
