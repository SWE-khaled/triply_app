import '../../../../features/tour_guide/my_trips_tg/model/guide_trip.dart';
import 'mock_booking_details.dart';
import 'mock_guide_profile.dart';
import 'mock_guide_shared.dart';
import 'mock_guide_trips.dart';

/// Raw mock source for the tour-guide Dashboard.
/// Convert via GuideDashboardStats.fromJson() / BookingRequest.fromJson().
///
/// The counters are derived from the trips and bookings of this dataset,
/// so the dashboard can never show a total that contradicts the lists
/// rendered underneath it.

final Map<String, dynamic> mockGuideDashboardRaw = {
  'guide_name': mockGuideProfileJson['name'],
  'avatar_url': mockGuideProfileJson['avatarUrl'],
  'total_bookings': mockBookingDetailsRaw.length,
  'upcoming_trips':
      mockGuideTripsCountForTab(GuideTripStatus.active) +
      mockGuideTripsCountForTab(GuideTripStatus.pending),
  'active_trips': mockGuideTripsCountForTab(GuideTripStatus.active),
  'completed_trips': mockGuideTripsCountForTab(GuideTripStatus.completed),
  'earnings_label': mockAmountLabel(mockBookingsTotal()),
  'pending_requests': mockGuideTripsCountForTab(GuideTripStatus.pending),
};

/// The "New bookings" rows of the dashboard, derived from the very same
/// booking records the details screen reads.
final List<Map<String, dynamic>> mockBookingRequestsRaw = mockBookingDetailsRaw
    .map(
      (booking) => <String, dynamic>{
        'id': booking['id'],
        'guest_name': booking['guest_name'],
        'tour_title': booking['tour_title'],
        'detail_label': booking['detail_label'],
        'avatar_url': booking['avatar_url'],
        'is_private': booking['is_private'],
      },
    )
    .toList();
