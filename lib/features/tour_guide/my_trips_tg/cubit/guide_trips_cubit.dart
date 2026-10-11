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

  /// Re-reads the store (call after returning from Create Trip).
  void refresh() {
    emit(state.copyWith(trips: _filter(state.selectedStatus)));
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
    emit(state.copyWith(selectedStatus: status, trips: _filter(status)));
  }

  /// Best-effort remote refresh for [guideId]. Returns true when remote
  /// trips replaced the list; false when session data was kept — callers
  /// must surface this, never present session data as live data.
  Future<bool> loadRemote(String guideId) async {
    try {
      final result = await _repository.myTrips(guideId);
      if (result is FirestoreOk<List<GuideTrip>> && result.data.isNotEmpty) {
        final trips = result.data
            .where((t) => t.status == state.selectedStatus)
            .toList();
        emit(state.copyWith(trips: trips));
        return true;
      }
    } catch (e) {
      debugPrint('Triply: GuideTripsCubit.loadRemote failed: $e');
      return false;
    }
    debugPrint('Triply: GuideTripsCubit.loadRemote kept session data.');
    return false;
  }
}
