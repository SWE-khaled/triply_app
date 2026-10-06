import 'package:flutter/foundation.dart';
import '../model/guide_dashboard_booking_request.dart';
import '../model/guide_dashboard_stats.dart';
import '../../../../core/data/mock/tourguide/mock_guide_dashboard.dart';

class DashboardController extends ChangeNotifier {
  late final GuideDashboardStats stats;
  List<BookingRequest> bookings = [];

  DashboardController() {
    stats = GuideDashboardStats.fromJson(mockGuideDashboardRaw);
    bookings = mockBookingRequestsRaw.map(BookingRequest.fromJson).toList();
  }
}
