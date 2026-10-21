import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/safe_emit_mixin.dart';

import '../../../../../core/data/repositories/guide_dashboard_repository.dart';
import '../model/booking_details.dart';

part 'booking_details_state.dart';

/// One booking of the guide, opened from the dashboard "New bookings"
/// list.
///
/// Reads the booking from Firestore, with the mock dataset as fallback.
class BookingDetailsCubit extends Cubit<BookingDetailsState>
    with SafeEmitMixin<BookingDetailsState> {
  BookingDetailsCubit({
    required this.bookingId,
    GuideDashboardRepository? repository,
  }) : _repository = repository ?? GuideDashboardRepository(),
       super(const BookingDetailsInitial()) {
    load();
  }

  /// The booking this screen shows.
  final String bookingId;

  final GuideDashboardRepository _repository;

  /// Loads the booking.
  Future<void> load() async {
    safeEmit(const BookingDetailsLoading());
    try {
      final details = await _repository.fetchBookingDetails(bookingId);
      if (details == null) {
        safeEmit(const BookingDetailsError(error: 'Booking not found.'));
        return;
      }
      safeEmit(BookingDetailsSuccess(details: details));
    } catch (e) {
      safeEmit(BookingDetailsError(error: e.toString()));
    }
  }
}
