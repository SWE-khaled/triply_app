import 'mock_booking_details.dart';
import 'mock_guide_shared.dart';

/// Raw mock source for the guide earnings screen.
/// Convert via EarningsSummary.fromJson().
///
/// The activities are the guide's bookings, so the available balance
/// always equals the sum of the listed activities.

final Map<String, dynamic> mockEarningsJson = {
  'availableBalance': mockBookingsTotal(),
  'month': mockMonthName(mockNow),
  'activities': _activities(),
};

List<Map<String, dynamic>> _activities() => mockBookingDetailsRaw
    .map(
      (booking) => <String, dynamic>{
        'id': 'ea-${booking['id']}',
        'bookingId': booking['id'],
        'tripId': booking['tripId'],
        'title': booking['tour_title'],
        'amountEgp': booking['totalPrice'],
      },
    )
    .toList();
