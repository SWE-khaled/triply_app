import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/guide_trips_store.dart';
import '../../../common/AuthTourguide/data/tour_guide_auth_service.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../model/guide_dashboard_booking_request.dart';
import '../model/guide_dashboard_stats.dart';
import '../../../../../core/data/mock/tourguide/mock_guide_dashboard.dart';
import 'dashboard_state.dart';

/// Dashboard state: trip-derived counts recomputed from the shared
/// [GuideTripsStore] (created + mock trips) so "Add New Trip" flows
/// update the cards automatically via the store listener.
///
/// [totalBookings] and [earningsLabel] still come from the dashboard mock:
/// bookings/earnings have no local store yet (separate entities with
/// their own screens/cubits). Everything else is dynamic.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(_initial()) {
    GuideTripsStore.addListener(_rebuild);
    _rebuild();
    _loadVerificationStatus();
  }

  static DashboardState _initial() {
    final base = GuideDashboardStats.fromJson(mockGuideDashboardRaw);
    return DashboardState(
      stats: GuideDashboardStats(
        guideName: base.guideName,
        avatarUrl: base.avatarUrl,
        totalBookings: base.totalBookings,
        upcomingTrips: 0,
        activeTrips: 0,
        completedTrips: 0,
        earningsLabel: base.earningsLabel,
        pendingRequests: 0,
      ),
      bookings: mockBookingRequestsRaw.map(BookingRequest.fromJson).toList(),
      showVerificationBanner: true,
    );
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final approved =
          await TourGuideAuthService().isVerificationApproved();
      emit(state.copyWith(showVerificationBanner: !approved));
    } catch (_) {
      emit(state.copyWith(showVerificationBanner: true));
    }
  }

  void _rebuild() {
    final trips = GuideTripsStore.allTrips();
    final base = GuideDashboardStats.fromJson(mockGuideDashboardRaw);
    int count(GuideTripStatus status) =>
        trips.where((t) => t.status == status).length;
    final pending = count(GuideTripStatus.pending);
    final active = count(GuideTripStatus.active);
    emit(
      state.copyWith(
        stats: GuideDashboardStats(
          guideName: base.guideName,
          avatarUrl: base.avatarUrl,
          totalBookings: base.totalBookings,
          upcomingTrips: active + pending,
          activeTrips: active,
          completedTrips: count(GuideTripStatus.completed),
          earningsLabel: base.earningsLabel,
          pendingRequests: pending,
        ),
        bookings:
            mockBookingRequestsRaw.map(BookingRequest.fromJson).toList(),
      ),
    );
  }

  /// Force a recompute (e.g. after returning from a flow that mutates
  /// trips without going through the store listener).
  void refresh() => _rebuild();

  @override
  Future<void> close() {
    GuideTripsStore.removeListener(_rebuild);
    return super.close();
  }
}
