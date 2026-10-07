import 'package:flutter/foundation.dart';
import '../../../../core/data/guide_trips_store.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../model/guide_dashboard_booking_request.dart';
import '../model/guide_dashboard_stats.dart';
import '../../../../../core/data/mock/tourguide/mock_guide_dashboard.dart';

/// Dashboard state: trip-derived counts recomputed from the shared
/// [GuideTripsStore] (created + mock trips) so "Add New Trip" flows
/// update the cards automatically via the store listener.
///
/// [totalBookings] and [earningsLabel] still come from the dashboard mock:
/// bookings/earnings have no local store yet (separate entities with
/// their own screens/cubits). Everything else is dynamic.
class DashboardController extends ChangeNotifier {
  late GuideDashboardStats stats;
  List<BookingRequest> bookings = [];

  DashboardController() {
    GuideTripsStore.addListener(_rebuild);
    _rebuild();
  }

  void _rebuild() {
    final trips = GuideTripsStore.allTrips();
    final base = GuideDashboardStats.fromJson(mockGuideDashboardRaw);
    int count(GuideTripStatus status) =>
        trips.where((t) => t.status == status).length;
    final pending = count(GuideTripStatus.pending);
    final active = count(GuideTripStatus.active);
    stats = GuideDashboardStats(
      guideName: base.guideName,
      avatarUrl: base.avatarUrl,
      totalBookings: base.totalBookings,
      upcomingTrips: active + pending,
      activeTrips: active,
      completedTrips: count(GuideTripStatus.completed),
      earningsLabel: base.earningsLabel,
      pendingRequests: pending,
    );
    bookings = mockBookingRequestsRaw.map(BookingRequest.fromJson).toList();
    notifyListeners();
  }

  /// Force a recompute (e.g. after returning from a flow that mutates
  /// trips without going through the store listener).
  void refresh() => _rebuild();

  @override
  void dispose() {
    GuideTripsStore.removeListener(_rebuild);
    super.dispose();
  }
}
