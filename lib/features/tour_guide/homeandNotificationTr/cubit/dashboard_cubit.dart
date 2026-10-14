import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/datasources/users_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
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
/// remote trips by mapped status (approved → active). [earningsLabel] sums
/// non-cancelled booking totals and the New bookings rows map the newest
/// active bookings — both fall back to mock until the first successful load.
class DashboardCubit extends Cubit<DashboardState> {
  final GuideTripsRepository _tripsRepo;
  final BookingsRepository _bookingsRepo;
  final TripsDatasource _tripsDs;
  final UsersDatasource _usersDs;

  /// Last successful remote fetch. Null until the first success — counts
  /// fall back to the session/mock store meanwhile.
  List<GuideTrip>? _remoteTrips;
  int? _remoteTotalBookings;
  List<BookingRequest>? _remoteBookings;
  String? _remoteEarningsLabel;

  DashboardCubit({
    GuideTripsRepository? trips,
    BookingsRepository? bookings,
    TripsDatasource? tripsDs,
    UsersDatasource? usersDs,
  })  : _tripsRepo = trips ?? GuideTripsRepository(),
        _bookingsRepo = bookings ?? BookingsRepository(),
        _tripsDs = tripsDs ?? TripsDatasource(),
        _usersDs = usersDs ?? UsersDatasource(),
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
          earningsLabel: _remoteEarningsLabel ?? base.earningsLabel,
          pendingRequests: pending,
        ),
        bookings: _remoteBookings ??
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
      final bookingDocs = bookingsRes is FirestoreOk<List<BookingDoc>>
          ? bookingsRes.data
          : const <BookingDoc>[];
      _remoteTotalBookings = bookingDocs.length;
      // "New bookings" rows + earnings from the same server snapshot.
      // Active (non-cancelled) bookings first, newest first, capped at 5.
      final active = bookingDocs
          .where((b) => b.status != 'cancelled')
          .toList()
        ..sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      final rows = <BookingRequest>[];
      for (final b in active.take(5)) {
        var guestName = '';
        var avatarUrl = '';
        try {
          final user = await _usersDs.getById(b.touristId);
          guestName = user?.fullName ?? '';
          avatarUrl = user?.avatarUrl ?? '';
        } catch (_) {}
        var tourTitle = '';
        if (b.tripId != null && b.tripId!.isNotEmpty) {
          try {
            tourTitle =
                await _tripsDs.getById(b.tripId!).then((t) => t?.title ?? '');
          } catch (_) {}
        }
        rows.add(FirestoreMappers.bookingDocToBookingRequest(
          b,
          guestName: guestName,
          tourTitle: tourTitle,
          avatarUrl: avatarUrl,
        ));
      }
      if (rows.isNotEmpty) _remoteBookings = rows;
      final earnings = FirestoreMappers.guideEarningsTotal(bookingDocs);
      if (earnings > 0) {
        _remoteEarningsLabel =
            'EGP ${earnings.toStringAsFixed(earnings.truncateToDouble() == earnings ? 0 : 2)}';
      }
      _rebuild();
      emit(state.copyWith(isLoading: false, countsError: null));
    } catch (e) {
      debugPrint('Triply: DashboardCubit.loadRemote failed: $e');
      _remoteTrips = null;
      _remoteTotalBookings = null;
      _remoteBookings = null;
      _remoteEarningsLabel = null;
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
