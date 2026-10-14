import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/repositories/guide_trips_repository.dart';
import '../../../../core/data/guide_trips_store.dart';
import '../../../../core/data/mock/tourguide/mock_guide_trips.dart';
import '../model/guide_trip.dart';
import 'guide_trips_state.dart';

/// Guide-side trip management (mock -> Model). Owns status filter.
///
/// Firestore bridge: [loadRemote] swaps in the guide's own `trips/` docs
/// on success; session mocks are kept on any failure/empty result.
class GuideTripsCubit extends Cubit<GuideTripsState> {
  final GuideTripsRepository _repository;
  GuideTripsCubit({
    GuideTripStatus initialStatus = GuideTripStatus.active,
    GuideTripsRepository? repository,
  })  : _repository = repository ?? GuideTripsRepository(),
        super(
          GuideTripsState(
            selectedStatus: initialStatus,
            trips: _filter(initialStatus),
          ),
        );

  static List<GuideTrip> _all() => GuideTripsStore.applyUpdates([
    ...GuideTripsStore.created,
    ...mockGuideTripsJson.map((e) => GuideTrip.fromJson(e)),
  ]);

  /// Last successful remote fetch (all statuses). Tab filters read this
  /// first so switching tabs never drops back to session/mock data.
  /// Null until the first success.
  List<GuideTrip>? _remoteTrips;

  List<GuideTrip> _visible(GuideTripStatus status) =>
      (_remoteTrips ?? _all()).where((t) => t.status == status).toList();

  /// Re-reads the current source (call after returning from Create Trip).
  void refresh() {
    emit(state.copyWith(trips: _visible(state.selectedStatus)));
  }

  static List<GuideTrip> _filter(GuideTripStatus status) =>
      _all().where((t) => t.status == status).toList();

  static String label(GuideTripStatus status) {
    switch (status) {
      case GuideTripStatus.active:
        return 'Active';
      case GuideTripStatus.pending:
        return 'Pending';
      case GuideTripStatus.rejected:
        return 'Rejected';
      case GuideTripStatus.completed:
        return 'Completed';
      case GuideTripStatus.cancelled:
        return 'Cancelled';
    }
  }

  void selectStatus(GuideTripStatus status) {
    emit(state.copyWith(selectedStatus: status, trips: _visible(status)));
  }

  /// Best-effort remote refresh for [guideId]. Returns true when remote
  /// trips replaced the list; false when session data was kept — callers
  /// must surface this, never present session data as live data.
  Future<bool> loadRemote(String guideId) async {
    try {
      final result = await _repository.myTrips(guideId);
      if (result is FirestoreOk<List<GuideTrip>> && result.data.isNotEmpty) {
        _remoteTrips = result.data;
        emit(
          state.copyWith(
            trips: _visible(state.selectedStatus),
            isLoading: false,
          ),
        );
        return true;
      }
    } catch (e) {
      debugPrint('Triply: GuideTripsCubit.loadRemote failed: $e');
      return false;
    }
    debugPrint('Triply: GuideTripsCubit.loadRemote kept session data.');
    return false;
  }

  /// Initial load: shows a spinner (never mock/session rows) while the
  /// Firebase list loads. Signed-out guides fall back to the local list.
  /// Returns true when remote trips replaced the list.
  Future<bool> loadInitial(String? guideId) async {
    emit(
      GuideTripsState(
        selectedStatus: state.selectedStatus,
        trips: const [],
        isLoading: true,
      ),
    );
    if (guideId == null || guideId.isEmpty) {
      emit(
        GuideTripsState(
          selectedStatus: state.selectedStatus,
          trips: _filter(state.selectedStatus),
        ),
      );
      return false;
    }
    final ok = await loadRemote(guideId);
    if (!ok) {
      // Initial load must not present mock/session rows as the list.
      emit(
        GuideTripsState(
          selectedStatus: state.selectedStatus,
          trips: const [],
        ),
      );
    }
    return ok;
  }
}
