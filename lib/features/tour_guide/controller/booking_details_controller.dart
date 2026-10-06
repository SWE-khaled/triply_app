import 'package:flutter/foundation.dart';
import '../model/booking_details.dart';
import '../../../../core/data/mock/tourguide/mock_booking_details.dart';

class BookingDetailsController extends ChangeNotifier {
  final String bookingId;
  BookingDetails? details;

  BookingDetailsController({required this.bookingId}) {
    final matches = mockBookingDetailsRaw.where((e) => e['id'] == bookingId);
    details =
        matches.isEmpty ? null : BookingDetails.fromJson(matches.first);
  }
}
