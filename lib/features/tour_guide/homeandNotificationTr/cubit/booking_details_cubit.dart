import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/data/mock/tourguide/mock_booking_details.dart';
import '../model/booking_details.dart';
import 'booking_details_state.dart';

class BookingDetailsCubit extends Cubit<BookingDetailsState> {
  BookingDetailsCubit({required String bookingId})
      : super(
          BookingDetailsState(
            details: _lookup(bookingId),
          ),
        );

  static BookingDetails? _lookup(String bookingId) {
    final matches = mockBookingDetailsRaw.where((e) => e['id'] == bookingId);
    return matches.isEmpty ? null : BookingDetails.fromJson(matches.first);
  }
}
