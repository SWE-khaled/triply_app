import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/safe_emit_mixin.dart';

import '../../../../core/data/mock/tourguide/mock_guide_dashboard.dart';
import '../../../../core/data/repositories/guide_dashboard_repository.dart';
import '../../../../core/data/repositories/guide_trips_repository.dart';
import '../../../../core/helper/price_format.dart';
import '../../../common/AuthTourguide/data/tour_guide_auth_service.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../model/guide_dashboard_booking_request.dart';
import '../model/guide_dashboard_stats.dart';

part 'dashboard_state.dart';

/// Dashboard state.
///
/// The counters are recomputed from the guide's trips and bookings, both
/// read live from [GuideTripsRepository] / [GuideDashboardRepository], so
/// "Add New Trip" and a new booking show up without a manual reload.
class DashboardCubit extends Cubit<DashboardState>
    with SafeEmitMixin<DashboardState> {
  DashboardCubit({
    GuideTripsRepository? tripsRepository,
    GuideDashboardRepository? dashboardRepository,
  }) : _tripsRepository = tripsRepository ?? GuideTripsRepository(),
       _dashboardRepository = dashboardRepository ?? GuideDashboardRepository(),
       super(const DashboardInitial()) {
    _tripsSubscription = _tripsRepository.watchTrips().listen(
      _onTrips,
      onError: (Object error) =>
          safeEmit(DashboardError(error: error.toString())),
    );
    load();
  }

  final GuideTripsRepository _tripsRepository;
  final GuideDashboardRepository _dashboardRepository;

  StreamSubscription<List<GuideTrip>>? _tripsSubscription;

  /// The guide's trips — the source of the trip counters.
  List<GuideTrip> _trips = const [];

  /// Booking counters, null until they are loaded.
  GuideDashboardMetrics? _metrics;

  /// Whether the verification banner is still shown.
  bool _showVerificationBanner = true;

  /// Loads the booking counters and the verification status.
  Future<void> load() async {
    safeEmit(const DashboardLoading());
    try {
      _metrics = await _dashboardRepository.fetchMetrics();
      _showVerificationBanner = !await _isVerified();
      _emitSuccess();
    } catch (e) {
      safeEmit(DashboardError(error: e.toString()));
    }
  }

  Future<bool> _isVerified() async {
    try {
      return await TourGuideAuthService().isVerificationApproved();
    } catch (_) {
      // Offline or missing document: keep the banner, never crash.
      return false;
    }
  }

  void _onTrips(List<GuideTrip> trips) {
    _trips = trips;
    if (state is DashboardSuccess) _emitSuccess();
  }

  /// Rebuilds the state from the trips + the booking metrics.
  void _emitSuccess() {
    final metrics = _metrics;
    final base = GuideDashboardStats.fromJson(mockGuideDashboardRaw);

    int count(GuideTripStatus status) =>
        _trips.where((trip) => trip.status == status).length;

    safeEmit(
      DashboardSuccess(
        stats: GuideDashboardStats(
          guideName: base.guideName,
          avatarUrl: base.avatarUrl,
          totalBookings: metrics?.totalBookings ?? base.totalBookings,
          upcomingTrips:
              count(GuideTripStatus.active) + count(GuideTripStatus.pending),
          activeTrips: count(GuideTripStatus.active),
          completedTrips: count(GuideTripStatus.completed),
          earningsLabel: metrics == null
              ? base.earningsLabel
              : formatEgp(metrics.totalEarnings),
          pendingRequests: count(GuideTripStatus.pending),
        ),
        bookings:
            metrics?.bookings ??
            mockBookingRequestsRaw.map(BookingRequest.fromJson).toList(),
        showVerificationBanner: _showVerificationBanner,
      ),
    );
  }

  /// Force a recompute (e.g. after returning from a flow that mutates
  /// trips without going through the store listener).
  void refresh() => load();

  @override
  Future<void> close() {
    _tripsSubscription?.cancel();
    return super.close();
  }
}
