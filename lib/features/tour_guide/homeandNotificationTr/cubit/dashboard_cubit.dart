import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import 'package:triply/data/firestore/repositories/guide_trips_repository.dart';
import '../../../../core/data/guide_trips_store.dart';
import '../../../common/AuthTourguide/data/tour_guide_auth_service.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../model/guide_dashboard_booking_request.dart';
import '../model/guide_dashboard_stats.dart';
import '../../../../../core/data/mock/tourguide/mock_guide_dashboard.dart';
import 'dashboard_state.dart';

/// Dashboard state: trip/booking counts recomputed from Firebase when
/// available, session/mock store otherwise.
///
/// [totalBookings] counts the guide's booking documents; trip cards count
/// remote trips by mapped status (approved → active). [earningsLabel] has
/// no guide-scoped backend source yet and stays mock, as do the New
/// bookings rows (separate screens own those entities).
class DashboardCubit extends Cubit<DashboardState> {
  final GuideTripsRepository _tripsRepo;
  final BookingsRepository _bookingsRepo;

  /// Last successful remote fetch. Null until the first success — counts
  /// fall back to the session/mock store meanwhile.
  List<GuideTrip>? _remoteTrips;
  int? _remoteTotalBookings;

  DashboardCubit({
    GuideTripsRepository? trips,
    BookingsRepository? bookings,
  })  : _tripsRepo = trips ?? GuideTripsRepository(),
        _bookingsRepo = bookings ?? BookingsRepository(),
        super(_initial()) {
    GuideTripsStore.addListener(_rebuild);
    _rebuild();
    _loadVerificationStatus();
    loadRemote();
  }

  static DashboardState _initial() {
    final base = GuideDashboardStats.fromJson(mockGuideDashboardRaw);
    // Every numeric counter starts at 0 and stays 0 until Firebase data
    // arrives — never mock, hardcoded, cached, or session counts.
    return DashboardState(
      stats: GuideDashboardStats(
        guideName: base.guideName,
        avatarUrl: base.avatarUrl,
        totalBookings: 0,
        upcomingTrips: 0,
        activeTrips: 0,
        completedTrips: 0,
        earningsLabel: base.earningsLabel,
        pendingRequests: 0,
      ),
      bookings: mockBookingRequestsRaw.map(BookingRequest.fromJson).toList(),
      showVerificationBanner: true,
      isLoading: true,
    );
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final approved =
          await TourGuideAuthService().isVerificationApproved();
      emit(
        state.copyWith(
          showVerificationBanner: !approved,
          isLoading: state.isLoading,
          countsError: state.countsError,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          showVerificationBanner: true,
          isLoading: state.isLoading,
          countsError: state.countsError,
        ),
      );
    }
  }

  void _rebuild() {
    // Counts derive from remote Firebase data only. Before the first
    // successful load (or after a failed one clears the cache) every
    // counter stays 0 — session/mock rows are never substituted.
    final trips = _remoteTrips ?? const <GuideTrip>[];
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
          totalBookings: _remoteTotalBookings ?? 0,
          upcomingTrips: active + pending,
          activeTrips: active,
          completedTrips: count(GuideTripStatus.completed),
          earningsLabel: base.earningsLabel,
          pendingRequests: pending,
        ),
        bookings:
            mockBookingRequestsRaw.map(BookingRequest.fromJson).toList(),
        isLoading: state.isLoading,
        countsError: state.countsError,
      ),
    );
  }

  /// Loads the signed-in guide's trips + bookings from Firebase and
  /// recomputes the counters from real data. Signed-out/demo flows keep
  /// the mock baseline silently; genuine failures keep it with an
  /// explicit error (never presented as live data).
  Future<void> loadRemote() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      // Signed-out/demo: no remote source — stop loading, keep zeros.
      emit(state.copyWith(isLoading: false, countsError: null));
      return;
    }
    emit(state.copyWith(isLoading: true, countsError: null));
    try {
      final tripsRes = await _tripsRepo.myTrips(uid);
      // Capped page: totals stay approximate for very large histories.
      final bookingsRes = await _bookingsRepo.guideBookings(uid, limit: 500);
      if (tripsRes is FirestoreFailure) {
        throw Exception((tripsRes as FirestoreFailure).message);
      }
      if (bookingsRes is FirestoreFailure) {
        throw Exception((bookingsRes as FirestoreFailure).message);
      }
      _remoteTrips = tripsRes is FirestoreOk<List<GuideTrip>>
          ? tripsRes.data
          : const [];
      _remoteTotalBookings =
          bookingsRes is FirestoreOk<List<BookingDoc>>
              ? bookingsRes.data.length
              : 0;
      _rebuild();
      emit(state.copyWith(isLoading: false, countsError: null));
    } catch (e) {
      debugPrint('Triply: DashboardCubit.loadRemote failed: $e');
      _remoteTrips = null;
      _remoteTotalBookings = null;
      _rebuild();
      emit(
        state.copyWith(
          isLoading: false,
          countsError: 'Could not load dashboard stats. Showing saved data.',
        ),
      );
    }
  }

  /// Force a recompute (e.g. after returning from a flow that mutates
  /// trips without going through the store listener).
  void refresh() => loadRemote();

  @override
  Future<void> close() {
    GuideTripsStore.removeListener(_rebuild);
    return super.close();
  }
}
